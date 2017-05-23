classdef phaseMonitor < handle
    % Plot the relative phase of two AO tasks on different boards
    %
    % vidrio.sync.phaseMonitor 
    %
    %
    % Hook up AO0 of DAQ_a to AI0 of DAQ_a and AO0 of DAQ_b to AI1 of DAQ_a
    % 
    %
    % Also see:
    % vidrio.sync.sine_AO_AI, vidrio.mixed.AOandAI, vidrio.mixed.AOandAI_OO, 


    properties
        taskA
        taskB
    end %close properties block

    properties (Hidden)
        listeners

        % These properties hold information relevant to the plot window
        hFig %The handle to the figure which shows the data is stored here
        axis_A %Handles for the two axes
        axis_B 
        axis_C

    end


    methods

        function obj=phaseMonitor(DAQ_ID_A, DAQ_ID_B)

            % Connect to DAQ
            obj.taskA=vidrio.sync.sine_AO_AI(DAQ_ID_A);
            obj.taskB=vidrio.sync.sine_AO_AI(DAQ_ID_B);


            obj.hFig = clf;
            obj.hFig.Position(3)=obj.hFig.Position(3)*1.5; %Make figure a little wider
            obj.hFig.Name='Close figure to stop acquisition'; %This is just the OO notation. We could also use the set command.
            obj.hFig.CloseRequestFcn = @obj.windowCloseFcn;


            %Make two empty axes which we fill in the method readAndPlotData
            obj.axis_A = axes('Parent', obj.hFig, 'Position', [0.1 0.12 0.4 0.4]);
            obj.axis_B = axes('Parent', obj.hFig, 'Position', [0.1 0.55 0.4 0.4]);
            obj.axis_C = axes('Parent', obj.hFig, 'Position', [0.55 0.12 0.4 0.8]);

            % Plot some empty data which we will later modify in readAndPlotData
            % in the first two plots we show the two waveforms as a function of time
            plot(obj.axis_A, zeros(round(obj.taskA.sampleRate*obj.taskA.updatePeriod),1))
            plot(obj.axis_B, zeros(round(obj.taskA.sampleRate*obj.taskA.updatePeriod),1))

            % In the third plot we will show AI 1 as a function of AI 0
            plot(obj.axis_C, zeros(round(obj.taskA.sampleRate*obj.taskA.updatePeriod),1),'.-')

            %Make plots look nice
            obj.axis_A.YLabel.String='Voltage (V)';
            obj.axis_A.XLabel.String='Samples';

            obj.axis_B.YLabel.String='Voltage (V)';
            obj.axis_B.XLabel.String='';
            obj.axis_B.XTickLabel=[];

            % Set properties of axes together
            set([obj.axis_A,obj.axis_B], 'Box', 'On', 'XGrid', 'On', 'YGrid', 'On', 'YLim', [obj.taskA.minVoltage,obj.taskA.maxVoltage])
            set(obj.axis_C, 'XLim', [obj.taskA.minVoltage,obj.taskA.maxVoltage])




            
            addlistener(obj.taskA,'acquiredData', 'PostSet', @(src,eventData) obj.plotIt(src,eventData) );


            obj.taskA.startAcquisition;
            obj.taskB.startAcquisition;

        end % close constructor


        function delete(obj)
            delete(obj.taskA)
            delete(obj.taskB)
            delete(obj.hFig)
        end %close destructor


        function plotIt(obj,src,eventData)

            AIdata=eventData.AffectedObject.acquiredData; %Get the data
            %We keep the plot objects the same and just change their data properties
            C=get(obj.axis_A, 'Children');
            C(1).YData=AIdata(:,1);

            C=get(obj.axis_B, 'Children');
            C.YData=AIdata(:,2);

            C=get(obj.axis_C, 'Children');
            C.YData=AIdata(:,1);
            C.YData=AIdata(:,2);
        end %close plotIt


        function windowCloseFcn(obj,~,~)
            fprintf('You closed the window. Shutting down DAQ.\n')
            obj.delete % simply call the destructor
        end %close windowCloseFcn



    end %close methods block

end %close the vidrio.mixed.AOandAI_OO class definition 
