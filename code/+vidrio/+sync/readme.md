# Synchronising DAQ operations across devices

The examples in this folder relate to synchronising tasks. 
It's assumed you're already familiar with the information in vidrio.mixed
Also see ContinuousAI.c in the DAQmx_ANSI_C_examples directory

### One
Let's start two tasks at the same time on different DAQs from the command line.
Hook up the AO0 lines of each DAQ to a scope then run:

```
>> B=vidrio.sync.sine_AO_AI('Dev1');
>> R=vidrio.sync.sine_AO_AI('Dev2');
>> B.startAcquisition;R.startAcquisition;
```

Where 'Dev1' and 'Dev2' are your DAQ names.
You should see two waveforms with a phase shift. 
Trigger off the waveform on channel 1 of the scope and change the time scale to show about one cycle of the waveform. 
Watch for a while. What do you notice?

Stop the acquisition:

```
>> B.stopAcquisition;R.stopAcquisition;
```

### Two
Will this problem go away if start the two waveforms at exactly the same time?
vidrio.sync.sine_AO_AI triggers the AO task from the AI task so we need to set this up to wait for a trigger:

Set up triggers so nothing happens until 5V goes into PFI0

```
>> B.hAITask.cfgDigEdgeStartTrig('PFI0','DAQmx_Val_Rising'); R.hAITask.cfgDigEdgeStartTrig('PFI0','DAQmx_Val_Rising');
```

Now wire up the rack so that the two PFI0 ports are connected. If using BNC, attach a T-piece to one.

```
>> B.startAcquisition;R.startAcquisition;
```

Nothing happens on the scope until you hook up PFI0 (e.g. with your T connector) to +5 (the breakout box provides this)
You can unplug the 5V line right away, it's only needed transiently for the trigger. 

What do you see on the scope? The waveforms should be in phase perfectly. Nice, huh?
Keep watching. Ah.....

Stop the acquisition:
```
>> B.stopAcquisition;R.stopAcquisition;
```

### Three
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