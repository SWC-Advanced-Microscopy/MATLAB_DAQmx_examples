function AOandAI
    % Demonstration of simultaneous analog input and output with the dabs.ni.daqmx wrapper
    %
    % function vidrio.mixed.AOandAI
    %
    % Description:
    %    This example demonstrates how to continuously run data acquisition (AI) 
    %    and signal generation (AO) at the same time and have the tasks synchronized 
    %    with one another. Note that a single DAQmx task can support only one type of channel:
    %    http://digital.ni.com/public.nsf/allkb/4D2E6ABCF652542186256F04004FDAC3
    %    So we need to make one task for AI, one for AO, and start them synchronously with an 
    %    internal trigger. If you have not done so already, first see the following two examples:
    %    vidrio.AI.hardwareContinuousVoltageWithCallBack
    %    vidrio.AO.hardwareContinuousVoltage
    %
    %    Note that in this example the AI and AO do not share a clock. They are set to run at 
    %    at the same sample rate, but they won't be running on the same clock. This can create 
    %    jitter and, for some desired sample rates, continuously variable phase delays. See: 
    %    vidrio.mixed.AOandAI_OO_sharedClock
    %
    %
    % Wiring instructions:
    % connect AI0 to AO0 on the DAQ device you are working on. 
    %
    %
    % Demonstrated steps:
    %    1. Create the AI and AO tasks and waveform to play.
    %    2. Create an analog input and an analog output voltage channel.
    %    3a. Set up the AI channel:
    %       i)   Set the rate for the sample clock for signal reading.
    %       ii)  Define the sample modes to be continuous and the buffer size.
    %       iii) Set up a callback function for reading and plotting the data.
    %    3b. Set up the AO channel:
    %       i)   Set the rate for the sample clock for signal generation.
    %       ii)  Define the sample modes to be continuous and the buffer size.
    %       iii) Allow regeneration so the data in the buffer are played out repeatedly.
    %       iii) Set the sample clock rate for the signal generation.
    %       iv)  Write data to the buffer
    %       v)   Configure the trigger on the AO task to start when the AI starts.
    %    4. Call the start function to arm the two tasks. Make sure the
    %       analog output is armed before the analog input. This will
    %       ensure both will start at the same time.
    %    6. Read the waveform data continuously until the figure window is closed.
    %    8. Call the Stop function to stop the acquisition.
    %    9. Display an error if any.
    %
    %
    %
    % Also see:
    % ANSI C: DAQmx_ANSI_C_examples/SynchAI-AO.c
    % Basic AO digital triggering: vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig
    % AO and AI with a class rather than a functio: vidrio.mixed.AOandAI_OO

    DAQdevice = 'Dev1';

    AIChans = 0; 
    AIterminalConfig = 'DAQmx_Val_Cfg_Default'; %Valid values: 'DAQmx_Val_Cfg_Default', 'DAQmx_Val_RSE', 'DAQmx_Val_NRSE', 'DAQmx_Val_Diff', 'DAQmx_Val_PseudoDiff'
    AOChan = 0; 

    minVoltage = -10;
    maxVoltage =  10;

    sampleRate = 5e3; % Samples per second

    %Play a sinewave out of the AO 
    waveform = sin(linspace(-pi,pi, sampleRate/55))' * 5; % Build a sine wave to play through the AO line. NOTE: column vector
    updatePeriod = 0.5; % How often to read 
    readEveryNpoints=round(updatePeriod * sampleRate); % every this many points read data

    % Open a figure window and have it shut off the acquisition when closed
    % See: basicConcepts/windowCloseFunction.m
    fprintf('Close figure to quit acquisition\n')
    fig = clf;
    set(fig, 'CloseRequestFcn', @windowCloseFcn, ...
           'Name', 'Close figure to stop acquisition')

    try
        % * Create separate DAQmx tasks for the AI and AO
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hAITask = dabs.ni.daqmx.Task;
        hAOTask = dabs.ni.daqmx.Task;


        % * Set up analog input and output voltage channels
        %   More details at: "help dabs.ni.daqmx.Task.createAOVoltageChan" and "help dabs.ni.daqmx.Task.createAIVoltageChan"
        %   C equivalent - DAQmxCreateAOVoltageChan
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaovoltagechan/
        hAITask.createAIVoltageChan(DAQdevice, AIChans, [], minVoltage, maxVoltage, [], [], AIterminalConfig);
        hAOTask.createAOVoltageChan(DAQdevice, AOChan);


        %--------------------------------------------------------------------------------
        % SET UP THE AI TASK

        % * Configure the sampling rate and the buffer size (make it comfortably bigger than the rate we will read with)
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        hAITask.cfgSampClkTiming(sampleRate, 'DAQmx_Val_ContSamps',  readEveryNpoints*10);

        % * Use a callback function to read from the buffer at the interval set by updatePeriod
        %   have been played out. Also see: basicConcepts/anonymousFunctionExample.
        %   More details at: "help dabs.ni.daqmx.Task.registerEveryNSamplesEvent"
        hAITask.registerEveryNSamplesEvent(@readAndPlotData, readEveryNpoints, false, 'Scaled');


        %-------------------------------------------------------------------------------
        % SET UP THE AO TASK

        % * Set the size of the output buffer to be equal to the waveform length (that's all we need, it's circular)
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        hAOTask.cfgSampClkTiming(sampleRate, 'DAQmx_Val_ContSamps', size(waveform,1));


        % * Allow sample regeneration
        % When the read buffer becomes empty, the card will just return to the buffer start
        % and then repeat the same values. 
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/mxcprop/attr1453/
        hAOTask.set('writeRegenMode', 'DAQmx_Val_AllowRegen');


        % * Write the waveform to the buffer with a 5 second timeout in case it fails
        %   More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
        %   Writes doubles using DAQmxWriteAnalogF64
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxwriteanalogf64/
        hAOTask.writeAnalogData(waveform, 5)


        % * Configure the AO task to start as soon as the AI task starts
        %   More details at: "help dabs.ni.daqmx.Task.cfgDigEdgeStartTrig"
        %   DAQmxCfgDigEdgeStartTrig
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgdigedgestarttrig/
        hAOTask.cfgDigEdgeStartTrig(['/',DAQdevice,'/ai/StartTrigger'], 'DAQmx_Val_Rising')
        
        hAOTask.start();
        hAITask.start();

    catch ME

        if exist('hAITask','var') %Because if AI exists then very likely AO does also
            fprintf('Cleaning up DAQ task\n');
            hAITask.stop;    % Calls DAQmxStopTask
            hAOTask.stop;
            delete([hAITask, hAOTask]);  % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
            delete(fig)
        else
            fprintf('No task variable present for clean up\n')
        end

        daqDemosHelpers.errorDisplay(ME)
      
    end %try/catch


    function readAndPlotData(src,~)
        % Scaled sets the input to be represented as a voltage value
        inData = readAnalogData(src, src.everyNSamples, 'Scaled'); 
        plot(inData)
        ylim([minVoltage, maxVoltage])
        grid on
    end %close readAndPlotData



    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    function windowCloseFcn(~,~)
        % This runs when the user closes the figure window or if there is an error
        % Note it's also possible to run a clean-up callback function with hTask.registerDoneEvent
        if exist('hAITask','var') %Because if AI exists then very likely AO does also
           disp('Closing the connection to the DAQ in windowCloseFcn');
           hAITask.stop;    % Calls DAQmxStopTask
           hAOTask.stop;
           delete([hAITask, hAOTask]);
        else
            fprintf('No task variable present for clean up\n')
        end

        if exist('fig','var') %In case this is called in the catch block
            delete(fig)
        end
    end %close windowCloseFcn


end %close vidrio.mixed.AOandAI
