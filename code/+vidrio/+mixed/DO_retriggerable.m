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
    % Retriggerable tasks only work with X-Series DAQ boards such as
    % PCIe-6321 or USB-6343. This task uses a counter and only a few counters
    % are available per board (typically four for more recent NI DAQ devices).
    %
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
    % Peter Rupprecht - Basel, 2017
    %
    % Also see:
    % vidrio.CO.singlePulse - setting up a single pulse with a counter
    % vidrio.mixed.AO_retriggerable

    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition (device and channels)
    devName = 'beam';       % the name of the DAQ device as shown in MAX
    taskName = 'retrigDO';    % A string that will provide a label for the task
    counterID=0;       % The ID of the counter to use

    physicalChannel = 1;      % A scalar defining the output on which the pulses are delivered
    triggerChannel = 'PFI0';  % A string defining the PFI channel on which triggers come

    % Task configuration
    frequency = 3; % Hz
    dutyCycle = 0.25;
    
    try
        % * Create a DAQmx task
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task(taskName);

        % * Set up a channel to generate digital pulses and define the pulse properties
        %   More details at: "help dabs.ni.daqmx.Task.createCOPulseChanFreq"
        %   C equivalent - DAQmxCreateCOPulseChanFreq
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatecopulsechanfreq/
        hTask.createCOPulseChanFreq(devName, counterID, [], frequency, dutyCycle);
        
        % Set the pulses to come out of PFI4
        % TODO: is this the best way of setting this property? Where is this documented?
        hTask.channels(1).set('pulseTerm','PFI4');

        % * Alternatively define delay and duration of pulses manually
         %set(hTask.channels(1),'pulseTimeInitialDelay',3e-8);
         %set(hTask.channels(1),'pulseLowTime',3e-8);
         %set(hTask.channels(1),'pulseHighTime',40e-6); 
        
        
        % * Define the channel of the trigger source
        %   Set task as retriggerable
        hTask.cfgDigEdgeStartTrig(triggerChannel,'DAQmx_Val_Rising');
        hTask.set('startTrigRetriggerable',1); 
        
        % Start the task and wait until it is complete. Task starts and
        % will wait for triggers until it is stopped
        hTask.start();

        fprintf('Waiting for triggers (ctrl-c to stop) ...\n')
        while 1
            pause(0.5)
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


end %DO_retriggerable

