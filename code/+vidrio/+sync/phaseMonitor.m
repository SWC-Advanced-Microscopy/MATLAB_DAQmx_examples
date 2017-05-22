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
    end


    methods

        function obj=phaseMonitor(DAQ_ID_A, DAQ_ID_B)

            obj.taskA=vidrio.sync.sine_AO_AI(DAQ_ID_A);
            obj.taskB=vidrio.sync.sine_AO_AI(DAQ_ID_B);

            
            addlistener(obj.taskA,'acquiredData', @obj.plotIt(src,eventData)); %TODO: confirm that's valic


            obj.taskA.startAcquisition;
            obj.taskB.startAcquisition;

        end % close constructor


        function delete(obj)
            delete(obj.taskA)
            delete(obj.taskB)
        end %close destructor


        function plotIt(obj,src,eventData)
            %TODO: plot both chans
        end


    end %close methods block

end %close the vidrio.mixed.AOandAI_OO class definition 
