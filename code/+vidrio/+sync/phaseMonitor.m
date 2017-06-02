classdef phaseMonitor < handle
    % Plot the relative phase of two AO tasks on different boards
    %
    % vidrio.sync.phaseMonitor 
    %
    %
    % Hook up AO0 of DAQ_a to AI0 of DAQ_a and AO0 of DAQ_b to AI1 of DAQ_a
    % Then run, e.g. vidrio.sync.phaseMonitor('DAQ_a','DAQ_b';
    % The input args are the device IDs. First is the one with the AI connections.
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

        lastDataHandle_A
        lastDataHandle_B
        lastDataHandle_BA %Copy of _A
        lastDataHandle_C

        histData_B
        histDataHandle_B
        histData_C
        histDataHandle_C

        minPointsToPlot % We trigger the waveform at the upward 0 V crossing so it looks consistent and we plot at least this many points
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
            set([obj.axis_B,obj.axis_C],'NextPlot','add')

            % Plot some empty data which we will later modify in readAndPlotData
            % in the first two plots we show the two waveforms as a function of time
            obj.minPointsToPlot = round((obj.taskA.sampleRate*obj.taskA.updatePeriod)/3);
            obj.lastDataHandle_A = plot(obj.axis_A, zeros(obj.minPointsToPlot,1), '-','color', [1,0.4,0.4],'linewidth',2);
            obj.histData_B = nan(obj.minPointsToPlot,1);
            obj.histDataHandle_B = plot(obj.axis_B, obj.histData_B, '-');
            obj.lastDataHandle_B = plot(obj.axis_B, zeros(obj.minPointsToPlot,1), '-k','linewidth',2);
            obj.lastDataHandle_BA = plot(obj.axis_B, zeros(obj.minPointsToPlot,1), '-','color', [1,0.75,0.75],'linewidth',3);


            % In the third plot we will show AI 1 as a function of AI 0
            obj.lastDataHandle_C = plot(obj.axis_C, zeros(round(obj.taskA.sampleRate*obj.taskA.updatePeriod),1),'-k','linewidth',2);
            obj.histData_C = nan(obj.minPointsToPlot,1,2);
            obj.histDataHandle_C = plot(obj.axis_C, obj.histData_C(:,:,1), obj.histData_C(:,:,2), '-');

            %Make plots look nice
            obj.axis_A.YLabel.String=[obj.taskA.DAQdevice, ' Voltage (V)'];
            obj.axis_A.XLabel.String='Samples';

            obj.axis_B.YLabel.String=[obj.taskB.DAQdevice, ' Voltage (V)'];
            obj.axis_B.XLabel.String='';
            obj.axis_B.XTickLabel=[];

            obj.axis_C.XLabel.String=[obj.taskA.DAQdevice, ' Voltage (V)'];
            obj.axis_C.YLabel.String=[obj.taskB.DAQdevice, ' Voltage (V)'];

            % Set properties of axes together
            set([obj.axis_A,obj.axis_B,obj.axis_C], 'Box', 'On', 'XGrid', 'On', 'YGrid', 'On', ...
                'YLim', [obj.taskA.minVoltage,obj.taskA.maxVoltage], 'XLim',[0,obj.minPointsToPlot])

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


        function plotIt(obj,~,eventData)

            AIdata=eventData.AffectedObject.acquiredData; %Get the data

            %lock to the first upward 0 V crossing
            if exist('smooth','builtin')
                tmp=smooth(AIdata(:,1));
            else
                % Hope smoothing isn't necessary if the tlbx is missing
                tmp=AIdata(:,1);
            end
            tmp=round(tmp,2);
            f=find(tmp(1:end-1,1)==0 & diff(tmp(:,1))>0 );
            if isempty(f)
                return
            end

            AIdata(1:f(1),:)=[];
            if length(AIdata)<obj.minPointsToPlot
                %Do not proceed if not enough points are available to plot
                return
            end

            %We keep the plot objects the same and just change their data properties
            obj.lastDataHandle_A.YData=AIdata(:,1);



            obj.histData_B(:,end+1)=AIdata(1:obj.minPointsToPlot,2);
            obj.axis_B.ColorOrder=flipud(gray(size(obj.histData_B,2))) ;
            delete(obj.histDataHandle_B)
            obj.histDataHandle_B=plot(obj.axis_B,obj.histData_B,'linewidth',1.5);

            obj.lastDataHandle_B.YData=AIdata(:,2);
            uistack(obj.lastDataHandle_B,'top')
            obj.lastDataHandle_BA.YData = AIdata(:,1);


            obj.lastDataHandle_C.XData=AIdata(:,1);
            obj.lastDataHandle_C.YData=AIdata(:,2);


            obj.histData_C(:,end+1,1)=AIdata(1:obj.minPointsToPlot,1);
            obj.histData_C(:,end, 2)=AIdata(1:obj.minPointsToPlot,2);

            obj.axis_C.ColorOrder=flipud(gray(size(obj.histData_B,2))) ;
            delete(obj.histDataHandle_C)
            obj.histDataHandle_C=plot(obj.axis_C, obj.histData_C(:,:,1), obj.histData_C(:,:,2), 'linewidth',2);            
            uistack(obj.lastDataHandle_C,'top')

        end %close plotIt


        function windowCloseFcn(obj,~,~)
            fprintf('You closed the window. Shutting down DAQ.\n')
            obj.delete % simply call the destructor
        end %close windowCloseFcn



    end %close methods block

end %close the vidrio.mixed.AOandAI_OO class definition 
