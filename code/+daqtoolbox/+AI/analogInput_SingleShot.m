function varargout = analogInput_SingleShot
% Example showing how to record two seconds
%
% function data = analogInput_SingleShot
%
% Purpose
% Records two seconds of data and plots it to screen.
% Optionally returns as output argument. 
%
% Outputs
% data - [optional] Returns the data vector that was plotted to screen.
%
% 
% Rob Campbell - Basel 2016


%Create a session using NI hardware
s=daq.createSession('ni');
s.Rate=20E3; %Set the sample rate

%Add an analog input channel
AI=s.addAnalogInputChannel('Dev1', 'ai0', 'Voltage');
AI.Range = [-1,1]; %record over +/- 1 V

%Pull in 2 seconds worth of samples
s.NumberOfScans = s.Rate*2;


%start the acquisition and block until finished
fprintf('Acquiring data...');
[data,t]=s.startForeground;
fprintf('\n');


%Plot
plot(t,data)


%Release the DAQ session
s.release;


if nargout>0
	varargout{1} = data;
end

