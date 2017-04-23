function softwareTimedVoltage
    % Example showing software timed analog output using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AO.softwareTimedVoltage
    %
    %
    % Purpose
    % Demonstrates how to do software-timed analog output ("on demand" output) using 
    % Vidrio's dabs.ni.daqmx wrapper. This example outputs multiple analog output
    % voltage samples to a single analog output channel in a software-timed loop.
    %
    % 
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Create an Analog Output voltage channel.
    %    3. Create a vector comprising a single cycle of a sinewave with 100 points
    %    4. Call the Start function.
    %    5. Write one data point from the vector at a time every 10 ms until the 
    %       user hits ctrl-c or an error occurs. 
    %    6. Set AO to zero and clear the task.
    %    7. Display an error if any.
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the analog output to 
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    % 
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % Vidrio example: dabs.ni.daqmx.demos.AnalogInput.Voltage_Software_Timed_Input 
    % PyDAQmx example: https://pythonhosted.org/PyDAQmx/examples/analog_output.html
    % ANSI C: DAQmx_ANSI_C_examples/AO/MultVoltUpdates-SWTimed.c


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);


    %% Parameters for the acquisition
    devName = 'Dev1';       % The name of the DAQ device as shown in MAX
    taskName = 'softAO';    % A string that will provide a label for the task
    physicalChannel = 0;    % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum


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

        sineWave = sin(linspace(-pi,pi, 100));
        fprintf('Playing sine wave out of %s AO %d. Hit ctrl-C to stop.\n', devName, physicalChannel);

        % Output continues for as long as the following while loop runs
        n=1;
        while 1
            % More details at: "help dabs.ni.daqmx.Task.writeAnalogData"
            hTask.writeAnalogData(sineWave(n)); % Immediately outputs voltage value
            pause(0.01) % <- There will be software jitter
            n=n+1;
            if n==length(sineWave)
                hTask.isTaskDone; % Checks for errors
                n=1;
            end
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
            hTask.writeAnalogData(0); %Set channel to 0 V
            DAQmxClearTask
            hTask.stop;    % Calls DAQmxStopTask
            delete(hTask); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
        else
            fprintf('No task variable present for clean up\n')
        end
    end %close cleanUpFunction

end %softwareTimedVoltage

