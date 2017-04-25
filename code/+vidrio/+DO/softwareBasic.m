function softwareBasic
    % Example showing software-timed (on demand) digital output using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.DO.softwareBasic
    %
    % Purpose
    % Shows how to flip digital lines on demand using Vidrio's dabs.ni.daqmx wrapper. 
    % Note that on many DAQ cards the digital lines are not "buffered". For more info see:
    % http://digital.ni.com/public.nsf/allkb/51754212AD10BDCE862573BD007BFDD2
    %
    %
    % Demonstrated steps:
    %    1. Create three tasks.
    %    2. Create DO channels in three different ways to show all the available options.
    %    3. Write digital values on at a time to these lines. 
    %    4. Clear the task
    %    5. Display an error if any.
    %
    % Rob Campbell - Basel, 2017
    %
    % Also see:
    % ANSI C: DAQmx_ANSI_C_examples/DO/WriteDigChan.c


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);

    devName = 'Dev1';

    try

        % * Create two DAQmx tasks: One task has one line and the other has multiple lines
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hDO = dabs.ni.daqmx.Task.empty();
        hDO(1) = dabs.ni.daqmx.Task('DOtask_single');
        hDO(2) = dabs.ni.daqmx.Task('DOtask_multi');
        hDO(3) = dabs.ni.daqmx.Task('DOtask_port');

        % * Define digital output channels on these tasks
        %   More details at: "help dabs.ni.daqmx.Task.createDOChan"
        %   C equivalent - DAQmxCreateDOChan
        %   http://zone.ni.com/reference/en-XX/help/370471AC-01/daqmxcfunc/daqmxcreatedochan/
        hDO(1).createDOChan(devName,'port0/line0'); %Open one digital line

        % We will be able  to address these two lines with a row vector, where 
        % each column in the vector corresponds to a different physical channel. 
        hDO(2).createDOChan(devName,'port0/line1'); %Open multiple digital lines
        hDO(2).createDOChan(devName,'port0/line2'); %Open multiple digital lines

        % We now create three physical lines under the same logical channel.
        hDO(3).createDOChan(devName,'port0/line3:5');


        % * Write to the DO lines
        %   More details at: "help dabs.ni.daqmx.Task.writeDigitalData"
        %   This is a wrapper for the DAQmx digital write functions of which 
        %   there are five in total: http://zone.ni.com/reference/en-XX/help/370471AC-01/TOC22.htm


        % Set only port0/line0 on DOtask_single high then flip it back down
        hDO(1).writeDigitalData(1);
        pause(1)    
        hDO(1).writeDigitalData(0);


        % Set all lines on task DOtask_multi high:
        hDO(2).writeDigitalData([1,1]);
        pause(1)

        % Then switch them low one at a time:
        hDO(2).writeDigitalData([0,1]); %Note this is a row vector
        pause(0.5)
        hDO(2).writeDigitalData([0,0]);


        % Set the middle line (P0/L4) high
        % Unlike the previous task we here use a row vector. This is because
        % we are writing all samples to a single logical channel. In hDO(2)
        % it was two logical channels. 
        % NOTE: it's also possible to supply this input as binary notation, but this appears to require a running taskk
        hDO(3).writeDigitalData([0;1;0]);
        pause(1)
        hDO(3).writeDigitalData([0;0;0] );


    catch ME
       daqDemosHelpers.errorDisplay(ME)
       return

    end %try/catch



    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    function cleanUpFunction
        %This runs when the function ends
        if exist('hDO','var')
            fprintf('Cleaning up DAQ task\n');
            delete(hDO); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
        else
            fprintf('No task variable present for clean up\n')
        end
    end %close cleanUpFunction



end %vidrio.DO.softwareBasic
