function varargout = hardwareContinuousDigitalSquareWave(devID)
    % function nidaqmx.AO.hardwareContinuousDigitalSquareWave(devID)
    %
    % Purpose
    % Shows how to do hardware-timed digital outputs using the DAQmx .NET 
    % interface. This function sends out a 10 Hz square wave from P0/L0 and 
    % a 100 Hz square wave from P0/L1. The example uses the card's on-board
    % clock and regeneration but no triggers. 
    %
    %
    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the outputs to
    % an analog input and monitor this using the NI MAX test panel. 
    %
    %
    % Inputs
    %   devID - [optional] 'Dev1' by default
    %
    % Outputs [optional]
    % task - if supplied, the task does not end and instead the user gets the task
    %       object and can manually stop with task.Stop or task.Dispose
    %
    %
    % Rob Campbell - SWC, 2026


    NET.addAssembly('NationalInstruments.DAQmx');
    import NationalInstruments.DAQmx.*

    if nargin < 1
        devID = 'Dev1';
    end

    if ~nidaqmx.deviceExists(devID)
        fprintf('%s does not exist\n', devID)
        return
    end

    %% Parameters
    taskName   = 'hardDO';
    sampleRate = 1000;   % Hz (plenty of resolution for 100 Hz)
    freq1      = 10;      % 10 Hz that will be played out of P0.0
    freq2      = 100;     % 100 Hz that will be played out of P0.1

    % Choose buffer length = LCM of both periods
    samplesPerPeriod1 = sampleRate / freq1;
    samplesPerPeriod2 = sampleRate / freq2;
    numSamples = lcm(samplesPerPeriod1, samplesPerPeriod2);

    % Time vector
    t = (0:numSamples-1)';

    %% Generate square waves
    sq1 = mod(floor(2 * freq1 * t / sampleRate), 2);   % freq1 Hz
    sq2 = mod(floor(2 * freq2 * t / sampleRate), 2);   % freq2 Hz

    % Pack into port word
    portData = uint32(sq1) * bitshift(1,0) + ...
               uint32(sq2) * bitshift(1,1);


    %% Set up the hardware
    
    % Reset device
    DaqSystem.Local.LoadDevice(devID).Reset;

    % * Create a DAQmx task
    %   C equivalent - DAQmxCreateTask
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/    task = NationalInstruments.DAQmx.Task;

    %% Create port-wide digital output channel
    channelName = [devID '/port0'];
    task.DOChannels.CreateChannel( ...
        channelName, ...
        taskName, ...
        ChannelLineGrouping.OneChannelForAllLines);

    %% Allow regeneration
    task.Stream.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;

    % * Configure the sampling rate and the number of samples
    %   More details at: "help dabs.ni.daqmx.Task.cfgSampClkTiming"
    %   C equivalent - DAQmxCfgSampClkTiming
    %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
    %   SampleQuantityMode is an enum
    task.Timing.ConfigureSampleClock( ...
        '', ...
        sampleRate, ...
        SampleClockActiveEdge.Rising, ...
        SampleQuantityMode.ContinuousSamples, ...
        numSamples);

    %% Create digital writer instance
    writer = DigitalSingleChannelWriter(task.Stream);

    % * Verify that the task parameters are valid for the hardware.
    % TaskAction in an enum
    task.Control(TaskAction.Verify);

    %% Write waveform
    writer.WriteMultiSamplePort(false, portData);

    fprintf('Playing 10 Hz on P0.0 and 100 Hz on P0.1 using %s\n', channelName);

    
    %% Start task
    task.Start;

    if nargout > 0
        varargout{1} = task;
    else
        input('Press return to stop');
        task.Stop;
        task.Dispose;
    end

end
