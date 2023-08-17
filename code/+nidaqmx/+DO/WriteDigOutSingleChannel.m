function WriteDigOutSingleChannel(devID)
% Flip Port0/Line0 of named device on and off at random intervals until ctrl-c is hit
%
% function nidaqmx.DO.WriteDigOutSingleChannel(devID)
%
% Purpose
% Example showing how to write to a single digital channel using software time commands.
% This is the most basic possible thing. Connect port0/line0 of the named DAQ to an scope
% and watch the line randomly flick state. Use a 100 ms per div interval.
% Hit ctrl-c to disconnect from the DAQ and stop.
%
% Inputs
% devID - [optional] 'Dev1' by default
%
% Outputs
% None
%
% Rob Campbell - SWC 2023

%Define a cleanup object

% Add the DAQmx assembly if needed then import
NET.addAssembly('NationalInstruments.DAQmx');
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
task = NationalInstruments.DAQmx.Task();


% * Set port0 line0 as a digital output line
chan = [devID,'/Port0/line0'];
task.DOChannels.CreateChannel(chan,'',ChannelLineGrouping.OneChannelForEachLine);



%  * Create an instance of DigitalSingleChannelWriter
%
% This class contains methods for writing samples to the digital output line in a task.
% https://www.ni.com/docs/en-US/bundle/ni-daqmx-net-framework-45-api-ref/page/ninetdaqmxfx45ref/html/m_nationalinstruments_daqmx_digitalsinglechannelwriter_writesinglesamplesingleline.htm
taskWriter = DigitalSingleChannelWriter(task.Stream);


fprintf('\n Randomly switching digital line. Ctrl-C to stop\n\n')

state = true;
while true
    taskWriter.WriteSingleSampleSingleLine(true,state);
    state = ~state;
    pause(rand*0.1)
end

