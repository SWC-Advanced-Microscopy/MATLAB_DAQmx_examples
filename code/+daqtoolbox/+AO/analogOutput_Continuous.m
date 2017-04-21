function analogOutput_Continuous
% Play a continuous sine wave out of an analog output
%
% function daqtoolbox.AO.analogOutput_Continuous
%
%
% Instructions
% Connect AO0 of NI device Dev1 to an oscilloscope and run this function.
% Quit with ctrl-C.
%
%
% Rob Campbell - Basel 2016
%
% Also see:
% vidrio.AO.hardwareContinuousVoltage

devName = 'Dev1';  % The name of the DAQ device as shown in MAX


%Create a session using NI hardware
s=daq.createSession('ni');


%Add one output channel (channel 0)
s.addAnalogOutputChannel(devName,0,'Voltage'); 


%Build one cycle of a sine wave
waveform=sin(linspace(-pi,pi,1000));

%Set the sample rate to 2000 samples per second, so the waveform plays out in one second
s.Rate = 2000;


%The output buffer is re-filled for the next line when it becomes half empty
s.NotifyWhenScansQueuedBelow = round(length(waveform)*0.5); 


% This listener tops up the output buffer with an anonymous function 
% (see basicConcepts/anonymousFunctionExample.m)
addlistener(s,'DataRequired', @(src,event) src.queueOutputData(waveform));

s.IsContinuous = true; %needed to provide continuous behavior


%queue the first cycle 
s.queueOutputData(waveform); 


% START!
s.startBackground 


%Block. User presses ctrl-C to to quit, this calls stopAcq
fprintf('Press ctrl-c to stop')
while 1
	pause(0.25)
end

