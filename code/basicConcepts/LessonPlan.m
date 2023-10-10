% Can go through the following in lesson form


% Figures are objects
fig = figure;

% That have this class
class(fig)

% What's in a an object of this class?
fig
properties(fig)
methods(fig)


% For example there is a property called "Postition"
fig.Position
%move it
fig.Position

% We can also set it:
fig.Position(2) = 0;
fig.Position(2) = 100;

% Another example
fig.Color
fig.Color='r';

% What's happening there? Mention observable properties and listeners.
% Let's create a listener that changes the color of a different figure:
fig2 = figure;
L = addlistener(fig,'Color','PostSet', @(~,~) set(fig2,'Color', fig.Color) )
fig.Color='g'; %Changes both figures!



%% Let us try running a callback when the window is closed
% Run auto-complete on fig.Wi
fig.WindowButtonDownFcn %Show it's empty

% Introduce anonymous function 
 myFunc = @(~,~) disp('HELLO');
 myFunc
 myFunc()
 
 % Demo this
 fig.WindowButtonDownFcn=myFunc;
 
 % Now demo this
 fig.CloseRequestFcn=myFunc;

 % Now demo:
 windowCloseFunction

 
 % Demo in a new window how to write a simple class and point students to
 % go later back to simpleOOexample to check that out. Point is to hammer
 % home that it's not through some form of higher magic that this stuff is
 % created and built. 
 
 
 % What good is all this for? Show the streaming plotter
 clf
 subplot(2,1,1)
 S1=streamingPlotter(gca);
 subplot(2,1,2)
 S2=streamingPlotter(gca);
 
 S2.markerColor='g';
 S2.setUpdateInterval(0.025)
 
 S2.numMarkersOnScreen
 S2.numMarkersOnScreen=100;
 S2.numMarkersOnScreen=10;
 S2.numMarkersOnScreen=30;
 
 S1.stopStream
 S1.startStream
 delete([S1,S2])
 
