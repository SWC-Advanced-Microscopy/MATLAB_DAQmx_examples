function AO_retriggerable
    % Example showing analog output of a finite number of samples, repeatedly triggered by an external TTL signal using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.mixed.AO_retriggerable
    %
    % Purpose
    % Shows how to repeatedly trigger an analog waveform using an incoming
    % TTL signal. This can be used to synchronize devices on multiple
    % devices, or on timescales that cannot be achieved by software
    % (microsecond domain)
    %
    % Specific use cases:
    %
    % 1) For scanned light-sheet microscopy, one ideally wants to
    % synchronize the scanning with the camera. Use the camera out TTL
    % signal to trigger a waveform for scanning for each frame.
    %
    % 2) A resonant scanner gives a TTL signal of slightly changing
    % frequency. To synchronize the microscope acquisition and scanning
    % with the resonant scanner, one needs to trigger several tasks
    % (pockels cell, galvo, frame acquisition, line acquisition) by the
    % resonant scanner, therefore requiring a retriggerable task.
    %
    %
    % IMPORTANT NOTE
    % Retriggerable tasks only work with X-Series DAQ boards by NI, e.g. NI
    % PCIe-6321 or USB-6343.
    %    
    %
    % Demonstrated steps:
    %    1. Create a vector comprising a single cycle of a sawtooth waveform of 
    %       1 s duration that will played every time a trigger comes in.
    %    2. Create a task.
    %    3. Create an Analog Output voltage channel.
    %    4. Define the update (sample) rate for the voltage generation.
    %    5. Define external trigger source and set the task to be re-triggerable
    %    6  Write the waveform to the buffer. 
    %    7. Call the Start function and wait until generation is complete.
    %    8. Clear the task
    %    9. Display an error if any.
    %
    %
    % Wiring:
    % * Your device, devName, will need to be an X-series NI DAQ. 
    % * Feed AO 0 to an osciloscope.
    % * Connect PFI0 of devName to a digital trigger. e.g. Port0/Line0 on devName.
    % * Start MAX and enter the digital test panel for the device to be producing the
    %   triggers. 
    % * Run this function.
    % * The waveform is produced each time a positive-going TTL pulse is delivered to
    %   PFI0. 
    %
    %
    % Peter Rupprecht - Basel, 2017



    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'retrigAO';  % A string that will provide a label for the task
    physicalChannel = 0;    % A scalar or an array with the channel numbers
    triggerChannel = 0;     % A scalar defining the trigger channel (e.g. If this is zero, the trigger line is PFI0)
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum
    
    % Task configuration
    sampleRate = 5000;  
    
    amplitude = 1;

    sawtooth = linspace(-amplitude,amplitude, 2500)';
    sawtooth = [sawtooth; flipud(sawtooth)];
    numSamplesPerChannel = length(sawtooth);

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
        hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_FiniteSamps',numSamplesPerChannel);


        % * Set the size of the output buffer
        %   More details at: "help dabs.ni.daqmx.Task.cfgOutputBuffer"
        %   C equivalent - DAQmxCfgOutputBuffer
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxcfgoutputbuffer/        
        hTask.cfgOutputBuffer(numSamplesPerChannel);

        % * Define the channel of the trigger source
        %   Set task as retriggerable       
        hTask.cfgDigEdgeStartTrig(sprintf('PFI%d',triggerChannel),'DAQmx_Val_Rising');
        hTask.set('startTrigRetriggerable',1);
        
        % * Write the waveform to the buffer with a 5 second timeout in case it fails
        %   More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
        %   Writes doubles using DAQmxWriteAnalogF64
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxwriteanalogf64/
        hTask.writeAnalogData(sawtooth,false); % false = no autostart


        % Start the task and wait until it is complete. Task starts and
        % will wait for triggers until it is stopped
        hTask.start();

        fprintf('Waiting for triggers (ctrl-c to stop) ...\n')
        while 1
            pause(0.5)
        end
        hTask.stop();
        
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


end %AO_retriggerable

