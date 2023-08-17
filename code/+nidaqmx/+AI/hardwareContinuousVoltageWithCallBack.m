function hardwareContinuousVoltageWithCallBack(devID)
    % A simple example showing hardware-timed continuous analog input using using DAQmx via .NET
    %
    % function nidaqmx.AI.hardwareContinuousVoltageWithCallBack(devID)
    %
    % Purpose
    % Demonstrates how to do hardware-timed continuous analog input using DAQmx via .NET.
    % This function continuously acquires data from multiple channels and plots the results to screen as
    % the data come in. Plotting is achieved using a callback function. The example uses the
    % card's on-board clock but uses no triggers.
    %
    %
    % Inputs
    %   devID - [optional] 'Dev1' by default
    %
    % Rob Campbell - SWC, 2023

    % Add the DAQmx assembly if needed then import
    NET.addAssembly('NationalInstruments.DAQmx');
    import NationalInstruments.DAQmx.*

    if nargin<1
        devID = 'Dev1';
    end

    if ~nidaqmx.deviceExists(devID)
        fprintf('%s does not exist\n', devID)
        return
    end

    % Parameters for the acquisition (device and channels)
    minVoltage = -5;       % Channel input range minimum
    maxVoltage = 5;        % Channel input range maximum


    % Task configuration
    sampleRate = 10E3;                  % Sample Rate in Hz
    numSamplesToPlot = 4000 ;            % Read off this many samples each time to plot
    bufferSize_numSamplesPerChannel = 80*numSamplesToPlot; % The number of samples to be stored in the buffer per channel.


    % Reset the device we will use
    DaqSystem.Local.LoadDevice(devID).Reset

    % * Create a DAQmx task
    %   C equivalent - DAQmxCreateTask
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
    task = NationalInstruments.DAQmx.Task();


    % * Set up analog inputs on device defined by variable devID
    %   More details at: "help dabs.ni.daqmx.Task.createAIVoltageChan"
    %   C equivalent - DAQmxCreateAIVoltageChan
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaivoltagechan/
    channelName = [devID,'/AI0:1'];
    task.AIChannels.CreateVoltageChannel(channelName, '',  AITerminalConfiguration.Differential, ...
                                        minVoltage, maxVoltage, AIVoltageUnits.Volts);


    % * Configure the sampling rate and the number of samples
    %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
    %   C equivalent - DAQmxCfgSampClkTiming
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    %   SampleQuantityMode is an enum
    task.Timing.ConfigureSampleClock('', ...
            sampleRate, ...
            SampleClockActiveEdge.Rising, ...
            SampleQuantityMode.ContinuousSamples, ... % And we set this to continuous
            bufferSize_numSamplesPerChannel)



    AIreader = AnalogUnscaledReader(task.Stream);
    task.EveryNSamplesReadEventInterval = numSamplesToPlot;
    task.Control(TaskAction.Verify);

    AIlistener = addlistener(task, 'EveryNSamplesRead', @readAndPlotData);


    % Open a figure window and have it shut off the acquisition when closed
    % See: basicConcepts/windowCloseFunction.m
    fig=clf;
    set(fig,'CloseRequestFcn', @windowCloseFcn, ...
        'Name', 'Close figure window to stop acquisition')
    P{1} = plot(1:numSamplesToPlot,'Color','r');
    hold on
    P{2} = plot(1:numSamplesToPlot,'Color','k');
    hold off
    % Start the task and wait until it is complete. Task starts right away since we
    % configured no triggers
    task.Start

   fprintf('Recording data on %s. Close window to stop.\n', devID);



    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    function windowCloseFcn(~,~)
        %This runs when the user closes the figure window or if there is an error
        if exist('task','var')
            fprintf('Cleaning up DAQ task\n');
            task.Stop;    % Calls DAQmxStopTask
            task.Dispose
            delete(task); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
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

        data = AIreader.ReadInt16(numSamplesToPlot).int16;

        if isempty(data)
            fprintf('Input buffer is empty\n' );
        else
            P{1}.YData(1,:) = data(1,:);
            P{2}.YData(1,:) = data(2,:);
            drawnow
        end

    end %readAndPlotData

end %close hardwareContinuousVoltage


