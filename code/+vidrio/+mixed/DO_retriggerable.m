function DO_retriggerable
    % Example showing TTL output, repeatedly triggered by an external TTL signal using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.mixed.DO_retriggerable
    %
    % Purpose
    % Shows how to repeatedly trigger a TTL signal with adjustable delay and duration
    % using an incoming TTL signal. This can be used to synchronize devices on multiple
    % devices, or on timescales that cannot be achieved by software (microsecond domain)
    %
    %
    % IMPORTANT NOTE
    % Retriggerable tasks only work with X-Series DAQ boards by NI, e.g. NI
    % DAQ 6321. This task uses a counter of the board. Only few counters
    % are available per board (typically four).
    
    %
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Create an counter channel for TTL output.
    %    3. Define external trigger source.
    %    4. Call the Start function and wait for triggers.
    %    5. Clear the task
    %    6. Display an error if any.
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the counter output to 
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    %
    %
    % Rob Campbell, Peter Rupprecht - Basel, 2017
    %


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'retrigDO';    % A string that will provide a label for the task
    physicalChannel = 0;    % A scalar or an array with the channel numbers
    triggerChannel = 1;    % A scalar or an array with the channel numbers

    % Task configuration
    frequency = 30; % Hz
    dutyCycle = 0.25;
    
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
        hTask.createCOPulseChanFreq(devName, physicalChannel,[], frequency, dutyCycle)
        
        % * Alternatively define delay and duration of pulses manually
        % set(hTask.channels(1),'pulseTimeInitialDelay',3e-8);
        % set(hTask.channels(1),'pulseLowTime',3e-8);
        % set(hTask.channels(1),'pulseHighTime',40e-6); 
        
        
        % * Define the channel of the trigger source
        %   Set task as retriggerable
        hTask.cfgDigEdgeStartTrig(sprintf('PFI%d',triggerChannel),'DAQmx_Val_Rising');
        hTask.set('startTrigRetriggerable',1); 
        
        % Start the task and wait until it is complete. Task starts and
        % will wait for triggers until it is stopped
        hTask.start();

        fprintf('Waiting for triggers ...\n')
        pause(10);
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


end %DO_retriggerable

