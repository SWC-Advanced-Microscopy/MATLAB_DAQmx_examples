function hardwareContinuousVoltageNoRegen
    % Example showing hardware-timed continuous analog output without regeneration using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.hardwareContinuousVoltageNoRegen
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog output using Vidrio's dabs.ni.daqmx wrapper. 
    % This function ouputs a continuous sine wave out of an analog output channel using the DAQ's 
    % internal (on-board) sample clock. The example uses no triggers. The waveform data is written to the
    % buffer at intervals using a callback funtion. In other words, there is no "regeneration". 
    % If regeneration were enabled, data written to either the user buffer or the FIFO would be reused by 
    % the DAQ device to produce the waveform.
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
    % Same but with two channels: vidrio.AO.hardwareContinuousVoltageNoRegen_2chans
    % Same but with a digital trigger: vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig
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
    sampleRate = 500;                  % Sample Rate in Hz
    waveform=sin(linspace(-pi,pi, sampleRate*2))'*5; % Build one cycle of a sine wave to play through the AO line. NOTE: column vector
    numSamplesPerChannel = length(waveform) ;   % The number of samples to be stored in the buffer per channel
    bufferSize = numSamplesPerChannel * 2;
    fprintf('Waveform length: %d\nSample rate: %d\nBuffer size: %d\n', ....
        numSamplesPerChannel, sampleRate, bufferSize)

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


        % * Disable sample regeneration
        %  When regeneration is enabled, data written to either the user buffer or the FIFO is reused by the 
        % DAQ device to produce the waveform. 
        % https://knowledge.ni.com/KnowledgeArticleDetails?id=kA00Z0000019P1kSAE&l=en-GB 
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/mxcprop/attr1453/
        % For more on DAQmx write properties: http://zone.ni.com/reference/en-XX/help/370469AG-01/daqmxprop/daqmxwrite/
        hTask.set('writeRegenMode','DAQmx_Val_DoNotAllowRegen');


        % * Configure the sampling rate and the number of samples
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        %
        % Note that in the following line the number of samples per channel does not determine 
        % the buffer size for an output operation but is the total number of samples to generate.
        % See: http://zone.ni.com/reference/en-XX/help/370466AD-01/mxcncpts/buffersize/
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps',numSamplesPerChannel,sampleClockSource);

        % * Set the size of the output buffer
        %   More details at: "help dabs.ni.daqmx.Task.cfgOutputBuffer"
        %   C equivalent - DAQmxCfgOutputBuffer
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxcfgoutputbuffer/
        hTask.cfgOutputBuffer(bufferSize);


        % * Call an anonymous function function to top up the buffer when half of the samples
        %   have been played out. Also see: basicConcepts/anonymousFunctionExample.
        %   More details at: "help dabs.ni.daqmx.Task.registerEveryNSamplesEvent"
        %   This is conceptually similar to the notifier "NotifyWhenScansQueuedBelow" and
        %   the associated listener in daqtoolbox.AO.analogOutput_Continuous
        %hTask.registerEveryNSamplesEvent(@(src,~) src.writeAnalogData(waveform,5), floor(numSamplesPerChannel*0.5));
        hTask.registerEveryNSamplesEvent(@topUpBuffer, 125);



        % * Write the waveform to the buffer with a 1 second timeout in case it fails
        %   More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
        %   Writes doubles using DAQmxWriteAnalogF64
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxwriteanalogf64/
        hTask.writeAnalogData(waveform, 1)


        % Start the task and wait until it is complete. Task starts right away
        % since we configured no triggers
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

    function topUpBuffer(src,~)
        disp('**TOPPING UP THE BUFFER**')
        src.writeAnalogData(waveform, 5)
    end

end %close hardwareContinuousVoltage
