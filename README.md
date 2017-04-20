# DAQmx Examples

These examples show you how to interact with National Instruments devices using MATLAB.
The focus of these examples is  [Vidrio's](http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home) free DAQmx wrapper, `dabs.ni.daqmx`.
Also supplied are some contrasting examples using The Mathworks [Data Acquisition Toolbox](https://www.mathworks.com/help/daq/). 
Since this is already well described, there are fewer of these examples. 
All examples require a Windows machine. 


### Vidrio's `dabs.ni.daqmx` wrapper
The MATLAB Data Acquisition Toolbox is the most common way of handling data acquisition in MATLAB. 
However, with NI hardware you can also use the free `dabs.ni.daqmx' wrapper that is part of [ScanImage](http://scanimage.vidriotechnologies.com/).
This is a thin, object-oriented wrapper that provides access to almost the full DAQmx API.

In addition to `dabs.ni.daqmx`, ScanImage also supplies an FPGA interface wrapper (`dabs.ni.rio`) which can be used to run a bitfile compiled using LabVIEW FPGA on any NI RIO FPGA target. 
The NI VISA wrapper (`dabs.ni.visa`) connects to and communicates with devices that support NI's VISA interface (such as oscilloscopes). 
This currently supports only a small subset of the NI VISA API.


### What is provided here
This repository contains a bunch of NI DAQ examples using both the DAQ toolbox and the Vidrio wrapper. 
The are similar to those in `dabs.ni.daqmx.demos` but are more up to date and are more extensively commented. 
The `DAQmx_ANSI_C_examples` directory is for convenience and contains copies of some of the examples installed along with DAQmx.


## Installation

* Download [ScanImage](http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home) and add its root directory to your MATLAB path.
* Install the supported version of DAQmx. For example, ScanImage 5.2 [requires v15.5](http://scanimage.vidriotechnologies.com/display/SI2016/Software+Version+Compatibility)
* Add the examples in this repository to your path or `cd` to the directory to run
* You may [create simulated devices](create simulated devive) in [NI MAX](http://digital.ni.com/public.nsf/allkb/71544521BDE34FFB86256FCF005F4FB6) to play with the examples on a machine with no NI hardware connected. Simulated mode also works in a virtual machine. 

### Running examples
By default all examples will run on NI DAQ device `Dev1`. 
In each example this is defined by a variable called `devName` near the start of the function. 
You will therefore either need a DAQ device (which may be simulated as many examples will work on simulated devices) called `Dev1` or you will need to edit the code accordingly. 

## Key Contents

* `vidrio.AO.softwareTimedVoltage` - software-timed ("on demand" output) analog output
* `vidrio.AO.hardwareFiniteVoltage` - hardware-timed analog output (using the on-board clock) of a fixed number of points
* `vidrio.AO.hardwareContinuousVoltage` - basic continuous analog output with the on-board clock
* `vidrio.AO.hardwareContinuousVoltageNoRegen` - basic continuous analog output with the on-board clock that recycles the output buffer



### Hints
The use of `try`/`catch` blocks should ensure the DAQmx tasks always shut down cleanly. 
If they do not:
* If the DAQ device claims to be in use, you can reset it using MAX. 
* If you end up with orphan tasks, you will have to close and re-open MATLAB. 

### Further information 
* [Using NI-DAQmx in Text Based Programming Environments](http://www.ni.com/tutorial/5409/en/)
* [DAQmx C Reference help](http://zone.ni.com/reference/en-XX/help/370471AE-01/)
* [DAQmx C functions](http://zone.ni.com/reference/en-XX/help/370471AE-01/TOC3.htm)
* [Vidrio DAQmx docs](http://scanimage.vidriotechnologies.com/display/API/Hardware+Support+Package+%28dabs%29+-+ni+-+daqmx)
* [Vidrio DAQmx demos](http://scanimage.vidriotechnologies.com/display/API/Hardware+Support+Package+%28dabs%29+-+ni+-+daqmx+-+demos)


### DAQmx in other languages
* [PyDAQmx](https://pythonhosted.org/PyDAQmx/index.html)
* [Calling the DAQmx dll directly from Python and Perl](http://www.ni.com/white-paper/8911/en/)
* For ANSI C examples look in `C:\Users\Public\Documents\National Instruments\NI-DAQ\Examples`