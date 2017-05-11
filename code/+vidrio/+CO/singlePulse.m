function singlePulse
    % Example showing how to create a single pulse on a digital output channel with a timer using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.CO.singlePulse
    %
    % Purpose
    % Shows how to flip a single digital line high for a brief period after a fixed delay
    % with a counter using the dabs.ni.daqmx wrapper. 
    %
    %
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Set up a counter to deliver the pulse with the desired properties.
    %    3. Assign an output channel out of which the pulse is played.
    %    4. Start the task and wait until it is complete. 
    %    5. Clear the task
    %    6. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % DAQmx_ANSI_C_examples/CO/DigPulse.c



    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    % Parameters for the pulse generation
    devName = 'Dev1';  % The name of the DAQ device as shown in MAX
    counterID=0;       % The ID of the counter to use
    lowTime = 0.25;    % How long the pulse stays low (TODO: I think this is after the pulse ends)
    highTime=0.25;     % How long the pulse is stay high
    initialDelay=2;    % How long to wait before generating the first pulse (seconds)

    try
        % * Create a DAQmx task called 'example_clk_task'
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task('clk_task');


        % * Set up a channel to generate digital pulses and define the pulse properties (onset, duration, )
        %   More details at: "help dabs.ni.daqmx.Task.createCOPulseChanTime"
        %   C equivalent - DAQmxCreateCOPulseChanTime
        %   http://zone.ni.com/reference/en-XX/help/370471AG-01/daqmxcfunc/daqmxcreatecopulsechantime/
        hTask.createCOPulseChanTime(devName, counterID, '', lowTime, highTime, initialDelay, 'DAQmx_Val_Low');


        % Set the pulses to come out of PFI4
        % TODO: is this the best way of setting this property? Where is this documented?
        hTask.channels(1).set('pulseTerm','PFI4');


        % Start the task and wait until it is complete. Task starts right away
        % since we configured no triggers
        hTask.start
        hTask.waitUntilTaskDone(initialDelay+highTime+lowTime+1)

    catch ME
       daqDemosHelpers.errorDisplay(ME)
       return

    end %try/catch



    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    function cleanUpFunction
        %This runs when the function ends
        if exist('hTask','var')
            fprintf('Cleaning up DAQ task\n');
            hTask.stop;
            delete(hTask); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
        else
            fprintf('No task variable present for clean up\n')
        end
    end %close cleanUpFunction

end %vidrio.CO.singlePulse
