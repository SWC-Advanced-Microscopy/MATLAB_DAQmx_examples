function writeRandomSingleChan(devID)
% Write random numbers to AO0 of device devID using DAQmx .NET
%
% function nidaqmx.AO.writeRandomSingleChan(devID)
%
% Purpose
% Example showing how to write random numbers to AO0 of device devID using DAQmx .NET
% This code plays out 1000 random numbers then stops and resets the DAQ.
%
% Inputs
% devID - [optional] 'Dev1' by default
%
% Outputs
% None
%
% Rob Campbell - SWC 2022

% Add the DAQmx assembly if needed then import
nidaqmx.add_DAQmx_Assembly
import NationalInstruments.DAQmx.*


if nargin<1
    devID = 'Dev1';
end

if ~nidaqmx.deviceExists(devID)
    fprintf('%s does not exist\n', devId)
    return
end


% Reset the device we will use
DaqSystem.Local.LoadDevice(devID).Reset


% * Create a DAQmx task
%   C equivalent - DAQmxCreateTask
%   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
task = NationalInstruments.DAQmx.Task;

% * Set up analog output 0 on device defined by variable devID
%   C equivalent - DAQmxCreateAOVoltageChan
%   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaovoltagechan/
task.AOChannels.CreateVoltageChannel([devID,'/ao0'], '', -10, 10, AOVoltageUnits.Volts);


%  * Create an instance of AnalogSingleChannelWriter
%
% This class contains methods for writing samples to the analog output channel in a task.
% https://www.ni.com/docs/en-US/bundle/ni-daqmx-net-framework-40-api-ref/page/ninetdaqmxfx40ref/html/t_nationalinstruments_daqmx_analogsinglechannelwriter.htm
taskWriter = AnalogSingleChannelWriter(task.Stream);


n = 1000;
fprintf('\nPlaying %d random numbers out of %s/AO0. Ctrl-C to stop\n\n', n, devID)


for ii=1:n
    value = rand*20 - 10;
    taskWriter.WriteSingleSample(true,value);
end

fprintf('Finished and reseting DAQ\n')


DaqSystem.Local.LoadDevice(devID).Reset

