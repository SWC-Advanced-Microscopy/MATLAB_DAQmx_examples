function hardwareContinuousVoltageOnBoardFIFO
    % Example showing hardware-timed continuous analog output using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.hardwareContinuousVoltageOnBoardFIFO
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog output using Vidrio's dabs.ni.daqmx wrapper. 
    % This function ouputs a continuous sine wave out of an analog output channel using the DAQ's 
    % internal (on-board) sample clock. The example uses no triggers. The waveform is regenerated 
    % continuously from the FIFO buffer on the board. i.e. NO transfer from
    % PC during sine wave generation.
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the analog output to 
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    % 
    %
    % Demonstrated steps:
    %    1. Create a vector comprising a single cycle of a sinewave which will play at 1 Hz.
    %    2. Create a task.
    %    3. Create an Analog Output voltage channel.
    %    4. Define the update rate for the voltage generation. Additionally, define 
    %       the sample mode to be continuous, allow sample regeneration,
    %       use the on-board FIFO only.
    %    5  Write the waveform to the buffer. 
    %    7. Call the Start function.
    %    8. Continuously play the waveform until the user hits ctrl-c or an error occurs.
    %    9. Clear the task
    %    10. Display an error if any.
    %
    %
    % Rob Campbell - SWC, 2019
    %
    % 
    % Also see:
    % TMW DAQ Toolbox example: daqtoolbox.AO.analogOutput_Continuous
    % Vidrio example: dabs.ni.daqmx.demos.AnalogOutput.Voltage_Continuous_Output_NoRegeneration
    % ANSI C: DAQmx_ANSI_C_examples/AO/MultVoltUpdates-SWTimed.c
    % Restrictions on AO tasks: http://digital.ni.com/public.nsf/allkb/2C45C3DC484FF730862570E7007CCBD4?OpenDocument


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    % Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % The name of the DAQ device as shown in MAX
    taskName = 'hardAO';    % A string that will provide a label for the task
    physicalChannel = 0;    % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum


    % Task configuration
    sampleClockSource = 'OnboardClock'; % The source terminal used for the sample Clock. 
                                        % For valid values see: zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    sampleRate = 2E6;                   % Some large number. Check your card supports this!
    waveform=sin(linspace(-pi,pi, 8190))'*5; % Build one cycle of a sine wave. It MUST fit into the FIFO buffer. Check your buffer size! 
                                             % NOTE: it must be a column vector

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
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps',length(waveform),sampleClockSource);


        % * Do not allow sample regeneration
        % When the read buffer becomes empty, the card will not return to the start
        % and re-output the same values. 
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/mxcprop/attr1453/
        % For more on DAQmx write properties: http://zone.ni.com/reference/en-XX/help/370469AG-01/daqmxprop/daqmxwrite/
        hTask.set('writeRegenMode','DAQmx_Val_AllowRegen');
        
        
        % * Configure the AO task to use only the onboard FIFO buffer
        %   This means no data are sent from the PC to the card during 
        %   playback of the sine wave.
        %
        % http://zone.ni.com/reference/en-XX/help/370473J-01/ninetdaqmxfx40ref/html/p_nationalinstruments_daqmx_aochannel_useonlyonboardmemory/
        hTask.channels.set('useOnlyOnBrdMem',true) % <-- implements FIFO only
        
        
        % * Set the size of the output buffer
        %   You DO NOT need to set the buffer size here as DAQmxCfgOutputBuffer
        %   effects only the PC buffer, which we are not using
        %%hTask.cfgOutputBuffer(numSamplesPerChannel);  %NOT DONE 


        % * Write the waveform to the buffer with a 5 second timeout in case it fails
        %   More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
        %   Writes doubles using DAQmxWriteAnalogF64
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxwriteanalogf64/
        hTask.writeAnalogData(waveform, 5) 


        % Start the task and wait until it is complete. Task starts right away since we
        % configured no triggers
        hTask.start


        fprintf('Playing sine wave out of %s AO %d. Hit ctrl-C to stop.\n', devName, physicalChannel);
        % Output continues for as long as the following while loop runs
        while 1
            hTask.isTaskDone; % Checks for errors
            pause(0.5);
        end

    catch ME
       daqDemosHelpers.errorDisplay(ME)
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
