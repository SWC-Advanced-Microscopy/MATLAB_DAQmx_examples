classdef AOandAI_OO < handle
    % Demonstration of simultaneous analog input and output with the dabs.ni.daqmx wrapper
    %
    % vidrio.mixed.AOandAI_OO
    %
    %
    % Description:
    %    This example demonstrates how to use a class to continuously run data acquisition (AI) 
    %    and signal generation (AO) at the same time and have the tasks synchronized 
    %    with one another. Note that a single DAQmx task can support only one type of channel:
    %    http://digital.ni.com/public.nsf/allkb/4D2E6ABCF652542186256F04004FDAC3
    %    So we need to make one task for AI, one for AO, and start them synchronously with an 
    %    internal trigger. The focus of this example is doing DAQ tasks using object-oriented 
    %    programming. 
    %     * If you want basic simultaneous AI an AO see:
    %             vidrio.mixed.AOandAI
    %     * If you are not familiar with basic AI or AO see the following two examples:
    %             vidrio.AI.hardwareContinuousVoltageWithCallBack
    %             vidrio.AO.hardwareContinuousVoltage
    %     * If you need a primer on object oriented programming see:
    %              "basicConcepts" directory
    %
    %    Note that in this example the AI and AO do not share a clock. They are set to run at 
    %    at the same rate, but they won't be running on the same clock. This can create jitter 
    %    and, for some desired sample rates, continuously variable phase delays. See: 
    %    vidrio.mixed.AOandAI_OO_sharedClock
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
    % ANSI C: DAQmx_ANSI_C_examples/SynchAI-AO.c
    % Basic AO digital triggering: vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig
    % AO and AI with a function rather than a class: vidrio.mixed.AOandAI



    % Define properties that we will use for the acquisition 
    properties
        %Properties for the analog input end of things
        hAITask %The AI task will be kept here
        AIDevice = 'Dev1'
        AIChans = 0:1 
        AIterminalConfig = 'DAQmx_Val_RSE' %Valid values: 'DAQmx_Val_Cfg_Default', 'DAQmx_Val_RSE', 'DAQmx_Val_NRSE', 'DAQmx_Val_Diff', 'DAQmx_Val_PseudoDiff'

        %Properties for the analog output end of things
        hAOTask %The AO task will be kept here
        AODevice = 'Dev1'
        AOChans = 0:1

        % Shared properties
        minVoltage = -10
        maxVoltage =  10

        sampleRate = 10e3   %Hz
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

        function obj=AOandAI_OO
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
            obj.axis_B = axes('Parent', obj.hFig, 'Position', [0.58 0.12 0.4 0.8]);

            % Plot some empty data which we will later modify in readAndPlotData
            % in the first plot we show the two waveforms as a function of time
            plot(obj.axis_A, zeros(round(obj.sampleRate*obj.updatePeriod),2))

            % In the second plot we will show AI 1 as a function of AI 0
            plot(obj.axis_B, zeros(round(obj.sampleRate*obj.updatePeriod),1),'.-')

            %Make plots look nice
            obj.axis_A.YLabel.String='Voltage (V)';
            obj.axis_A.XLabel.String='Samples';

            obj.axis_B.XLabel.String='AI0 Voltage (V)';
            obj.axis_B.YLabel.String='AI1 Voltage (V)';

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
                obj.hAITask.createAIVoltageChan(obj.AIDevice, obj.AIChans, [], obj.minVoltage, obj.maxVoltage, [], [], obj.AIterminalConfig);
                obj.hAOTask.createAOVoltageChan(obj.AODevice, obj.AOChans);


                % * Set up the AI task

                % Configure the sampling rate and the buffer size
                obj.hAITask.cfgSampClkTiming(obj.sampleRate,'DAQmx_Val_ContSamps', round(obj.sampleRate*obj.updatePeriod)*10);

                % Read back the data with a callback function at an interval defined by updatePeriod
                % Also see: basicConcepts/anonymousFunctionExample.
                obj.hAITask.registerEveryNSamplesEvent(@obj.readAndPlotData, round(obj.sampleRate*obj.updatePeriod), false, 'Scaled');


                % * Set up the AO task
                % Set the size of the output buffer
                obj.hAOTask.cfgSampClkTiming(obj.sampleRate, 'DAQmx_Val_ContSamps', size(obj.waveforms,1));

                % Allow sample regeneration (buffer is circular)
                obj.hAOTask.set('writeRegenMode', 'DAQmx_Val_AllowRegen');

                % Write the waveform to the buffer with a 5 second timeout in case it fails
                obj.generateWaveforms %This will populate the waveforms property
                obj.hAOTask.writeAnalogData(obj.waveforms, 5)

                % Configure the AO task to start as soon as the AI task starts
                obj.hAOTask.cfgDigEdgeStartTrig(['/',obj.AIDevice,'/ai/StartTrigger'], 'DAQmx_Val_Rising');
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
            waveform0 = sin(linspace(-pi,pi, obj.sampleRate/51))' * 5; 
            waveform1 = sin(linspace(-pi*obj.waveform_B_freqMultiplier,pi*obj.waveform_B_freqMultiplier, length(waveform0)))' * 5; 
            obj.waveforms = [waveform0,waveform1];
        end %close generateWaveforms


        function changeWaveformBFreqMult(obj,newVal)
            % Restarts the acquisition with a new frequency relationship
            obj.stopAcquisition
            obj.waveform_B_freqMultiplier=newVal;
            obj.generateWaveforms

            try
                obj.hAOTask.writeAnalogData(obj.waveforms, 5)
            catch ME 
                daqDemosHelpers.errorDisplay(ME)
                %Tidy up if we fail
                obj.delete
            end

            obj.startAcquisition
        end %close changeWaveformBFreqMult


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
