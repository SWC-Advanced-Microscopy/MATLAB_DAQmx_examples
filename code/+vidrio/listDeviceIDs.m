function varargout=listDeviceIDs(varargin)
    % List the IDs of all connected National Instruments devices
    %
    % function vidrio.listDeviceIDs
    %
    % 
    % Purpose
    % Print to screen the IDs of all connected NI devices. 
    %
    % 
    % Inputs (optional)
    % deviceName - [string] The function returns true if a 
    %              device with this name is present on the system.
    %              Nothing is printed to screen.
    %
    % Outputs
    % If a device ID is supplied, the function returns true or false
    % according to whether a device by this name is present on the
    % system. Otherwise, nothing is returned. If the user requested
    % an output argument but supplied no inputs, the function returns
    % the IDs of all connected devices as a cell array. 
    %
    % 
    % Examples
    %
    % >> vidrio.listDeviceIDs('Dev1')
    % ans =
    %   logical
    %    1
    %
    % >> vidrio.listDeviceIDs('WIBBLE')
    % ans =
    %   logical
    %    0
    %
    % >> vidrio.listDeviceIDs
    %   The devices on your system are:
    %    beam    X-Series DAQ    PXIe-6341
    %    pifoc   X-Series DAQ    PCIe-6321
    %    pmt     X-Series DAQ    USB-6343 (BNC)
    %    resscan X-Series DAQ    PXIe-6341
    %    scan    S-Series DAQ    PXIe-6124
    %
    % Rob Campbell - Basel, 2017



    %Start a task and attempt to read device names
    hNI=dabs.ni.daqmx.System;

    try
        devices = strsplit(hNI.devNames, ', ');
    catch ME
        rethrow(ME)
    end


    % If no devices are connected then say so and quit
    if isempty(devices)
        fprintf('No NI devices connectes\n');
        if varargout>0
            varargout{1}=[];
        end
        return
    end


    % If the user supplied an input argument, test of a device was present and quit.
    if nargin>0
        devToTest=varargin{1};
        if ~ischar(devToTest)
            fprintf('Input argument "deviceName" must be a string\n')
            return
        end
        varargout{1} = any( strmatch(devToTest,devices, 'exact') );
        return
    end


    %Display device names
    fprintf('\nThe devices on your system are:\n')

    maxNameLength=max(cellfun(@length,devices));
    cellfun(@(x) displayDevice(x,maxNameLength), devices )
    fprintf('\n')



    if nargout>0
        varargout{1}=devices;
    end



    function displayDevice(thisDevice,padNameTo)
        paddedName = repmat(' ',1,padNameTo);
        paddedName(1:length(thisDevice))=thisDevice;

        details = dabs.ni.daqmx.Device(thisDevice);
        cleanProdCat = regexprep(details.productCategory,'DAQmx_Val_(\w)(\w+)DAQ','$1-$2 DAQ');
        fprintf('\t%s\t%s\t%s\n', paddedName, cleanProdCat, details.productType)
