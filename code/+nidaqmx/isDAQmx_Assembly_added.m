function varargout = isDAQmx_Assembly_added
% Return true if NI .NET assembly has been added
%
% function isAdded = nidaqmx.isDAQmx_Assembly_added
%
% Inputs
% None
%
% Outputs
% isAdded - true if NI DAQmx assembly has been added. false otherwise
%
%
% Rob Campbell - SWC 2022

assemblies = System.AppDomain.CurrentDomain.GetAssemblies;

isAdded = false;

for ii = 1:assemblies.Length

    tName = char(assemblies(ii).GetName.Name);
    if contains(tName,'NationalInstruments')
        isAdded = true;
    end

end

if nargout>0
    varargout{1} = isAdded;
end
