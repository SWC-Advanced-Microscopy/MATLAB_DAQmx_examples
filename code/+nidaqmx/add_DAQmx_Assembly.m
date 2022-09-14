function vargargout = add_DAQmx_Assembly
% Add NI DAQmx .NET assembly and return true if successful
%
% function isAdded = nidaqmx.add_DAQmx_Assembly
%
% Inputs
% None
%
% Outputs
% isAdded - true if NI DAQmx assembly has been added. false otherwise
%
%
% Rob Campbell - SWC 2022



isAdded = nidaqmx.isDAQmx_Assembly_added;

% Bail if it's already been added
if isAdded
    if nargout>0
        varargout{1} = isAdded;
    end

    return
end


try
    NET.addAssembly('NationalInstruments.DAQmx');
catch
    fprintf('Error loading .NET assembly! Check NIDAQmx .NET installation.\n')
end


isAdded = nidaqmx.isDAQmx_Assembly_added;

if nargout>0
    varargout{1} = isAdded;
end
