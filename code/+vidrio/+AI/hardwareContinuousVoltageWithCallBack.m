function hardwareContinuousVoltageWithCallBack
    % A simple example showing hardware-timed continuous analog input using the Vidrio dabs.ni.daqmx wrapper
    %
    % function vidrio.AI.hardwareContinuousVoltageWithCallBack
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog input using Vidrio's dabs.ni.daqmx wrapper. 
    % This function continuously acquires data from multiple channels and plots the results to screen as
    % the data come in. Plotting is achieved using a callback function. The example uses the card's on-board clock but uses no triggers. 
    %
    %
    % Demonstrated steps:
    %    1. Create a task.
    %    2. Create multiple Analog Input voltage channels.
    %    3. Set the sample rate, define the sample mode to be continuous.
    %    4. Set up a figure that will stop the acquisition when closed then call the Start function.
    %    5. Read in the data continuously using a callback function and plot to screen.
    %    6. Clear the task.
    %    7. Display an error if any.
    %
    %
    % Rob Campbell - Basel, 2017
    %
    % 
    % Also see:
    % TMW DAQ Toolbox example: daqtoolbox.AI.analogInput_Continuous
    % ANSI C: DAQmx_ANSI_C_examples/AI/ContAcq-IntClk.c 
    % vidrio.AI.hardwareContinuousVoltage (without a callback function)


    % Parameters for the acquisition (device and channels)
    devName = 'Dev1';       % the name of the DAQ device as shown in MAX
    taskName = 'hardAI';    % A string that will provide a label for the task
    physicalChannels = 0:3; % A scalar or an array with the channel numbers
    minVoltage = -0.5;       % Channel input range minimum
    maxVoltage = 0.5;        % Channel input range maximum


    % Task configuration
    sampleRate = 10E3;                  % Sample Rate in Hz
    numSamplesToPlot = 1000 ;            % Read off this many samples each time to plot
    bufferSize_numSamplesPerChannel = 40*numSamplesToPlot; % The number of samples to be stored in the buffer per channel. 


    try
        % * Create a DAQmx task
        %   More details at: "help dabs.ni.daqmx.Task"
        %   C equivalent - DAQmxCreateTask 
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task(taskName); 


        % * Set up analog inputs on device defined by variable devName
        %   More details at: "help dabs.ni.daqmx.Task.createAIVoltageChan"
        %   C equivalent - DAQmxCreateAIVoltageChan
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaivoltagechan/
        hTask.createAIVoltageChan(devName, physicalChannels, [], minVoltage, maxVoltage);


        % * Configure the sampling rate and the size of the buffer in samples using the on-board sanple clock
        %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
        %   C equivalent - DAQmxCfgSampClkTiming
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        hTask.cfgSampClkTiming(sampleRate, 'DAQmx_Val_ContSamps', bufferSize_numSamplesPerChannel, 'OnboardClock');


        % * Set up a callback function to regularly read the buffer and plot the data.
        %   More details at: "help dabs.ni.daqmx.Task.registerEveryNSamplesEvent"
        hTask.registerEveryNSamplesEvent(@readAndPlotData, numSamplesToPlot, 1, 'Scaled');


        % Open a figure window and have it shut off the acquisition when closed
        % See: basicConcepts/windowCloseFunction.m
        fig=clf;
        set(fig,'CloseRequestFcn', @windowCloseFcn, ...
            'Name', 'Close figure window to stop acquisition')


        % Start the task and wait until it is complete. Task starts right away since we
        % configured no triggers
        hTask.start


       fprintf('Recording data on %s. Close window to stop.\n', devName);
    


    catch ME
       daqDemosHelpers.errorDisplay(ME)
       windowCloseFcn([]) %Closes any open figure windows and disconnects from the DAQ
    end %try/catch





    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    function windowCloseFcn(~,~)
        %This runs when the user closes the figure window or if there is an error
        if exist('hTask','var')
            fprintf('Cleaning up DAQ task\n');
            hTask.stop;    % Calls DAQmxStopTask
            delete(hTask); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
        else
            fprintf('No task variable present for clean up\n')
        end

        if exist('fig','var') %In case this is called in the catch block
            delete(fig)            
        end
    end %close windowCloseFcn



    function readAndPlotData(src,evt)
        % This callback function runs each time a pre-defined number of points have been collected
        % This is defined at the hTask.registerEveryNSamplesEvent method call.
        hTask = src;
        data = evt.data;

        errorMessage = evt.errorMessage;

        % check for errors and close the task if any occur. 
        if ~isempty(errorMessage)
            delete(hTask);
            error(errorMessage);
        else
            if isempty(data)
                fprintf('Input buffer is empty\n' );
            else
                plot(data)
            end
        end

    end %readAndPlotData

end %close hardwareContinuousVoltage


