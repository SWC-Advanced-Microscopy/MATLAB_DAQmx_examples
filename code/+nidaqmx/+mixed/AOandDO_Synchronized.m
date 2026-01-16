function AOandDO_Synchronized
% Demonstration of simultaneous analog output and digital output with DAQmx .NET
%
% function vidrio.mixed.AOandDO_Synchronized
%
% Description:
%    This example demonstrates how to continuously run analog signal generation (AO)
%    and hardware-timed digital signal generation (DO) at the same time and have the
%    tasks synchronized with one another. The analog output task is the master and
%    triggers the digital output task using the internal AO Start Trigger.
%
%    The AO task outputs a 10 Hz sine wave on AO0 with an amplitude of +/-2.5 V.
%    The DO task outputs:
%        - 10 Hz square wave on P0.0
%        - 100 Hz square wave on P0.1
%
%    Both tasks are hardware timed using the onboard clocks and use regeneration.
%
%    Note that a single DAQmx task can support only one type of channel:
%    http://digital.ni.com/public.nsf/allkb/4D2E6ABCF652542186256F04004FDAC3
%    So we need to make one task for AO and one for DO, and start them synchronously
%    with an internal trigger.
%
% Demonstrated steps:
%    1. Create the AO and DO tasks and waveforms.
%    2. Create an analog output voltage channel.
%    3. Create a digital output port channel.
%    4a. Set up the AO task:
%        i)   Configure the sample clock.
%        ii)  Define the sample mode as continuous.
%        iii) Allow regeneration.
%        iv)  Write waveform data to the output buffer.
%    4b. Set up the DO task:
%        i)   Configure the sample clock and have it be the AO clock
%        ii)  Define the sample mode as continuous.
%        iii) Allow regeneration.
%        iv)  Write digital pattern to the output buffer.
%        v)   Configure the DO task to start when the AO task starts.
%    5. Arm the DO task.
%    6. Start the AO task (which triggers the DO task).
%    7. Run continuously until the user stops the task.
%
% Also see:
% ANSI C: DAQmx_ANSI_C_examples/SynchAI-AO.c
% Digital Output Fundamentals:
% https://www.ni.com/docs/en-US/bundle/ni-daqmx/page/digital_output.html
%
% Rob Campbell -- SWC 2026


    %% Load DAQmx .NET assembly
    NET.addAssembly('NationalInstruments.DAQmx');
    import NationalInstruments.DAQmx.*

    DAQdevice = 'Dev1';

    if ~nidaqmx.deviceExists(DAQdevice)
        fprintf('%s does not exist\n', DAQdevice)
        return
    end


    %% Parameters

    aoSampleRate = 10000;   % Samples per second
    doSampleRate = 10000;   % Samples per second

    aoFreq  = 10;          % 10 Hz sine wave on AO0
    doFreq1 = 10;          % 10 Hz square wave on P0.0
    doFreq2 = 100;         % 100 Hz square wave on P0.1


    %% Build AO waveform (10 Hz sine, +/-2.5 V)

    aoSamplesPerPeriod = aoSampleRate / aoFreq;
    aoWaveform = 2.5 * sin(2*pi*(0:aoSamplesPerPeriod-1)'/aoSamplesPerPeriod);


    %% Build DO waveform (packed port data)

    doSamplesPerPeriod1 = doSampleRate / doFreq1;
    doSamplesPerPeriod2 = doSampleRate / doFreq2;
    doNumSamples = lcm(doSamplesPerPeriod1, doSamplesPerPeriod2);

    t = (0:doNumSamples-1)';

    sq1 = mod(floor(2 * doFreq1 * t / doSampleRate), 2);   % 10 Hz
    sq2 = mod(floor(2 * doFreq2 * t / doSampleRate), 2);   % 100 Hz

    % Pack into port word:
    %   bit0 -> P0.0
    %   bit1 -> P0.1
    doPortData = uint32(sq1)*bitshift(1,0) + ...
                 uint32(sq2)*bitshift(1,1);


    %% Reset the device

    DaqSystem.Local.LoadDevice(DAQdevice).Reset;


    try
        %------------------------------------------------------------------
        % Create separate DAQmx tasks for the AO and DO
        %
        % C equivalent - DAQmxCreateTask
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        %
        aoTask = NationalInstruments.DAQmx.Task('mixedAO');
        doTask = NationalInstruments.DAQmx.Task('mixedDO');


        %------------------------------------------------------------------
        % Create analog output voltage channel (AO0)
        %
        % C equivalent - DAQmxCreateAOVoltageChan
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaovoltagechan/
        %
        aoChan = [DAQdevice '/AO0'];
        aoTask.AOChannels.CreateVoltageChannel( ...
            aoChan, ...
            'ao0', ...
            -10, 10, ...
            AOVoltageUnits.Volts);


        %------------------------------------------------------------------
        % Create digital output port channel (port0)
        %
        % C equivalent - DAQmxCreateDOChan
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatedochan/
        %
        doChan = [DAQdevice '/port0'];
        doTask.DOChannels.CreateChannel( ...
            doChan, ...
            'do0', ...
            ChannelLineGrouping.OneChannelForAllLines);


        %------------------------------------------------------------------
        % SET UP THE AO TASK
        %

        % * Configure the sampling rate and buffer size
        %
        % C equivalent - DAQmxCfgSampClkTiming
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgsampclktiming/
        %
        aoTask.Timing.ConfigureSampleClock( ...
            '', ...
            aoSampleRate, ...
            SampleClockActiveEdge.Rising, ...
            SampleQuantityMode.ContinuousSamples, ...
            length(aoWaveform));


        % * Allow sample regeneration
        %
        aoTask.Stream.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;


        % * Write the waveform to the buffer
        %
        aoWriter = AnalogSingleChannelWriter(aoTask.Stream);
        aoWriter.WriteMultiSample(false, aoWaveform);


        %------------------------------------------------------------------
        % SET UP THE DO TASK
        %

        % * Configure the sampling rate and buffer size of the DO task. 
        % Note that we are using the AO sample clock for the DO. 
        doTask.Timing.ConfigureSampleClock( ...
            ['/' DAQdevice '/ao/SampleClock'], ...
            doSampleRate, ...
            SampleClockActiveEdge.Rising, ...
            SampleQuantityMode.ContinuousSamples, ...
            doNumSamples);


        % * Allow sample regeneration
        %
        doTask.Stream.WriteRegenerationMode = WriteRegenerationMode.AllowRegeneration;


        % * Write digital pattern to the buffer
        %
        doWriter = DigitalSingleChannelWriter(doTask.Stream);
        doWriter.WriteMultiSamplePort(false, doPortData);


        % * Configure the DO task to start when the AO task starts
        %
        % C equivalent - DAQmxCfgDigEdgeStartTrig
        % http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcfgdigedgestarttrig/
        %
        doTask.Triggers.StartTrigger.ConfigureDigitalEdgeTrigger( ...
            ['/' DAQdevice '/ao/StartTrigger'], ...
            DigitalEdgeStartTriggerEdge.Rising);


        %------------------------------------------------------------------
        % Verify both tasks
        %
        aoTask.Control(TaskAction.Verify);
        doTask.Control(TaskAction.Verify);


        %------------------------------------------------------------------
        % Arm the DO task first (waiting for trigger)
        %
        doTask.Start;


        %------------------------------------------------------------------
        % Start the AO task (fires the trigger)
        %
        aoTask.Start;


        fprintf('AO: 10 Hz sine wave on AO0 (+/-2.5 V)\n');
        fprintf('DO: 10 Hz on P0.0, 100 Hz on P0.1 (triggered by AO)\n');
        fprintf('Press return to stop\n');


        input('');

        %------------------------------------------------------------------
        % Stop and clean up
        %
        aoTask.Stop;
        doTask.Stop;

        aoTask.Dispose;
        doTask.Dispose;


    catch ME

        fprintf('Cleaning up DAQ tasks\n');

        if exist('aoTask','var')
            aoTask.Stop;
            aoTask.Dispose;
        end

        if exist('doTask','var')
            doTask.Stop;
            doTask.Dispose;
        end

        rethrow(ME)

    end % try/catch

end % AOandDO
