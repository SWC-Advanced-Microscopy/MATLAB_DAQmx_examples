# Synchronising DAQ operations across devices

The examples in this folder relate to synchronising tasks. 
It's assumed you're already familiar with the information in `vidrio.mixed`.
Also see `ContinuousAI.c` in the DAQmx_ANSI_C_examples directory.
The following demo uses the class `vidrio.sync.sine_AO_AI`, which just plays a sine wave out of AO0 on the target DAQ device.

### 1. Starting two tasks at the same time
Let's start two tasks at the same time on different DAQs from the command line.
Hook up the AO0 lines of each DAQ to a scope then run:

```
>> B=vidrio.sync.sine_AO_AI('Dev1');
>> R=vidrio.sync.sine_AO_AI('Dev2');
>> B.startAcquisition; R.startAcquisition;
```

Where `'Dev1'` and `'Dev2'` are your DAQ names.
You should see two waveforms with a phase shift, since they didn't start at the same instant. 
Set up the scope to trigger off the waveform on channel 1 and change the time scale to show about one cycle of the waveform. 
Watch for a while. See the phase shift?

Stop the acquisition:

```
>> B.stopAcquisition;R.stopAcquisition;
```

You can also use `vidrio.sync.phaseMonitor('Dev1','Dev2');` to monitor the phase of the two waveforms without a scope. 


### 2. Triggering the tasks simultaneously
Will the phase shift problem go away if start the two waveforms at exactly the same time?
`vidrio.sync.sine_AO_AI` triggers the AO task from the AI task so we need to set this up to wait for a trigger:

Set up triggers so nothing happens until 5V goes into PFI0. 
The tasks need to be stopped (see above) then you can run:

```
>> B.hAITask.cfgDigEdgeStartTrig('PFI0','DAQmx_Val_Rising'); 
>> R.hAITask.cfgDigEdgeStartTrig('PFI0','DAQmx_Val_Rising');
```

Note how we can configure the start trigger properties directlty on the two objects we have already created. 
This is what is nice about object-oriented programming. 
To use the triggers, wire up the rack so that the two PFI0 ports are connected. If using BNC, attach a T-piece to one.
Then start the tasks:

```
>> B.startAcquisition;R.startAcquisition;
```

Nothing happens on the scope until you hook up PFI0 (e.g. with your T connector) to +5 (the breakout box provides this).
You can unplug the 5V line right away, it's only needed transiently for the trigger. 
Of course you could also hook up PFI0 to a digital line and trigger it via MAX Test Panels or even set up a separate digital task in MATLAB. 

What do you see on the scope? The waveforms should be in phase perfectly. Nice, huh?
Keep watching. Ah... They drift apart over time. 

Stop the acquisition:
```
>> B.stopAcquisition; R.stopAcquisition;
```

### 3. Sync the clocks
The clocks are drifting! 
Clearly we need a *shared clock* between the boards.
Each class is set up such that the AI task on that device uses the AO clock of the same device. 
So all we need to do is have the AO clock of the DAQ in one class use the AO clock of the DAQ in the other class.

If your cards are in a PXI chassis or linked by an RTSI cable then you simply tell DAQmx that one device should use the other's clock:


```
% Ensure the stopAcquisition methods have been run.
>> B.hAOTask.cfgSampClkTiming(B.sampleRate,'DAQmx_Val_ContSamps', size(B.waveform,1), ['/',R.DAQdevice,'/ao/SampleClock'])
>> B.startAcquisition;R.startAcquisition;
```

Then trigger. 
Easy: no more phase delay!

In other situations (e.g. mixed PCI, PXI, or USB; or even devices on different PCs) you will need to [export the clock](http://digital.ni.com/public.nsf/allkb/3A7F1402B2A1CE7686256E93007E66C0). 
So look at the device routes and find on which PFI ports the AO sample clock can be is broadcast then we can use [DAQmxExportSignal](http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxexportsignal/).

For example, we can export the AO sample clock from one device to PFI10:
```
>> R.hAOTask.exportSignal('DAQmx_Val_SampleClock', 'PFI10')
```

You'll be able to see the pulses on a scope, but they are short: 40 ns or so FWHM. 
Next we set the other DAQ to import a clock on PFI1 (we're using PFI0 for the start trigger).
Wire up your DAQ remembering to use PF1 not digital port 1 on line 0.
```
>> B.hAOTask.cfgSampClkTiming(B.sampleRate,'DAQmx_Val_ContSamps', size(B.waveform,1), 'PFI1')
>> B.startAcquisition;R.startAcquisition;
```

Nice synchronised waveforms!
Note that the above only works when your two (or more) tasks need to run at the same rate. 
For more see the [NI synchronisation white paper](http://www.ni.com/white-paper/11369/en/).
