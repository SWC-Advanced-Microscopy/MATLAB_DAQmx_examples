The examples in this folder relate to synchronising tasks. 
It's assumed you're already familiar with the information in vidrio.mixed
Also see ContinuousAI.c in the DAQmx_ANSI_C_examples directory

### One
Let's start two tasks at the same time on different DAQs from the command line.
Hook up the AO0 lines of each DAQ to a scope then run:
>> B=vidrio.sync.sine_AO_AI('Dev1');
>> R=vidrio.sync.sine_AO_AI('Dev2');
>> B.startAcquisition;R.startAcquisition;

Where 'Dev1' and 'Dev2' are your DAQ names.
You should see two waveforms with a phase shift. 
Trigger off the waveform on channel 1 of the scope and change the time scale to show about one cycle of the waveform. 
Watch for a while. What do you notice?

Stop the acquisition:
>> B.stopAcquisition;R.stopAcquisition;


### Two
Will this problem go away if start the two waveforms at exactly the same time?
vidrio.sync.sine_AO_AI triggers the AO task from the AI task so we need to set this up to wait for a trigger:

Set up triggers so nothing happens until 5V goes into PFI0
>> B.hAITask.cfgDigEdgeStartTrig('PFI0','DAQmx_Val_Rising'); R.hAITask.cfgDigEdgeStartTrig('PFI0','DAQmx_Val_Rising');

Now wire up the rack so that the two PFI0 ports are connected. If using BNC, attach a T-piece to one.

>> B.startAcquisition;R.startAcquisition;

Nothing happens on the scope until you hook up PFI0 (e.g. with your T connector) to +5 (the breakout box provides this)
You can un-plug the 5V line right away, it's only needed transiently for the trigger. 

What do you see on the scope? The waveforms should be in phase perfectly. Nice, huh?
Keep watching. Ah.....

Stop the acquisition:
>> B.stopAcquisition;R.stopAcquisition;


### Three
Clearly we need a shared clock between the boards.
Each class is set up such that the AI task uses the AO clock. 
So all we need to do is have the AO clock of the DAQ in one class use the AO clock of the DAQ in the other class.

Ensure the stopAcquisition methods have been run.

If your cards are in a PXI chassis or linked by an RTSI cable then just do:

>> B.hAOTask.cfgSampClkTiming(B.sampleRate,'DAQmx_Val_ContSamps', size(B.waveform,1), ['/',R.DAQdevice,'/ao/SampleClock'])
>> B.startAcquisition;R.startAcquisition;

Then trigger. 
Easy: no more phase delay!
