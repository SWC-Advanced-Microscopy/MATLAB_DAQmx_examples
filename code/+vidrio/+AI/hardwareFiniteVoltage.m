function hardwareFiniteVoltage
    % Example showing hardware-timed analog input of a finite number of samples using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AI.hardwareFiniteVoltage
    %
    % Purpose
    % Shows how to do hardware-timed analog input using Vidrio's dabs.ni.daqmx wrapper. 
    % This function acquires a finite number of samples from multiple channels and plots
    % the results to screen after the acquisition finishes. The example uses the card's
    % on-board clock but uses no triggers. 
    %
    %
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Create an Analog Input voltage channel.
    %    3. Define the sample rate for the voltage acquisition. Additionally, define 
    %       the sample mode to be finite, and set the number of channels to be 
    %       acquired per channel.
    %    4. Call the Start function and wait until acquisition is complete.
    %    5. Read all data and plot to screen.
    %    6. Clear the task
    %    7. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % Vidrio example: dabs.ni.daqmx.demos.AnalogInput.Voltage_Finite_Input
    % TMW DAQ toolbox example: daqtoolbox.AI.analogInput_SingleShot
    % PyDAQmx example: https://pythonhosted.org/PyDAQmx/examples/multi_channel_analog_input.html
    % ANSI C: DAQmx_ANSI_C_examples/AI/Acq-IntClk.c


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'hardAI';    % A string that will provide a label for the task
    physicalChannels = 0:2; % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum



    % Task configuration
    sampleClockSource = 'OnboardClock'; % The source terminal used for the sample Clock. 
                                        % For valid values see: zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    sampleRate = 20E3;                  % Sample Rate in Hz
    secsToAcquire = 1;                  % Number of seconds over which to acquire data
    numberOfSamples = secsToAcquire * sampleRate; % The finite number of samples to acquire

    try 
        % * Create a DAQmx task
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task(taskName); 


        % * Set up analog input 0 on device defined by variable devName
        %   More details at: "help dabs.ni.daqmx.Task.createAIVoltageChan"
        %   It's is also valid to use device and channel only: e.g. "hTask.createAIVoltageChan(‘Dev1’,0);"
        %   C equivalent - DAQmxCreateAIVoltageChan
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaivoltagechan/
        hTask.createAIVoltageChan(devName,physicalChannels,[],minVoltage,maxVoltage);


        % * Configure the sampling rate and the number of samples
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',numberOfSamples,sampleClockSource);


        %We configured no triggers, so the acquisition starts as soon as hTask.start is run


        % Start the task and plot the data
        hTask.start  % start the acquisition 

        fprintf('Acquiring data...')
        hTask.waitUntilTaskDone;  % wait till all requested samples are acquired
        fprintf('\n')

        % "Scaled" sets the input to be represented as a voltage value. 
        % "Native" would have it be a raw integer (e.g. 16 bit number if this is a 16 bit DAQ)
        data = hTask.readAnalogData([],'scaled',0); % read all available data 

    catch ME
       daqDemosHelpers.errorDisplay(ME)
       return

    end %try/catch



    clf
    plot(data)
    legend({'AI 0','AI 1','AI 2'})
    xlabel('Samples')
    ylabel('Voltage')
    grid on


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

end %hardwareFiniteVoltage

