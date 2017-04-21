function cleanUp
    % Example - run a sub-function automatically when the caller function ends
    %
    % function cleanUp
    %
    % Purpose
    % Demo of how to run a sub-function when the main function ends. 
    % The use of try/catch statements means that the "cleanUp" function 
    % will run even if the caller crashes.
    %
    % Clean-up functions are not normally needed, since any variables present 
    % in your function are automatically cleared when the function ends. However,
    % clean-up functions are useful when you're doing things like hardware 
    % control. Say your function is communicating with a nuclear-powered toaster 
    % over a serial port. Since the device is dangerous, you want to ensure that
    % it's put into a safe state before the function ends (even if it ends in a
    % way that was predictable). Clean-up functions are just the ticket in this
    % sort of scenario. You will see clean-up functions in all the Vidrio DAQmx
    % examples in this repository. 
    %
    %
    %
    %
    % Rob Campbell - Basel 2016
    %
    % see: http://blogs.mathworks.com/loren/2008/03/10/keeping-things-tidy/
    %
    % See also: windowCloseFunction, nestedFunctionExample



    %Define a cleanup object
    tidyUp = onCleanup(@cleanUpFunction);

    fprintf('Press ctrl-C to abort')

    n=0;
    while 1
        pause(0.5)
        fprintf('.')
        n=n+1;
    end


    %NOTE: the cleanup function will also run on an error if you use a try/catch block
    %      (see trappingErrors.m) like this:

    %Option one:
    try
        %stuff  happens
        x=1; %Doesn't generate an error
    catch ME %See: https://www.mathworks.com/help/matlab/matlab_prog/capture-information-about-errors.html
        %Like this the clean-up function is run (call it explicitly then rethrow)
        cleanUpFunction
        rethrow(ME) %https://www.mathworks.com/help/matlab/ref/rethrow.html
    end

    %Option two:
    try
        %stuff  happens
        x=1; %Doesn't generate an error
    catch ME %See: https://www.mathworks.com/help/matlab/matlab_prog/capture-information-about-errors.html
        %Here we only show the message, so the clean-up function will run as normal
        disp(ME.message) 
    end


    %-----------------------------------------------
    %The clean-up function is nested so it has access to the caller's namespace
    function cleanUpFunction
        fprintf('\n\nTidying up (there were %d dots printed to screen).\n\n',n)
    end %cleanUpFunction


end %cleanUp
