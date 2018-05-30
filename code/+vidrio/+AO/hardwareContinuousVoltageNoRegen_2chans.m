function hardwareContinuousVoltageNoRegen_2chans
    % Example showing hardware-timed continuous analog output without regeneration using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.hardwareContinuousVoltageNoRegen_2chans
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog output using two channels with Vidrio's 
    % dabs.ni.daqmx wrapper. This function ouputs continuous sine waves out of AO0 and AO1 using the DAQ's 
    % internal (on-board) sample clock. The example uses no triggers. The waveforms are not regenerated 
    % continuously from a callback function. 
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the analog output to 
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    %
    % Demonstrated steps:
    %    1. Create a vector comprising a single cycle of a sinewave which will play at 1 Hz.
    %    2. Create a task.
    %    3. Create an Analog Output voltage channel.
    %    4. Define the update rate for the voltage generation. Additionally, define 
    %       the sample mode to be continuous and set the size of the output buffer to be equal 
    %       to the length of waveform we will be playing out.
    %    5  Write the waveform to the buffer. 
    %    6. Call the Start function.
    %    7. Continuously play the waveform until the user hits ctrl-c or an error occurs.
    %    8. Clear the task
    %    9. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % TMW DAQ Toolbox example: *Is non-regenerative AO possible with TMW toolbox*?
    % Vidrio example: dabs.ni.daqmx.demos.AnalogOutput.Voltage_Continuous_Output
    % Same but with one channel: vidrio.AO.hardwareContinuousVoltageNoRegen
    % Same but with a digital trigger: vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig
    % Restrictions on AO tasks: http://digital.ni.com/public.nsf/allkb/2C45C3DC484FF730862570E7007CCBD4?OpenDocument

    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    % Parameters for the acquisition (device and channels)
    devName = 'maitai';     % The name of the DAQ device as shown in MAX
    taskName = 'hardAO';    % A string that will provide a label for the task
    physicalChannel = 0:1;  % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum


    % Task configuration
    sampleClockSource = 'OnboardClock'; % The source terminal used for the sample Clock. 
                                        % For valid values see: zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    sampleRate = 5000;                  % Sample Rate in Hz

    %Build two waveforms to play out of channels 0 and 1. Note that each is a column vector 
    waveform0=sin(linspace(-pi*25,pi*25, sampleRate))'*5; % Build 25 cycles of a sine wave to play through the AO0 line.
    waveform1=sin(linspace(-pi,pi, sampleRate))'*5; % Build one cycle of a sine wave to play through the AO1 line.

    
    % Assemble the two waveforms into an N-by-2 array
    waveforms = [waveform0,waveform1];

    numSamplesPerChannel = size(waveforms,1) ; % The number of samples to be stored in the buffer per channel

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
        % For more on DAQmx write properties: http://zone.ni.com/reference/en-XX/help/370469AG-01/daqmxprop/daqmxwrite/
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
        hTask.writeAnalogData(waveforms, 5)


        % Start the task and wait until it is complete. Task starts right away
        % since we configured no triggers
        hTask.start


        fprintf('Playing sine waves out of %s AO%d and AO%d. Hit ctrl-C to stop.\n', devName, physicalChannel);
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
