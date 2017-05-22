classdef sine_AO_AI < handle
    % Demonstration of simultaneous analog input and output with the dabs.ni.daqmx wrapper
    %
    % vidrio.sync.sine_AO_AI 
    %
    %
    % Description:
    %    This class does continuous data acquisition (AI) and signal generation (AO).
    %    See the vidrio.mixed package for details. This class is sparse on documentation.
    %
    %
    % Usage information
    % Wire up AO 0 to AI 0 and AO 1 to AI 1 then try the following at the command line:
    % >> DAQ = vidrio.mixed.AOandAI_OO % Starts the acquisition and plots to screen
    % >> DAQ.stopAcquisition   % Stops the acquisition
    % >> DAQ.startAcquisition  % Re-starts the acquisition
    % >> DAQ.changeWaveformBFreqMult(4)  % Have the the AO 1 frequency be four times that of AO 0
    % >> delete(DAQ) % To stop (or close the window)
    %
    %
    % Also see:
    % vidrio.mixed.AOandAI, vidrio.mixed.AOandAI_OO



    % Define properties that we will use for the acquisition 
    properties
        DAQdevice  % The device on which the AO and AI tasks will run
        %Properties for the analog input end of things
        hAITask %The AI task will be kept here

        %Properties for the analog output end of things
        hAOTask %The AO task will be kept here
        AOChans = 0

        % Shared properties
        minVoltage = -10
        maxVoltage =  10

        sampleRate = 5e4   %Hz
        updatePeriod = 0.15 % How often to read 
    end %close properties block

    properties (SetObservable) 
        acquiredData
    end

    properties (Hidden)
        waveform % The waveforms we will play out are stored in the "waveforms" property
        AIChans = 0:1 
        AIterminalConfig = 'DAQmx_Val_PseudoDiff' %Valid values: 'DAQmx_Val_Cfg_Default', 'DAQmx_Val_RSE', 'DAQmx_Val_NRSE', 'DAQmx_Val_Diff', 'DAQmx_Val_PseudoDiff'
    end



    methods

        function obj=sine_AO_AI(deviceName, autoStart)
            if nargin<2
                autoStart=false;
            end

            obj.DAQdevice = deviceName;

            % Call a method to connect to the DAQ. If the following line fails, the destructor is called.
            obj.connectToDAQandSetUpChannels

            if autoStart
                % Start the acquisition
                obj.startAcquisition
            end
        end % close constructor


        function delete(obj)
            fprintf('Tidying up vidrio.sync.sine_AO_AI on DAQ "%s"\n', obj.DAQdevice)
            obj.stopAcquisition % Call the method that stops the DAQmx tasks
            obj.hAITask.delete;
            obj.hAOTask.delete;
        end %close destructor


        function connectToDAQandSetUpChannels(obj)
            % Note how we try to name the methods in the most descriptive way possible
            % Attempt to connect to the DAQ and set it up. If we fail, we close the 
            % connection to the DAQ and tidy up
            try
                % Create separate DAQmx tasks for the AI and AO
                obj.hAITask = dabs.ni.daqmx.Task([obj.DAQdevice, 'mixedAI']);
                obj.hAOTask = dabs.ni.daqmx.Task([obj.DAQdevice, 'mixedAO']);

                %  Set up analog input and output voltage channels
                obj.hAITask.createAIVoltageChan(obj.DAQdevice, obj.AIChans, [], obj.minVoltage, obj.maxVoltage, [], []); %can set up obj.AIterminalConfig here if neede
                obj.hAOTask.createAOVoltageChan(obj.DAQdevice, obj.AOChans);


                % * Set up the AI task

                % Configure the sampling rate and the buffer size with a *shared clock* between AO and AI
                obj.hAITask.cfgSampClkTiming(obj.sampleRate, 'DAQmx_Val_ContSamps', [], ['/',obj.DAQdevice,'/ao/SampleClock']);

                % Read back the data with a callback function at an interval defined by updatePeriod
                % Also see: basicConcepts/anonymousFunctionExample.
                obj.hAITask.registerEveryNSamplesEvent(@obj.readData, round(obj.sampleRate*obj.updatePeriod), false, 'Scaled');


                % * Set up the AO task
                % Set the size of the output buffer
                obj.hAOTask.cfgSampClkTiming(obj.sampleRate, 'DAQmx_Val_ContSamps', size(obj.waveform,1));

                % Allow sample regeneration (buffer is circular)
                obj.hAOTask.set('writeRegenMode', 'DAQmx_Val_AllowRegen');

                % Write the waveform to the buffer with a 5 second timeout in case it fails
                obj.waveform = sin(linspace(-pi,pi, obj.sampleRate/51))' * 5;
                obj.hAOTask.writeAnalogData(obj.waveform, 5)

                % Configure the AO task to start as soon as the AI task starts
                obj.hAOTask.cfgDigEdgeStartTrig(['/',obj.DAQdevice,'/ai/StartTrigger'], 'DAQmx_Val_Rising');


            catch ME
                    daqDemosHelpers.errorDisplay(ME)
                    %Tidy up if we fail
                    obj.delete
            end
        end % close connectToDAQandSetUpChannels


        function startAcquisition(obj)
            % This method starts acquisition on the AO then the AI task. 
            % Acquisition begins immediately since there are no external triggers.
            try
                obj.hAOTask.start();
                obj.hAITask.start();
            catch ME
                daqDemosHelpers.errorDisplay(ME)
                %Tidy up if we fail
                obj.delete
            end
        end %close startAcquisition


        function stopAcquisition(obj)
            % Stop the AI and then AO tasks
            fprintf('Stopping the task\n');
            obj.hAITask.stop;    % Calls DAQmxStopTask
            obj.hAOTask.stop;
        end %close stopAcquisition


        function readData(obj,src,evnt)
            % Scaled sets the input to be represented as a voltage value
            obj.acquiredData = readAnalogData(src,src.everyNSamples,'Scaled');
        end %close readData


    end %close methods block

end %close the vidrio.mixed.AOandAI_OO class definition 
