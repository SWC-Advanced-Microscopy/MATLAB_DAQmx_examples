function cleanUp
    % Example - run a sub-function automatically when the caller function ends
    %
    % function cleanUp
    %
    % Purpose
    % Demo of how to run a sub-function when the caller function ends. 
    % The "cleanUp" function will run even if the caller crashes.
    %
    % 
    % Inputs
    % none
    %
    % Outputs
    % none
    %
    %
    %
    % Rob Campbell - Basel 2016
    %
    % see: http://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    %
    % See also: windowCloseFunction



    %Define a cleanup object
    tidyUp = onCleanup(@cleanUpFunction);

    fprintf('Press ctrl-C to abort')

    n=0;
    while 1
        pause(0.5)
        fprintf('.')
        n=n+1;
    end


        %-----------------------------------------------
        %The clean-up function is nested so it has access to the caller's namespace
        function cleanUpFunction
            fprintf('\n\nTidying up (there were %d dots printed to screen).\n\n',n)
        end %cleanUpFunction


end %cleanUp