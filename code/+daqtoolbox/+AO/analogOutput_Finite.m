function analogOutput_Finite
% Play one cycle of a waveform out of an analog output using the on-board clock
%
% function daqtoolbox.AO.analogOutput_Finite
%
% Instructions
% Connect AO0 of NI device Dev1 to an oscilloscope and run this function.
% 
%
%
% Rob Campbell - Basel 2016
%
% See also;
% vidrio.AO.hardwareFiniteVoltage

devName = 'Dev1'; % The name of the DAQ device as shown in MAX

%Create a session using NI hardware
s=daq.createSession('ni');


%Add one output channel (channel 0)
s.addAnalogOutputChannel(devName,0,'Voltage'); 


%Build one cycle of a sine wave
waveForm=sin(-pi : pi/1000 : pi)';


%Set the sample rate to 2000 samples per second, so the waveform plays out in one second
s.Rate = 2000;


%Queue the data to the board
s.queueOutputData(waveForm);


%Play the waveform
s.startForeground 
