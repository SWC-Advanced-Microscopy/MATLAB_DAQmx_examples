function hardwareContinuousVoltageBasic(devID)
    % Example showing basic hardware-timed analog output with continuous samples using DAQmx via .NET
    %
    % function nidaqmx.AO.hardwareContinuousVoltageBasic(devID)
    %
    % Purpose
    % Shows how to do hardware-timed analog output using the DAQmx .NET interface.
    % This function plays a sine wave out of an analog output channel. The example uses the card's
    % on-board clock but uses no triggers. This is very similar to nidaqmx.AO.hardwareFiniteVoltage
    % but with a couple of small changes to make the output continuous.
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the analog output (AO0) to
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    %
    % Inputs
    %   devID - [optional] 'Dev1' by default
    %
    % Rob Campbell - SWC, 2022


    % Add the DAQmx assembly if needed then import
    nidaqmx.add_DAQmx_Assembly
    import NationalInstruments.DAQmx.*


    if nargin<1
        devID = 'Dev1';
    end

    if ~nidaqmx.deviceExists(devID)
        fprintf('%s does not exist\n', devID)
        return
    end



    %% Parameters for the acquisition (device and channels)
    taskName = 'hardAO';    % A string that will provide a label for the task


    % Task configuration
    sampleRate = 1000;                  % Sample Rate in Hz

    % Build one cycle of a sine wave to play through the AO line (note the transpose)
    waveform = sin(linspace(-pi,pi, sampleRate))';
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


    %  * Create an instance of AnalogSingleChannelWriter
    %
    % This class contains methods for writing samples to the analog output channel in a task.
    % https://www.ni.com/docs/en-US/bundle/ni-daqmx-net-framework-40-api-ref/page/ninetdaqmxfx40ref/html/t_nationalinstruments_daqmx_analogsinglechannelwriter.htm
    taskWriter = AnalogSingleChannelWriter(task.Stream);


    % * Verify that the task parameters are valid for the hardware.
    % TaskAction isn an enum
    task.Control(TaskAction.Verify);


    % * Write the waveform to the buffer
    %
    taskWriter.WriteMultiSample(false, waveform);

    fprintf('Playing sine wave through AO0 %s...\n', devID)

    % * Start the task
    % You can also start the task using the Control method and the TaskAction enum:
    % task.Control(TaskAction.Start)
    % The starts right away since we configured no triggers
    task.Start;

    input('Press return to stop')


    % Block until the task is complete
    task.Stop;


    % Reset the device we will use
    DaqSystem.Local.LoadDevice(devID).Reset


end %hardwareFiniteVoltage

