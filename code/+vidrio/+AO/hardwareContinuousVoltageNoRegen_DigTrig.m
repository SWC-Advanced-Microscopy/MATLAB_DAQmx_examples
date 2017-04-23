function hardwareContinuousVoltageNoRegen_DigTrig
    % Example showing hardware-timed continuous analog output without regeneration using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog output using Vidrio's dabs.ni.daqmx wrapper. 
    % This function ouputs a continuous sine wave out of an analog output channel using the DAQ's 
    % internal (on-board) sample clock. The example uses a digital trigger. The waveform is not regenerated 
    % continuously, so no callback to fill the buffer is needed. 
    %
    %
    % Usage
    % You can initiate the waveform output by connecting a hookup wire to PFI1 and touching 
    % this to the +5 V line
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
    %       the sample mode to be continuous and set the size of the output buffer to be equal 
    %       to the length of waveform we will be playing out.
    %    5  Write the waveform to the buffer. 
    %    6. Define the digital trigger
    %    7. Call the Start function.
    %    8. Continuously play the waveform until the user hits ctrl-c or an error occurs.
    %    9. Clear the task
    %    10. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % Vidrio example: dabs.ni.daqmx.demos.AnalogOutput.Voltage_Continuous_Output
    % ANSI C: DAQmx_ANSI_C_examples/ContGen-ExtClk-DigStart.c
    % vidrio.AO.hardwareContinuousVoltageNoRegen

    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    % Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'hardAO';    % A string that will provide a label for the task
    physicalChannel = 0;    % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum


    % Parameters for digital triggering
    % We will use a PFI (Programmable Function Interface) line as the trigger source
    % You can not conduct buffered acquisition on a PFI line but you can have changes on these lines instantly fire an event
    % The properties of the PFI lines vary between devices series:
    % http://digital.ni.com/public.nsf/allkb/8058F1BEF0944D99862574A3007EB53C
    dTriggerSource = 'PFI1';           % the terminal used for the digital trigger; refer to "Terminal Names" in the DAQmx help for valid values
    dTriggerEdge = 'DAQmx_Val_Rising'; % one of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}

    % Task configuration
    sampleClockSource = 'OnboardClock'; % The source terminal used for the sample Clock. 
                                        % For valid values see: zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    sampleRate = 5000;                  % Sample Rate in Hz
    waveform=sin(linspace(-pi,pi, sampleRate))'*5; % Build one cycle of a sine wave to play through the AO line. NOTE: column vector
    numSamplesPerChannel = length(waveform) ;   % The number of samples to be stored in the buffer per channel


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
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps',numSamplesPerChannel,sampleClockSource);


        % * Allow sample regeneration
        % When the read buffer becomes empty, the card will just return to the buffer start
        % and then repeat the same values. 
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/mxcprop/attr1453/
        hTask.set('writeRegenMode','DAQmx_Val_AllowRegen');


        % * Set the size of the output buffer
        %   More details at: "help dabs.ni.daqmx.Task.cfgOutputBuffer"
        %   C equivalent - DAQmxCfgOutputBuffer
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxcfgoutputbuffer/        
        hTask.cfgOutputBuffer(numSamplesPerChannel);


        % * Write the waveform to the buffer with a 5 second timeout in case it fails
        %   More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
        %   Writes doubles using DAQmxWriteAnalogF64
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxwriteanalogf64/
        hTask.writeAnalogData(waveform, 5)


        % * Configure the digital edge start trigger
        %   More details at: "help dabs.ni.daqmx.Task.cfgDigEdgeStartTrig"
        %   DAQmxCfgDigEdgeStartTrig
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgdigedgestarttrig/
        hTask.cfgDigEdgeStartTrig(dTriggerSource,dTriggerEdge);


        % Start the task and wait until it is complete. Task starts right away since we
        % configured no triggers
        hTask.start


        fprintf('Sine wave will play out of %s AO %d when a trigger is received on PFI1. Hit ctrl-C to stop.\n', devName, physicalChannel);
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
