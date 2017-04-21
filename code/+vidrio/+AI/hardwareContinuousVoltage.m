function hardwareContinuousVoltage
    % A simple example showing hardware-timed continuous analog input using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AI.hardwareContinuousVoltage
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog input using Vidrio's dabs.ni.daqmx wrapper. 
    % This function continuously acquires data from multiple channels and plots the results to screen as
    % the data come in. Plotting is achieved in a very simple way with repeated call to plot in a while loop.
    % The example uses the card's on-board clock but uses no triggers. 
    %
    %
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Create multiple Analog Input voltage channels.
    %    3. Set the sample rate, define the sample mode to be continuous.
    %    4. Call the Start function.
    %    5. Read in the data continuously TODO: FINISH
    %    6. Clear the task
    %    7. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % Vidrio example: dabs.ni.daqmx.demos.AnalogInput.Voltage_Continuous_Input
    % The following two examples are similar but use a callback function to plot the data
    % TMW DAQ Toolbox example: daqtoolbox.AI.analogInput_Continuous
    % ANSI C: DAQmx_ANSI_C_examples/AI/ContAcq-IntClk.c 



    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    % Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'hardAI';    % A string that will provide a label for the task
    physicalChannels = 0:3; % A scalar or an array with the channel numbers
    minVoltage = -0.5;       % Channel input range minimum
    maxVoltage = 0.5;        % Channel input range maximum


    % Task configuration
    sampleClockSource = 'OnboardClock'; % The source terminal used for the sample Clock. 
                                        % For valid values see: zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    sampleRate = 5000;                  % Sample Rate in Hz
    numSamplesPerChannel = sampleRate*2 ; % The number of samples to be stored in the buffer per channel


    try
        % * Create a DAQmx task
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task(taskName); 


        % * Set up analog output 0 on device defined by variable devName
        %   More details at: "help dabs.ni.daqmx.Task.createAOVoltageChan"
        %   C equivalent - DAQmxCreateAOVoltageChan
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaovoltagechan/
        hTask.createAIVoltageChan(devName, physicalChannels, [], minVoltage, maxVoltage);


        % * Configure the sampling rate and the number of samples
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        hTask.cfgSampClkTiming(sampleRate, 'DAQmx_Val_ContSamps', numSamplesPerChannel, sampleClockSource);


        % Start the task and wait until it is complete. Task starts right away since we
        % configured no triggers
        hTask.start


        fprintf('Recoding data on %s. Hit ctrl-C to stop.\n', devName);
        clf 
        while 1
            % readAnalogData returns once 500 samples have been acquired or the 5 second timeout is reached
            % More details at:  "help dabs.ni.daqmx.Task.readAnalogData"
            data = hTask.readAnalogData(500,'scaled',5);
            plot(data)
            ylim([minVoltage,maxVoltage])
            drawnow
        end

    catch ME
       fprintf('\nERRROR: %s\n\n',ME.message)
       return

    end %try/catch


    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    function cleanUpFunction
        %This runs when the function ends
        if exist('hTask','var')
            fprintf('Cleaning up DAQ task\n');
            hTask.stop;    % Calls DAQmxStopTask
            delete(hTask); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
        else
            fprintf('No task variable present for clean up\n')
        end
    end %close cleanUpFunction

end %close hardwareContinuousVoltage
