function hardwareFiniteVoltage
    % Example showing hardware-timed analog output of a finite number of samples using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.hardwareFiniteVoltage
    %
    % Purpose
    % Shows how to do hardware-timed analog output using Vidrio's dabs.ni.daqmx wrapper. 
    % This function plays one cycle of a sine wave out of an analog output channel. The 
    % example uses the card's on-board clock but uses no triggers. 
    %
    %
    % Demonstrated steps:
    %    1. Create a vector comprising a single cycle of a sinewave which will play at 1 Hz.
    %    2. Create a task.
    %    3. Create an Analog Output Voltage channel.
    %    4. Define the update rate for the voltage generation. Additionally, define 
    %       the sample mode to be finite, and set the size of the output buffer to 
    %       be equal to the length of waveform we will be playing out.
    %    5  Write the waveform to the buffer. 
    %    6. Call the Start function and wait until generation is complete.
    %    7. Continuously play the waveform until the user hits ctrl-c or an error occurs.
    %    8. Clear the task
    %    9. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % Vidrio example: dabs.ni.daqmx.demos.AnalogOutput.Voltage_Finite_Output
    % TMW DAQ Toolbox example: daqtoolbox.AO.analogOutput_Finite



    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'hardAO';    % A string that will provide a label for the task
    physicalChannel = 0;    % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum


    % Task configuration
    sampleClockSource = 'OnboardClock'; % The source terminal used for the sample Clock. 
                                        % For valid values see: zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    sampleRate = 1000;                  % Sample Rate in Hz
    
    % Build one cycle of a sine wave to play through the AO line (note the transpose)
    waveForm=sin(linspace(-pi,pi, sampleRate))';
    numSamplesPerChannel = length(waveForm) ;   % The number of samples to be stored in the buffer per channel


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
        hTask.createAOVoltageChan(devName, physicalChannel, [], minVoltage, maxVoltage);


        % * Configure the sampling rate and the number of samples
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',numSamplesPerChannel,sampleClockSource);


        % * Set the size of the output buffer
        %   More details at: "help dabs.ni.daqmx.Task.cfgOutputBuffer"
        %   C equivalent - DAQmxCfgOutputBuffer
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxcfgoutputbuffer/        
        hTask.cfgOutputBuffer(numSamplesPerChannel);


        % * Write the waveform to the buffer with a 5 second timeout in case it fails
        %   More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
        %   Writes doubles using DAQmxWriteAnalogF64
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxwriteanalogf64/
        hTask.writeAnalogData(waveForm, 5)


        % Start the task and wait until it is complete. Task starts right away since we
        % configured no triggers
        hTask.start
        
        fprintf('Playing sine wave through AO %d...\n', physicalChannel)
        hTask.waitUntilTaskDone; % wait until all requested samples have been played acquired

    catch err
        cleanUpFunction
        rethrow(err) %Display error

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


end %hardwareFiniteVoltage

