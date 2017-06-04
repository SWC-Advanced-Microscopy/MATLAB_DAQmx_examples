classdef AOandAI_OO_sharedClock < handle
    % Demonstration of simultaneous analog input and output with a shared clock with the dabs.ni.daqmx wrapper
    %
    % vidrio.mixed.AOandAI_OO_sharedClock
    %
    %
    % Description:
    %    This example demonstrates how to use a class to continuously run data acquisition (AI) 
    %    and signal generation (AO) at the same time and have the tasks synchronized 
    %    with one another and having a shared clock.
    %     * If you want basic simultaneous AI an AO see:
    %             vidrio.mixed.AOandAI
    %     * If you are not familiar with basic AI or AO see the following two examples:
    %             vidrio.AI.hardwareContinuousVoltageWithCallBack
    %             vidrio.AO.hardwareContinuousVoltage
    %     * If you need a primer on object oriented programming see:
    %              "basicConcepts" directory
    %
    %
    %
    % Usage information
    % Wire up AO 0 to AI 0 and AO 1 to AI 1 then try the following at the command line:
    % >> DAQ = vidrio.mixed.AOandAI_OO_sharedClock % Starts the acquisition and plots to screen
    % >> DAQ.stopAcquisition   % Stops the acquisition
    % >> DAQ.startAcquisition  % Re-starts the acquisition
    % >> S.changeAOsampleRate(50E3) % Change the sample rate 
    % >> delete(DAQ) % To stop (or close the window)
    %
    %
    % Also see:
    % ANSI C: DAQmx_ANSI_C_examples/SynchAI-AO.c
    % Basic AO digital triggering: vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig
    % OO example of AO and AI with separate clocks: vidrio.mixed.AOandAI_OO



    % Define properties that we will use for the acquisition 
    properties
        DAQdevice = 'Dev1'

        %Properties for the analog input end of things
        hAITask %The AI task will be kept here
        AIChans = 0:1 
        AIterminalConfig = 'DAQmx_Val_RSE' %Valid values: 'DAQmx_Val_Cfg_Default', 'DAQmx_Val_RSE', 'DAQmx_Val_NRSE', 'DAQmx_Val_Diff', 'DAQmx_Val_PseudoDiff'

        %Properties for the analog output end of things
        hAOTask %The AO task will be kept here
        AOChans = 0:1

        % Shared properties
        minVoltage = -10
        maxVoltage =  10

        sampleRateAO = 10e3   %Hz
        updatePeriod = 0.15 % How often to read 

        % These properties hold information relevant to the plot window
        hFig %The handle to the figure which shows the data is stored here
        axis_A %Handles for the two axes
        axis_B 

        % The waveforms we will play out are stored in the "waveforms" property
        waveforms
        waveform_B_freqMultiplier=2
    end %close properties block

    methods

        function obj=AOandAI_OO_sharedClock
            % This method is the "constructor". It runs when the class is instantiated.
            % To create an object from a class, there must be a constructor. 

            fprintf('Please see "help vidrio.mixed.AOandAI_OO for usage information\n')

            % Build the figure window and have it shut off the acquisition when closed.
            % See: basicConcepts/windowCloseFunction.m
            obj.hFig = clf;
            obj.hFig.Position(3)=obj.hFig.Position(3)*1.5; %Make figure a little wider
            obj.hFig.Name='Close figure to stop acquisition'; %This is just the OO notation. We could also use the set command.
            obj.hFig.CloseRequestFcn = @obj.windowCloseFcn;


            %Make two empty axes which we fill in the method readAndPlotData
            obj.axis_A = axes('Parent', obj.hFig, 'Position', [0.1 0.12 0.4 0.8]);
            xlabel('Voltage (V)')
            ylabel('Samples')
            obj.axis_B = axes('Parent', obj.hFig, 'Position', [0.58 0.12 0.4 0.8]);

            % Plot some empty data which we will later modify in readAndPlotData
            % in the first plot we show the two waveforms as a function of time
            plot(obj.axis_A, zeros(round(obj.sampleRateAO*obj.updatePeriod),2))

            % In the second plot we will show AI 1 as a function of AI 0
            plot(obj.axis_B, zeros(round(obj.sampleRateAO*obj.updatePeriod),1),'.-')

            %Make plots look nice
            obj.axis_A.XLabel.String='Voltage (V)';
            obj.axis_A.YLabel.String='Samples';

            obj.axis_B.XLabel.String='Voltage (V)';
            obj.axis_B.YLabel.String='Samples';

            % Set properties of both axes together
            set([obj.axis_A,obj.axis_B], 'Box', 'On', 'XGrid', 'On', 'YGrid', 'On', 'YLim', [obj.minVoltage,obj.maxVoltage])
            set(obj.axis_B, 'XLim', [obj.minVoltage,obj.maxVoltage])

            % Call a method to connect to the DAQ. If the following line fails, the Tasks are
            % cleaned up gracefully and the object is deleted. This is all done by the method
            % call and by the destructor
            obj.connectToDAQandSetUpChannels


            % Start the acquisition
            obj.startAcquisition
            fprintf('Close figure to quit acquisition\n')
        end % close constructor


        function delete(obj)
            % This method is the "destructor". It runs when an instance of the class is deleted.
            % The destructor is not required for your class to be valid.

            fprintf('Tidying up vidrio.mixed.AOandAI_OO\n')
            obj.hFig.delete %Closes the plot window
            obj.stopAcquisition % Call the method that stops the DAQmx tasks

            % The tasks should delete automatically (which causes dabs.ni.daqmx.Task.delete to 
            % call DAQmxClearTask on each task) but for paranoia we can delete manually:
            obj.hAITask.delete;
            obj.hAOTask.delete;
        end %close destructor


        function connectToDAQandSetUpChannels(obj)
            % Note how we try to name the methods in the most descriptive way possible
            % Attempt to connect to the DAQ and set it up. If we fail, we close the 
            % connection to the DAQ and tidy up
            try
                % Create separate DAQmx tasks for the AI and AO
                obj.hAITask = dabs.ni.daqmx.Task('mixedAI');
                obj.hAOTask = dabs.ni.daqmx.Task('mixedAO');

                %  Set up analog input and output voltage channels
                obj.hAITask.createAIVoltageChan(obj.DAQdevice, obj.AIChans, [], obj.minVoltage, obj.maxVoltage, [], [], obj.AIterminalConfig);
                obj.hAOTask.createAOVoltageChan(obj.DAQdevice, obj.AOChans);


                % * Set up the AI task

                % Configure the sampling rate and the buffer size
                % ===> SET UP THE SHARED CLOCK: Use the AO sample clock for the AI task <===
                % The supplied sample rate for the AI task is a nominal value. It will in fact use the AO sample clock. 
                obj.hAITask.cfgSampClkTiming(obj.sampleRateAO, 'DAQmx_Val_ContSamps', [], ['/',obj.DAQdevice,'/ao/SampleClock']);

                % Read back the data with a callback function at an interval defined by updatePeriod
                % Also see: basicConcepts/anonymousFunctionExample.
                obj.hAITask.registerEveryNSamplesEvent(@obj.readAndPlotData, round(obj.sampleRateAO*obj.updatePeriod), false, 'Scaled');


                % * Set up the AO task
                % Set the size of the output buffer
                obj.hAOTask.cfgSampClkTiming(obj.sampleRateAO, 'DAQmx_Val_ContSamps', size(obj.waveforms,1));

                % Allow sample regeneration (buffer is circular)
                obj.hAOTask.set('writeRegenMode', 'DAQmx_Val_AllowRegen');

                % Write the waveform to the buffer with a 5 second timeout in case it fails
                obj.generateWaveforms %This will populate the waveforms property
                obj.hAOTask.writeAnalogData(obj.waveforms, 5)

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


        function generateWaveforms(obj)
            % Build sine waves to play through the AO line. NOTE: column vectors
            waveform0 = sin(linspace(-pi,pi, obj.sampleRateAO/51))' * 5; 
            waveform1 = sin(linspace(-pi*obj.waveform_B_freqMultiplier,pi*obj.waveform_B_freqMultiplier, length(waveform0)))' * 5; 
            obj.waveforms = [waveform0,waveform1];
        end %close generateWaveforms


        function changeAOsampleRate(obj,newRate)
            % Change sampling rate to a new rate. 
            obj.stopAcquisition
            obj.sampleRateAO = newRate;
            obj.hAOTask.cfgSampClkTiming(obj.sampleRateAO, 'DAQmx_Val_ContSamps', size(obj.waveforms,1));
            obj.startAcquisition
        end %close changeAOsampleRate


        function readAndPlotData(obj,src,evnt)
            % Scaled sets the input to be represented as a voltage value
            inData = readAnalogData(src,src.everyNSamples,'Scaled');

            %We keep the plot objects the same and just change their data properties
            C=get(obj.axis_A, 'Children');
            C(1).YData=inData(:,1);
            C(2).YData=inData(:,2);

            C=get(obj.axis_B, 'Children');
            C.XData=inData(:,1);
            C.YData=inData(:,2);
        end %close readAndPlotData


        function windowCloseFcn(obj,~,~)
            % This runs when the user closes the figure window or if there is an error
            % Note it's also possible to run a clean-up callback function with hTask.registerDoneEvent

            fprintf('You closed the window. Shutting down DAQ.\n')
            obj.delete % simply call the destructor
        end %close windowCloseFcn

    end %close methods block

end %close the vidrio.mixed.AOandAI_OO class definition 
