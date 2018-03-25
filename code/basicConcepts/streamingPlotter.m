classdef streamingPlotter < handle

    % Simple example of defining a class in MATLAB 
    % 
    % streamingPlotter.m
    % 
    % 
    % INTRODUCTION
    % This class provides an example of stuff that is easy and natural using object
    % oriented programming but more awkard with regular approaches. Please see 
    % simpleOOexample, if you are not already familiar with object-oriented programming. 
    %
    % This example creates a class that that makes a scrolling line plot on the current 
    % axes. It creates a figure if none exists. The scrolling figure can be modified by 
    % changing its update rate, number of points, and a small number of plot properties. 
    %
    % 
    % USAGE EXAMPLES
    %
    % One - create an instance of the class and interact with it:
    % >> S=streamingPlotter;     
    % >> S.setUpdateInterval(0.03) % Increase the update rate
    % >> S.markerColor='r'; % Set the marker colour to red by changing the value of a class property
    % >> S.stopStream  % Stop the update
    % >> S.startStream % Restart the update
    % >> delete(S) % Delete the classes (which clears the plot)
    %
    % 
    % Two - Set up two streaming plots on the same figure window and set them 
    %       running with different parameters
    %
    % %Create two sub-plots and populate them with streaming plots:
    % >> subplot(2,1,1)
    % >> S1=streamingPlotter(gca);
    % >> subplot(2,1,2)
    % >> S2=streamingPlotter(gca); 
    %
    % %Change the properties of the two plots:
    % >> S2.markerColor='g';
    % >> S2.setUpdateInterval(0.025)
    % >> S2.numMarkersOnScreen=100;
    % >> S1.numMarkersOnScreen=10;  
    %
    % %Stop and tidy up
    % >> delete([S1,S2])
    %
    %
    % Rob Campbell - Basel 2016



    properties %open properties block
        % These two properties define the marker colour and the number of markers
        % plotting on the screen at any one time.
        markerColor='k' 
        numMarkersOnScreen=50
    end %close properties block


    properties (Hidden)
        % Properties in this block are not directly visible to the user at the command line.
        % i.e. if the user types "properties(OBJECTNAME)" only the properties in the above 
        % block are listed. Those in this block aren't listed but can still be modified. 
        % We can block even modification by making these properties "protected" should we 
        % wish to. This would make the class "safer", so the user can't do things like 
        % delete the plot axes. 

        plotTimer % This property will holder a timer object
        plotAxes  % The plot axes are stored here
        plotData  % The data being plotted are stored here
        updateInterval=0.5 % Number of seconds between plot updates
    end % Close hidden properties block



    methods %open methods block

        function obj=streamingPlotter(plotAxes)
            % This method is special and is known as a "constructor". The constructor method always
            % has the same name as the class. It is run once, when an instance of the class is created.

            % If no inputs provided, create an axis
            if nargin<1
                fig=clf;
                obj.plotAxes = axes('Parent', fig, 'Position', [0.15,0.15,0.8,0.8]);
            else
                obj.plotAxes = plotAxes;
            end

            % Make some random data
            obj.plotData=rand(1,obj.numMarkersOnScreen);

            % Plot these random data
            plot(obj.plotAxes,obj.plotData, '-ok', 'MarkerFaceColor', obj.markerColor)

            % Create a timer object that we will use to update the plot at fixed intervals
            obj.plotTimer = timer;
            obj.plotTimer.Period = obj.updateInterval; % How often to update
            obj.plotTimer.TimerFcn = @obj.plotStreamerCallBackFcn; %This function is run at fixed interval
            obj.plotTimer.StopFcn = @(~,~) [];
            obj.plotTimer.ExecutionMode = 'fixedDelay';

            obj.startStream % Start the timer
        end %close the streamingPlotter constructor method


        function delete(obj)
            % This is destructor, it runs when the object is deleted
            obj.stopStream
            cla(obj.plotAxes); %remove plot from axes
        end % close destructor method


        function startStream(obj)
            % Starts the timer (could add other stuff here if needed)
            start(obj.plotTimer)
        end % close startStream method


        function stopStream(obj)
            % Stops the timer (could add other stuff here if needed)
            stop(obj.plotTimer)
        end %close stopStream method


        function setUpdateInterval(obj,updateInterval)
            % Changes the update interval of the plot
            %
            % streamingPlotter.setUpdateInterval(intervalInSeconds)
            %
            % intervalInSeconds - time between plot update events in seconds. 

            % You could also do this with a dependent property (that would be the advanced approach):
            % https://www.mathworks.com/help/matlab/matlab_oop/access-methods-for-dependent-properties.html
            if updateInterval<0.025
                fprintf('Update interval can not be shorter than 25 ms\n')
                updateInterval=0.025;
            end

            obj.updateInterval=updateInterval;
            stop(obj.plotTimer)
            obj.plotTimer.Period = obj.updateInterval; %Of course could also do this without the updateInterval property
            start(obj.plotTimer)
        end % close setUpdateInterval method

    end %close methods block



    methods (Hidden)

        % Methods in this block are not directly visible to the user at the command line
        % i.e. they don't show up with "methods(OBJECTNAME)" 
        function plotStreamerCallBackFcn(obj,~,~)
            obj.plotData(end+1)=rand;
            if length(obj.plotData)>obj.numMarkersOnScreen
                obj.plotData = obj.plotData(end-obj.numMarkersOnScreen+1:end);
            end
 
            C=get(obj.plotAxes,'Children');
            C.YData=obj.plotData;
            C.MarkerFaceColor=obj.markerColor;
            drawnow
        end %close plotStreamer method

    end %close hidden methods block


end %close simpleOOexample classdef
