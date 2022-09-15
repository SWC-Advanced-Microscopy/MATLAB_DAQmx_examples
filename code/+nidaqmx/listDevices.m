function varargout = listDevices
% List connected devices
%
% function devices = nidaqmx.listDevices
%
% Purpose
% Query the NI devices attached to the PC. If no outputs are requested,
% the results are printed in screen. If outputs are requested, the
% display is suppressed and a cell array of strings is returned.
%
% Inputs
% None
%
% Outputs (optional)
% devices - a cell array of strings listing attached devices.
%
%
% Rob Campbell - SWC 2022


nidaqmx.add_DAQmx_Assembly
import NationalInstruments.DAQmx.*


devs = DaqSystem.Local.Devices;
devices = cell(1,devs.Length);

for ii = 1:devs.Length
    devices{ii} = char(devs(ii));

    if nargout < 1
        fprintf('%d. %s -- %s\n', ...
            ii, ...
            devices{ii}, ...
            DaqSystem.Local.LoadDevice(devs(ii)).ProductType)
    end
end



if nargout>0
    varargout{1} = devices;
end
