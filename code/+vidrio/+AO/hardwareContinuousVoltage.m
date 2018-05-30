function hardwareContinuousVoltage
    % Example showing hardware-timed continuous analog output using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.hardwareContinuousVoltage
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog output using Vidrio's dabs.ni.daqmx wrapper. 
    % This function ouputs a continuous sine wave out of an analog output channel using the DAQ's 
    % internal (on-board) sample clock. The example uses no triggers. The waveform is regenerated 
    % continuously using a callback function.
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
    %       the sample mode to be continuous, do not allow sample regeneration, and 
    %       set the size of the output buffer to be equal to the length of waveform we
    %       will be playing out.
    %    5  Write the waveform to the buffer. 
    %    6. Set up an anonymous function to regenerate the waveform before the buffer empties.
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


        % * Do not allow sample regeneration
        % When the read buffer becomes empty, the card will not return to the start
        % and re-output the same values. 
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/mxcprop/attr1453/
        % For more on DAQmx write properties: http://zone.ni.com/reference/en-XX/help/370469AG-01/daqmxprop/daqmxwrite/
        hTask.set('writeRegenMode','DAQmx_Val_DoNotAllowRegen');


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


        % * Call an anonymous function function to top up the buffer when half of the samples
        %   have been played out. Also see: basicConcepts/anonymousFunctionExample.
        %   More details at: "help dabs.ni.daqmx.Task.registerEveryNSamplesEvent"
        %   This is conceptually similar to the notifier "NotifyWhenScansQueuedBelow" and
        %   the associated listener in daqtoolbox.AO.analogOutput_Continuous
        hTask.registerEveryNSamplesEvent(@(src,~) src.writeAnalogData(waveform,5), floor(numSamplesPerChannel/2));


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
