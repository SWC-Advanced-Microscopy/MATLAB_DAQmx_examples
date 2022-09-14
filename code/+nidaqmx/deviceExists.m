function devExists = deviceExists(devID)
% Return true if an NI device of a given name is connected
%
% function devExists = nidaqmx.deviceExists(devID)
%
% Purpose
% Returns true if DAQmx reports that a device called devID is attached to the PC.
% If the device is not present, false is returned.
%
% Inputs
% devID - String defining the name of the device to search for. e.g. 'Dev1'
%
% Outputs
% devExists - true if device exists
%
%
% Rob Campbell - SWC 2022


devExists = false;

try
    connectedDevices = nidaqmx.listDevices;
catch
    fprintf('Failed to read connected NI devices\n')
    return
end


devExists = ~isempty(strmatch(devID, connectedDevices));

