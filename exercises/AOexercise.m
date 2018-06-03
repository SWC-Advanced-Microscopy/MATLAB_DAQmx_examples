function AOexercise


    % Monitoring the output
    % If you lack an oscilloscope you may physically connect the analog output to 
    % an analog input and monitor this using the NI MAX test panel. You likely will need
    % to select RSE: http://www.ni.com/white-paper/3344/en/
    %
    % 
    % Also see:
    % Restrictions on AO tasks: http://digital.ni.com/public.nsf/allkb/2C45C3DC484FF730862570E7007CCBD4?OpenDocument


    %Define a cleanup function
    tidyUp = onCleanup(@cleanUpFunction);



    try

        % * Create a DAQmx task
        %   More details at: "help dabs.ni.daqmx.Task"
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreatetask/
        hTask = dabs.ni.daqmx.Task  % <====


        % * Connect analog output 1 to your DAQ device
        %   see help dabs.ni.daqmx.Task.createAOVoltageChan"
        %   http://zone.ni.com/reference/en-XX/help/370471AE-01/daqmxcfunc/daqmxcreateaovoltagechan/
        hTask.createAOVoltageChan % <====


        % Define a waveform (anything you like) to play out of the analog output. The waveform should be at least 2 seconds long.
        % Hints: 
        % 1) The values of your waveform will correspond directly to voltages coming out of AO1. 
        % 2) You will play the waveform out of AO1 at 1 kHz. So 1000 samples will correspond to a 1 s long waveform
        % 3) The linspace command is useful
        waveform = % <====


        % * Configure the sampling rate and the number of samples
        % Use the cfgSampClkTiming method to:
        % 1) Set the sample rate to 1 kHz
        % 2) Set the analog output mode to finite sampling
        % 3) What should the third input argument be as a consequence of using finite sampling?
        %
        % Hint: help dabs.ni.daqmx.Task.cfgSampClkTiming
        hTask. % <====



        % * Set the size of the output buffer using the cfgOutputBuffer method
        %   Hint: the output buffer should be the same size as the waveform you are playing out
        %   help dabs.ni.daqmx.Task.cfgOutputBuffer
        hTask. % <====


        % * Write the waveform to the buffer 
        %   Hint: the waveform should be a column vector (it should have multiple rows)
        %   help dabs.ni.daqmx.Task.writeAnalogData
        hTask.writeAnalogData % <====


        % Start the task and wait until it's done
        hTask.start

        fprintf('Playing AO waveform...\n')
        hTask.waitUntilTaskDone; % wait until all requested samples have been played acquired


    catch ME
       daqDemosHelpers.errorDisplay(ME)
       return

    end %try/catch


    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    function cleanUpFunction
        %This runs when the function ends
        if exist('hTask','var')
            fprintf('Cleaning up DAQ task\n');
            hTask.stop;    % Calls DAQmxStopTask
            delete(hTask); % The destructor (dabs.ni.daqmx.Task.delete) calls DAQmxClearTask
        else
            fprintf('No task variable present for clean up\n')
        end
    end %close cleanUpFunction


end % main function 

