# Exercises



### On-demand digital output 
An "on demand" operation is one where the DAQ device sends out data or receives data in response to a command issued from the PC.
For example, you might press a button in your scanning software to open or close the laser shutter. 
Here the shutter controller is connected to a digital output line of your DAQ. 
When the line goes high (+5 V) the shutter opens and when it goes low (0 V) the shutter closes. 
Pressing the shutter button leads to an "on demand" DAQ operation. 
In this exercise you will learn how to do this at the command line. 

HINT: if you get stuck, do: `edit vidrio.DO.softwareBasic.m`

At the command line:


1) Create an instance of an NI task with the task name "TENSS"
   Verify that the "taskName" property is the string "TENSS"

2) Use `dabs.ni.daqmx.System` to figure out the device names of the attached NI devices

3) Create a digital output channel on port 0, line 3. 

4) If you are using a PCI DAQ with an external breakout box: connect port 0, line 3 to "User 1" with a wire. 
Then connect the BNC output labeled "User 1" to channel 1 of an oscilloscope. 
If you are using a USB DAQ, connect connect port 0, line 3 to an oscilloscope. 


5) Use the `writeDigitalData` method to set the digital output line high and low and monitor this with the oscilloscope. 

6) use the `delete` command to close the connection to the device. 




### Analog Output
On demand operations are perfect for responding to user interaction or handling signals where timing is not critical. 
However, there is lag and temporal jitter in operations triggered from the PC.
To get around this, DAQ devices have memory buffers which can store input or output waveforms. 
In this exercise you will perform such "buffered" analog output in order to play out a waveform from an analog output line.

Open `AOexercise.m` and complete all lines which end with `% <====`
Run the command once you're done and monitor the output on an oscilloscope to confirm it works.

In the above function, the waveform begun being played out as soon as the "start" method was run. 
Let's make it start on a trigger.

1) Modify the above code using the `cfgDigEdgeStartTrig` method such that it will start when port `PFIO` goes from low to high. 
2) Start your modified AOexercise.m and trigger the waveform by shorting `PFI0` to the +5V terminal of the DAQ or the +5V line from an Arduino. 





###  Analog input
Use `vidrio.AI.hardwareContinuousVoltageWithCallBack` to read in a photodiode signal and plot it to screen.
Read through the code and get an understand of what each line is doing. 

