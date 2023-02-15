function varargout = hardwareContinuousVoltageRampDown(devID,nonInteractive)
    % Example showing how to ramp down a regenerative signal
    %
    % function nidaqmx.AO.hardwareContinuousVoltageBasic(devID)
    %
    % Purpose
    % Shows how to do hardware-timed analog output using the DAQmx .NET interface.
    % This function plays a sine wave out of an analog output channel. The example uses the card's
    % on-board clock but uses no triggers. After the siganl begins playing,
    % the user is prompted to press return. The signal ramps down over
    % about a second to a new, lower, amplitude. The signal continues to
    % play until the user presses return a second time.
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the analog output (AO0) to
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    %
    %
    % Inputs
    % devID - optional. 'Dev1' by default.  Specifies the device to which
    %       to connect.
    % nonInteractive - does not ask for user input before next stage. Just
    %                  proceeds after a delay. false by default.
    %
    % Outputs [optional]
    % task
    %
    % Rob Campbell - SWC, 2022


    % Add the DAQmx assembly if needed then import
    nidaqmx.add_DAQmx_Assembly
    import NationalInstruments.DAQmx.*


    if nargin<1
        devID = 'Dev1';
    end

    if nargin<2
        nonInteractive = false;
    end

    if ~nidaqmx.deviceExists(devID)
        fprintf('%s does not exist\n', devId)
        return
    end



    %Define a cleanup function
    %tidyUp = onCleanup(@cleanUpFunction);

    %% Parameters for the acquisition (device and channels)
    taskName = 'hardAO';    % A string that will provide a label for the task


    % Task configuration
    sampleRate = 1E4;                  % Sample Rate in Hz

    % Build one cycle of a sine wave to play through the AO line (note the transpose)
    waveform = sin(linspace(-pi,pi, 500));%sampleRate/10))';
    numSamplesPerChannel = length(waveform) ;   % The number of samples to be stored in the buffer per channel



    % Reset the device we will use
    DaqSystem.Local.LoadDevice(devID).Reset


    % * Create a DAQmx task
    %   C equivalent - DAQmxCreateTask
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
    task = NationalInstruments.DAQmx.Task;

    % * Set up analog output 0 on device defined by variable devID
    %   C equivalent - DAQmxCreateAOVoltageChan
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaovoltagechan/
    %   AOVoltageUnits is an enum
    channelName = [devID,'/AO0'];
    task.AOChannels.CreateVoltageChannel(channelName, taskName,-10, 10, AOVoltageUnits.Volts);


    %%% The folowing line is an addition over the finite example
    task.Stream.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;


    % * Configure the sampling rate and the number of samples
    %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
    %   C equivalent - DAQmxCfgSampClkTiming
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    %   SampleQuantityMode is an enum
    task.Timing.ConfigureSampleClock('', ...
            sampleRate, ...
            SampleClockActiveEdge.Rising, ...
            SampleQuantityMode.ContinuousSamples, ... % And we set this to continuous
            numSamplesPerChannel)

    %task.AOChannels.All.UsbTransferRequestSize=2^10;

    %  * Create an instance of AnalogSingleChannelWriter
    %
    % This class contains methods for writing samples to the analog output channel in a task.
    % https://www.ni.com/docs/en-US/bundle/ni-daqmx-net-framework-40-api-ref/page/ninetdaqmxfx40ref/html/t_nationalinstruments_daqmx_analogsinglechannelwriter.htm
    taskWriter = AnalogSingleChannelWriter(task.Stream);


    % * Verify that the task parameters are valid for the hardware.
    % TaskAction isn an enum
    task.Control(TaskAction.Verify);

    %task.AOChannels.All.UsbTransferRequestCount=1; % Another option should things not work
    t.AOChannels.All.UseOnlyOnBoardMemory = 1;

    % * Write the waveform to the buffer
    %
    taskWriter.WriteMultiSample(false, waveform);

    if nargout>1
        varargout{1} = task;
        return
    end
    fprintf('Playing sine wave through AO0 %s...\n', devID)

    % * Start the task
    % You can also start the task using the Control method and the TaskAction enum:
    % task.Control(TaskAction.Start)
    % The starts right away since we configured no triggers
    task.Start;

    if nonInteractive
        pause(0.15)
    else
        input('Press return to ramp down amplitude')
    end


    for amp = 0.75:-0.1:0
        taskWriter.WriteMultiSample(false, waveform*amp);
    end



    % Block until the task is complete
    if nonInteractive
        pause(0.05)
    else
        input('Press return to stop')
    end


    task.Stop;


    % Reset the device we will use
    DaqSystem.Local.LoadDevice(devID).Reset;

    if nargout>0
        varargout{1} = task;
    end

end %hardwareFiniteVoltage

