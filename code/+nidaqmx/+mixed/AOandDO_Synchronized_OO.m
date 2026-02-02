classdef AOandDO_Synchronized_OO < handle
    % Demonstration of simultaneous analog output and digital output with DAQmx .NET with a class
    % This shows how to start and stop the signal playback with different conditions. 
    % For a function that is more basic and just starts up and plays signals see:
    % vidrio.mixed.AOandDO_Synchronized
    %
    % 
    %% Example
    %
    % % Create the tasks and start them 
    % D = nidaqmx.mixed.AOandDO_Synchronized_OO;
    %
    % % We can now stop and start the tasks
    % D.stopTasks
    % D.startTasks
    % 
    % % Change the AO amplitude:
    % D.AOamplitude=1;
    % D.buildWaveforms
    % D.writeData
    %
    % % Change the frequency of the AO waveform
    % D.aoFreq=20;
    % D.buildWaveforms
    % plot(D.aoWaveform) % The AO waveform we will play out
    % D.plotWaveforms % Or use the method provided by the class to plot all waveforms
    % D.writeData
    %
    % % Change the DO waveform
    % D.doFreq2=200;
    % D.buildWaveforms
    % D.writeData
    %
    %
    % % Tidy up.
    %  clear D
    %
    %
    % Rob Campbell -- SWC 2026


    properties

        % TODO -- work with a fixed buffer size so when we change waveforms everything makes sense. 

        %% Define the stimulation parameters
        sampleRate = 10000  % Samples per second. Best not to change this
        bufferSize = 1000; % Will force a buffer of this length. 

        % The frequency and amplitude of the AO sine wave
        aoFreq  = 10          % 10 Hz sine wave on AO0
        AOamplitude = 2.5

        % The frequency of the DO waves coming out of P0.0 and P0.1
        doFreq1 = 10          % 10 Hz square wave on P0.0
        doFreq2 = 100         % 100 Hz square wave on P0.1

        % Waveforms that are to be written to the DAQ
        aoWaveform  % AO waveform
        sqTrace1    % p0.0 DO trace
        sqTrace2    % p0.1 DO trace
        doPortData  % packed port data version of sqTrace1 and sqTrace2

        DAQdevice % string defining the name of the DAQ

        % Handles for the AO and DO task and stream writers
        aoTask
        doTask
        aoWriter
        doWriter

    end % properties


    methods


        function obj = AOandDO_Synchronized_OO(DAQdevice, autoStart)
            %% Load DAQmx .NET assembly
            NET.addAssembly('NationalInstruments.DAQmx');
            import NationalInstruments.DAQmx.*

            if nargin<1 || isempty(DAQdevice)
                obj.DAQdevice = 'Dev1';
            end

            if nargin<2
                autoStart = true;
            end

            if ~nidaqmx.deviceExists(obj.DAQdevice)
                fprintf('%s does not exist\n', obj.DAQdevice)
                return
            end


            %% Reset the device
            DaqSystem.Local.LoadDevice(obj.DAQdevice).Reset;

            %------------------------------------------------------------------
            % Create separate DAQmx tasks for the AO and DO
            %
            % C equivalent - DAQmxCreateTask
            % http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
            %
            obj.aoTask = NationalInstruments.DAQmx.Task;
            obj.doTask = NationalInstruments.DAQmx.Task;


            %------------------------------------------------------------------
            % Now we run through all the steps to create the channels, build the waveforms,
            % set up all the triggering and shared clocks, play out the waveforms. This is 
            % all done by a bunch of methods that can be accessed externally, making it 
            % possible for the playback to be stopped, the waveforms modified, and the 
            % playback resumed. 
            if autoStart
                obj.buildWaveforms
                obj.createChannels
                obj.configureAOtask
                obj.configureDOtask
                obj.writeData
                obj.startTasks
            end

        end % constructor



        function delete(obj)
            obj.aoTask.Dispose
            obj.doTask.Dispose
        end % destructor


        function stopTasks(obj)
            % Stop and clean up
            obj.aoTask.Stop;
            obj.doTask.Stop;
        end


        function startTasks(obj)

            % Arm the DO task first
            obj.doTask.Start;

            % Start the AO task (fires the trigger)
            obj.aoTask.Start;
        end


        function buildWaveforms(obj)
            % Build the AO and DO waveforms

            % Can not build the waveforms if the user asks for a rate that is lower
            % than samplerate/buffer size. 
            minFreq = obj.sampleRate/obj.bufferSize;
            if obj.aoFreq < minFreq
                fprintf('Setting frequency to %f', minFreq)
                obj.aoFreq = minFreq;
            end

            %% Build AO waveform (default is 10 Hz sine, +/-2.5 V)
            nCycles = obj.aoFreq/minFreq;

            aoSamplesPerPeriod = obj.sampleRate / obj.aoFreq;
            obj.aoWaveform = obj.AOamplitude * sin(linspace(nCycles*pi, nCycles*-pi, obj.bufferSize));



            %% Build DO waveforms using packed port data
            doSamplesPerPeriod1 = obj.sampleRate / obj.doFreq1;
            doSamplesPerPeriod2 = obj.sampleRate / obj.doFreq2;

            t = (0:obj.bufferSize-1)';

            obj.sqTrace1 = mod(floor(2 * obj.doFreq1 * t / obj.sampleRate), 2);   % The 10 Hz by default trace
            obj.sqTrace2 = mod(floor(2 * obj.doFreq2 * t / obj.sampleRate), 2);   % The 100 Hz by default trace

            % Pack into port word:
            %   bit0 -> P0.0
            %   bit1 -> P0.1
            obj.doPortData = uint32(obj.sqTrace1)*bitshift(1,0) + ...
                         uint32(obj.sqTrace2)*bitshift(1,1);

        end % buildWaveforms


        function createChannels(obj)
            import NationalInstruments.DAQmx.*

            % Create analog output voltage channel (AO0)
            obj.aoTask.AOChannels.CreateVoltageChannel( ...
                [obj.DAQdevice '/AO0'], ...
                'ao0', ...
                -10, 10, ...
                AOVoltageUnits.Volts);

            % Create digital output port channel (port0)
            obj.doTask.DOChannels.CreateChannel( ...
                [obj.DAQdevice '/port0'], ...
                'do0', ...
                ChannelLineGrouping.OneChannelForAllLines);

        end % createChannels



        function configureAOtask(obj)
            % Configure the AO TASK
            %
            import NationalInstruments.DAQmx.*

            % * Set the sampling rate and buffer size
            obj.aoTask.Timing.ConfigureSampleClock( ...
                '', ...
                obj.sampleRate, ...
                SampleClockActiveEdge.Rising, ...
                SampleQuantityMode.ContinuousSamples, ...
                length(obj.aoWaveform));


            % * Allow sample regeneration
            obj.aoTask.Stream.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;


            % * Make the writer class
            obj.aoWriter = AnalogSingleChannelWriter(obj.aoTask.Stream);

            % Verify the task
            obj.aoTask.Control(TaskAction.Verify);

        end % configureAOtask


        function configureDOtask(obj)
            % Configure the DO task
            import NationalInstruments.DAQmx.*

            % Set the sampling rate and buffer size of the DO task. 
            % Note that we are using the AO sample clock for the DO. 
            obj.doTask.Timing.ConfigureSampleClock( ...
                ['/' obj.DAQdevice '/ao/SampleClock'], ...
                obj.sampleRate, ...
                SampleClockActiveEdge.Rising, ...
                SampleQuantityMode.ContinuousSamples, ...
                obj.bufferSize);


            % * Allow sample regeneration
            obj.doTask.Stream.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;

            % * Make the writer class            
            obj.doWriter = DigitalSingleChannelWriter(obj.doTask.Stream);


            % Note
            % The DO task will start when it receives clock pulses and does not need
            % an explicit start trigger configured. Indeed, attemptig to do so causes
            % an error. 


            % Verify the task
            obj.doTask.Control(TaskAction.Verify);
        end % configureDOtask


        function writeData(obj)
            % Write waveforms to the AO and DO tasks
            obj.aoWriter.WriteMultiSample(false, obj.aoWaveform);

            % * Write digital pattern to the buffer
            obj.doWriter.WriteMultiSamplePort(false, obj.doPortData);
        end % writeData


        function plotWaveforms(obj)
            figure
            t = (0:length(obj.aoWaveform)-1)/(obj.sampleRate/1E3);
            plot(t, obj.aoWaveform,'k-','LineWidth',2)
            hold on
            plot(t, obj.sqTrace2*5,'b-','LineWidth',2)
            plot(t, 0.02+obj.sqTrace1*5,'r-','LineWidth',2)
            hold off
            xlabel('Time [ms]')
            ylabel('Amplitude [V]')
            grid on
        end

    end % methods


end % classdef
