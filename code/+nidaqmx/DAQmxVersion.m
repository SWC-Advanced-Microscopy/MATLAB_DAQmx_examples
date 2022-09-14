function varargout = DAQmxVersion
% List DAQmx version via the .NET assembly
%
% function [versionAsString, versionAsStructure] = nidaqmx.DAQmxVersion
%
% Purpose
% Query the NI DAQmx version using the .NET assembly. If no outputs are
% requested, the results are printed in screen. If outputs are requested,
% the user can return the version as string and/or as a structure containing
% numeric values.
%
% Inputs
% None
%
% Outputs (optional)
% versionAsString - devices as a string
% versionAsStructure - A structure containing three scalars, describing the major,
%                    minor, and update versions of the driver.
%
%
% Rob Campbell - SWC 2022


nidaqmx.add_DAQmx_Assembly
import NationalInstruments.DAQmx.*


versionAsString = sprintf('DAQmx version: %d.%d.%d', ...
            DaqSystem.Local.DriverMajorVersion, ...
            DaqSystem.Local.DriverMinorVersion, ...
            DaqSystem.Local.DriverUpdateVersion);

if nargout<1
    fprintf('%s\n',versionAsString);
    return
end


if nargout > 0
    varargout{1} = versionAsString;
end


if nargout > 1
    varargout{2} = struct(...
            'MajorVersion', DaqSystem.Local.DriverMajorVersion, ...
            'MinorVersion', DaqSystem.Local.DriverMinorVersion, ...
            'UpdateVersion', DaqSystem.Local.DriverUpdateVersion);
end

