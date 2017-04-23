function softwareTimedVoltage
    % Example showing software-timed analog input using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AI.softwareTimedVoltage
    %
    % Purpose
    % Describes how to do software-timed analog input using Vidrio's dabs.ni.daqmx wrapper
    % This is unbuffered or "on demand" acquisition. 
    %
    %
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Create an Analog Input voltage channel.
    %    3. Read individual analog points a fixed number of times from a single channel
    %       and plot points to screen as we progress. 
    %    4. Clear the task
    %    5. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % dabs.ni.daqmx.demos.AnalogInput.Voltage_Software_Timed_Input 


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition
    devName = 'Dev1';       % The name of the DAQ device as shown in MAX
    taskName = 'softAI';    % A string that will provide a label for the task
    physicalChannel = 0;   % A scalar or an array with the channel numbers
    minVoltage = -10;       % Channel input range minimum
    maxVoltage = 10;        % Channel input range maximum


    try 
        % * Create a DAQmx task
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task(taskName); 


        % * Set up analog input 0 on device defined by variable devName
        %   More details at: "help dabs.ni.daqmx.Task.createAIVoltageChan"
        %   It's is also valid to use device and channel only: e.g. "hTask.createAIVoltageChan(‘Dev1’,0);"
        %   C equivalent - DAQmxCreateAIVoltageChan
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaivoltagechan/
        hTask.createAIVoltageChan(devName, physicalChannel, [], minVoltage, maxVoltage);



        % Read periodically using software timing via the pause command and plot data as they come in. 
        clf
        hold on
        samplesToAcquire=250;
        xlim([0,samplesToAcquire])
        ylim([minVoltage,maxVoltage])
        xlabel('Samples')
        ylabel('Voltage')
        grid on
        for ii=1:samplesToAcquire

            % Read all available samples using default options
            % More details at: "help dabs.ni.daqmx.Task.readAnalogOutput"
            dataPoint=hTask.readAnalogData;

            %Plot it
            plot(ii,dataPoint,'.k')
            drawnow
            pause(0.01)  % <- There will be software jitter
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



end %vidrio.AI.softwareTimedVoltage

