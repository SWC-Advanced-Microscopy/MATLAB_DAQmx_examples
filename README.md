# DAQmx Examples

These examples show you how to interact with National Instruments devices using MATLAB.
The focus is  [Vidrio's](http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home) free [DAQmx](https://www.ni.com/dataacquisition/nidaqmx.htm) wrapper, `dabs.ni.daqmx`.
Also supplied are some contrasting examples using The Mathworks [Data Acquisition Toolbox](https://www.mathworks.com/help/daq/). 
Since this is already well described, there are fewer of these examples. 
All examples require a Windows machine. 


### The `dabs.ni.daqmx` wrapper
The MATLAB Data Acquisition Toolbox is the most common way of handling data acquisition in MATLAB. 
However, with NI hardware you can also use the free `dabs.ni.daqmx` wrapper that is part of [ScanImage](http://scanimage.vidriotechnologies.com/).
This is a thin, object-oriented wrapper that provides access to almost the full DAQmx API.

In addition to `dabs.ni.daqmx`, ScanImage also supplies an [FPGA](http://www.ni.com/fpga/) interface wrapper (`dabs.ni.rio`) which can be used to run a [bitfile](http://www.ni.com/white-paper/9640/en/) compiled using LabVIEW FPGA on any [NI RIO](http://www.ni.com/academic/students/learn-rio/what-is/) FPGA target. 
The [NI VISA](https://www.ni.com/visa/) wrapper (`dabs.ni.visa`) connects to and communicates with devices that support NI's VISA interface (such as oscilloscopes). 
This currently supports only a small subset of the NI VISA API.


### What is provided here
This repository contains a bunch of NI DAQmx examples using both the MATLAB DAQ toolbox and the `dabs.ni.daqmx` wrapper. 
The examples provided here overlap with those provided by Vidrio in `dabs.ni.daqmx.demos`, but are more up to date and more extensively commented. 
The `DAQmx_ANSI_C_examples` directory is for convenience and contains copies of some of the examples installed along with DAQmx.
Some examples use more advanced MATLAB features, these are covered by example code in the `basicConcepts` directory. 


## Installation

* Download [ScanImage](http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home) and add its root directory to your MATLAB path.
* Install the supported version of DAQmx. For example, ScanImage 5.2 [requires v15.5](http://scanimage.vidriotechnologies.com/display/SI2016/Software+Version+Compatibility)
* Add the examples in this repository to your path or `cd` to the `code` directory to run the examples.
* You may [create simulated devices](http://www.ni.com/tutorial/3698/en/) in [NI MAX](http://digital.ni.com/public.nsf/allkb/71544521BDE34FFB86256FCF005F4FB6) to run with the examples on a machine with no NI hardware connected. 
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
Example have been tested with an NI PCI-6229. 
Many have also been verified to work with a simulated NI PCIe-6341. 
You may get errors with certain combinations of cards and examples. 
e.g. With a PCI-6115 certain buffered examples will complain that the sample rate is too low. 


## Key Contents

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

### Hints
The use of `try`/`catch` blocks should ensure the DAQmx tasks always shut down cleanly. 
If they do not:
* If the DAQ device claims to be in use, you can reset it using MAX. 
* If you end up with orphan tasks, you will have to close and re-open MATLAB. 

### Further information 
* [Using NI-DAQmx in Text Based Programming Environments](http://www.ni.com/tutorial/5409/en/)
* [DAQmx C Reference help](http://zone.ni.com/reference/en-XX/help/370471AE-01/) and [C functions listing](http://zone.ni.com/reference/en-XX/help/370471AE-01/TOC3.htm)
* Vidrio DAQmx [docs](http://scanimage.vidriotechnologies.com/display/API/Hardware+Support+Package+%28dabs%29+-+ni+-+daqmx) and [demos](http://scanimage.vidriotechnologies.com/display/API/Hardware+Support+Package+%28dabs%29+-+ni+-+daqmx+-+demos)


### DAQmx in other languages
* [PyDAQmx](https://pythonhosted.org/PyDAQmx/index.html)
* [Calling the DAQmx dll directly from Python and Perl](http://www.ni.com/white-paper/8911/en/)
* For ANSI C examples look in `C:\Users\Public\Documents\National Instruments\NI-DAQ\Examples`
* You can find side-by-side examples of how DAQmx works in different languages [here](http://www.ni.com/product-documentation/2835/en/).
