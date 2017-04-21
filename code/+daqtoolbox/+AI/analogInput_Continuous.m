function analogInput_Continuous
% Example showing how to record data continuously through an analog input channel
%
% function out = daqtoolbox.AI.analogInput_Continuous
%
% Purpose
% Records data continuously and plots to screen.
% Displays positive values only.
% 
% Rob Campbell - Basel 2016


%Create a session using NI hardware
s=daq.createSession('ni');
s.Rate=20E3;

%Add an analog input channel
AI=s.addAnalogInputChannel('Dev1', 'ai2', 'Voltage');
inputRange = 1;
AI.Range = [-inputRange , inputRange]; %record over +/- 1 V


% Number of samples to pull in at a time
s.NumberOfScans = s.Rate*0.1;


%Add a listener to get data back from this channel and plot it
addlistener(s,'DataAvailable', @plotData); 

%Trigger the listener after all data have been acquired
s.NotifyWhenDataAvailableExceeds=s.NumberOfScans;

s.IsContinuous = true; %needed to provide continuous behavior

%start the acquisition and block until finished
clf

s.startBackground

fprintf('Press ctrl-c to quit\n');
while 1
	pause(0.1)
end




% - - - - - - - - - - - - - - - - - - - - -
function plotData(~,event)
	%Nested function to plot data
	t=event.TimeStamps;
	x=event.Data;
 
	plot(t,x)
	ylim([0,inputRange])
	grid
end

end