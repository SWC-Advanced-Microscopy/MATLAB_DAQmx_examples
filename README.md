# DAQmx Examples
<img src="https://github.com/tenss/MatlabDAQmx/blob/master/code/%2Bvidrio/%2Bsync/phase_example.jpg" />

These examples show you how to interact with [National Instruments](http://www.ni.com) devices using [MATLAB](http://www.mathworks.com/).
The focus is  [Vidrio's](http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home) free [DAQmx](https://www.ni.com/dataacquisition/nidaqmx.htm) wrapper, `dabs.ni.daqmx`.
Also supplied are some contrasting examples using The Mathworks [Data Acquisition Toolbox](https://www.mathworks.com/help/daq/). 
All examples require a Windows machine. 


### The `dabs.ni.daqmx` wrapper and .NET
The MATLAB [Data Acquisition Toolbox](https://www.mathworks.com/products/daq.html) is the most common way of handling data acquisition in MATLAB. 
However, with NI hardware you can also use the free `dabs.ni.daqmx` wrapper that is part of [ScanImage](http://www.vidriotechnologies.com/).
This is a thin, object-oriented wrapper that provides access to almost the full DAQmx API.
This may be particularly helpful to those who are used to the ScanImage API and it works pretty well.
Alternatively, you can call the DAQmx library more directly using the .NET interface.
Example code for this is in the `nidaqmx` module (i.e. the `+nidaqmx` directory).
The Vidrio wrapper is a little more similar to the call structure you will find in Python, but it requires a ScanImage install (free).
The .NET interface requires you to have installed .NET support when you installed DAQmx.

In addition to `dabs.ni.daqmx`, ScanImage also supplies an [FPGA](http://www.ni.com/fpga/) interface wrapper (`dabs.ni.rio`) which can be used to run a [bitfile](http://www.ni.com/white-paper/9640/en/) compiled using LabVIEW FPGA on any [NI RIO](http://www.ni.com/academic/students/learn-rio/what-is/) FPGA target. 
The [NI VISA](https://www.ni.com/visa/) wrapper (`dabs.ni.visa`) connects to and communicates with devices that support NI's VISA interface (such as oscilloscopes). 
This currently supports only a small subset of the NI VISA API.


### What is provided here
This repository contains a bunch of NI DAQmx examples using both the MATLAB DAQ toolbox and the `dabs.ni.daqmx` wrapper. 
The examples provided here overlap with those provided by Vidrio in `dabs.ni.daqmx.demos`, but are more up to date and more extensively commented. 
The `DAQmx_ANSI_C_examples` directory is for convenience and contains copies of some of the examples installed along with DAQmx.
The `basicConcepts` directory illustrates some of the more advanced programming concepts which crop up. 


## Installation

* Download [ScanImage](http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home) and add its root directory to your MATLAB path.
* Install the supported version of DAQmx. For example, ScanImage 5.2 [requires v15.5](http://scanimage.vidriotechnologies.com/display/SI2016/Software+Version+Compatibility).
* Add the examples in this repository to your path or `cd` to the `code` directory to run the examples.
* You may [create simulated devices](http://www.ni.com/tutorial/3698/en/) in [NI MAX](http://digital.ni.com/public.nsf/allkb/71544521BDE34FFB86256FCF005F4FB6) to run the examples on a machine with no NI hardware connected. 
Triggers do not work in simulated mode: they fire immediately.
Simulated mode also works in a virtual machine. 


### Running examples
By default all examples will run on NI DAQ device `Dev1`.
In each example this device ID is defined by a variable called `devName` near the start of the function. 
You will therefore either need a DAQ device called `Dev1` or you will need to edit the code accordingly. 
You can see which devices are connected in NI MAX or by running: `vidrio.listDeviceIDs` at the MATLAB command line. 
For each example, first look at the help text (e.g. `help vidrio.AO.softwareTimedVoltage`) then run at the MATLAB command-line. e.g. 

```
>> vidrio.AO.softwareTimedVoltage
```

There are further comments in-line so open the example in an editor to learn more.
Examples have been tested with an NI [PCI-6229](http://www.ni.com/en-us/support/model.pci-6229.html) and [PXIe-6341](http://www.ni.com/documentation/en/pxi-multifunction-io-module/latest/pxie-6341/overview/). 
Many examples have also been verified to work with a simulated NI PCIe-6341. 
Not all examples work on all boards (e.g. the [re-triggerable example](https://github.com/tenss/MatlabDAQmx/blob/master/code/%2Bvidrio/%2Bmixed/DO_retriggerable.m) requires an [X-Series board](http://www.ni.com/xseries/)). 
You may simply get errors with certain combinations of cards and examples. 
e.g. With a PCI-6115, certain buffered examples will complain that the sample rate is too low so you will need to modify this. 


## Key Contents

* `vidrio.listDeviceIDs` - shows how to list available device and query them to obtain detailed information


### Basic analog input and output examples
* `vidrio.AO.softwareTimedVoltage` - software-timed ("on demand") analog output
* `vidrio.AO.hardwareFiniteVoltage` - hardware-timed analog output (using the on-board clock) of a fixed number of points
* `vidrio.AO.hardwareContinuousVoltage` - basic continuous analog output with the on-board clock
* `vidrio.AO.hardwareContinuousVoltageNoRegen` - basic continuous analog output with the on-board clock that recycles the output buffer
* `vidrio.AO.hardwareContinuousVoltageNoRegen_DigTrig` - Continuous analog output that is hardware triggered by a digital (TTL) rising edge
* `vidrio.AI.softwareTimedVoltage` - software-timed ("on demand") analog input
* `vidrio.AI.hardwareFiniteVoltage` - hardware-timed analog input (using the on-board clock) of a fixed number of points
* `vidrio.AI.hardwareContinuousVoltage` -  A simple example showing hardware-timed continuous analog input with no callback functions
* `vidrio.AI.hardwareContinuousVoltageWithCallBack` -  Hardware-timed continuous analog input with a callback function. Acq ends when figure is closed.
* `vidrio.mixed.AOandAI` - continuous AI and AO that run simultaneously and in sync. 

### Basic digital IO and counters
* `vidrio.DO.softwareBasic` - simple on-demand digital output
* `vidrio.CO.singlePulse` - create a single digital pulse using a counter task

### More advanced techniques
* `vidrio.mixed.AOandAI_OO` - Interactive continuous AI and AO using object-oriented programming.
* `vidrio.mixed.AOandAI_OO_sharedClock` - Interactive continuous AI and AO with shared clock between AO and AI.
* For retriggerable tasks see `vidrio.mixed.DO_retriggerable` and `vidrio.mixed.AO_retriggerable`
* `vidrio.sync` is a demo package showing how to synchronise two DAQ devices and why you need to do so. 

### Hints
The use of `try`/`catch` blocks should ensure the DAQmx tasks always shut down cleanly. 
If they do not:
* If the DAQ device claims to be in use, you can reset it using MAX. 
* If you end up with orphan tasks, you will have to close and re-open MATLAB. 

### Further information 
* [Using NI-DAQmx in Text Based Programming Environments](http://www.ni.com/tutorial/5409/en/)
* [DAQmx C Reference help](http://zone.ni.com/reference/en-XX/help/370471AE-01/) and [C functions listing](http://zone.ni.com/reference/en-XX/help/370471AE-01/TOC3.htm)
* See [SimpleMScanner](https://github.com/tenss/SimpleMScanner) for basic 2-photon scanning software written using the techniques shown here. 

### DAQmx in other languages
* [Official Python NI DAQmx](https://github.com/ni/nidaqmx-python)
* [PyDAQmx](https://pythonhosted.org/PyDAQmx/index.html)
* A [wrapper for PyDAQmx](https://github.com/petebachant/daqmx)
* [Calling the DAQmx dll directly from Python and Perl](http://www.ni.com/white-paper/8911/en/)
* For ANSI C examples look in `C:\Users\Public\Documents\National Instruments\NI-DAQ\Examples`
* You can find side-by-side examples of how DAQmx works in different languages [here](http://www.ni.com/product-documentation/2835/en/).

### Projects using the Vidrio DAQmx wrapper
* [ScanImage Tools](https://github.com/BaselLaserMouse/ScanImageTools)
* [SimpleMScanner](https://github.com/tenss/SimpleMScanner)

### Projects using NI's DAQmx .NET assembly
* [LSMAQ](https://github.com/danionella/lsmaq/)
