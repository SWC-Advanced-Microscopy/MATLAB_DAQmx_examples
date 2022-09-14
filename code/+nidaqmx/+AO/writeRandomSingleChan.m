function writeRandomSingleChan(devID)
% Write random numbers to AO0 of device devID using DAQmx .NET
%
% function nidaqmx.AO.writeRandomSingleChan
%
% Purpose
% Example showing how to write random numbers to AO0 of device devID using DAQmx .NET.
%
% Inputs
% None
%
% Outputs (optional)
% None
%
% Rob Campbell - SWC 2022


if ~nidaqmx.deviceExists(devID)
    return
end


% Add the DAQmx assembly if needed then import
nidaqmx.add_DAQmx_Assembly
import NationalInstruments.DAQmx.*




% Reset the device we will use
DaqSystem.Local.LoadDevice(devID).Reset


% Start a task and add channel AO0 to it
task = NationalInstruments.DAQmx.Task;

% Add a voltage channel
task.AOChannels.CreateVoltageChannel([devID,'/ao0'], '', -10, 10, AOVoltageUnits.Volts);

taskWriter = AnalogSingleChannelWriter(task.Stream);

fprintf('\nPlaying random numbers out of %s/AO0. Ctrl-C to stop\n\n', devID)


while 1
    value = rand*20 - 10;
    taskWriter.WriteSingleSample(true,value);
end


% Reset the device, which also sets AO0 to 0V
DaqSystem.Local.LoadDevice(devID).Reset

