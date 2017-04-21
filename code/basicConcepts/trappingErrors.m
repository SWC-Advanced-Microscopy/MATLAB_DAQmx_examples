function trappingErrors
    % Example - demonstrates the use of try/catch for trapping errors
    %
    % function trappingErrors
    %
    % Purpose
    % Sometimes you want to ensure that a block of codes fails gracefully in
    % the event of an error. You can achieve this with a try/catch statement.
    %
    %
    % More info:
    % https://ch.mathworks.com/help/matlab/ref/try.html
    %
    %
    % Rob Campbell - Basel 2017


    %Define a short vector
    x = [1,2,3,4];

    try
        %MATLAB always attempts to execute code in this "try" block

        for ii=1:5, disp(x(ii)), end %Loop through the vector and create an error

    catch ME
        %If code in the "try" block fails, the code in this "catch" block is run
        fprintf('\nERROR!\nThe following error happened:\n%s\n\n', ME.message)
        %rethrow(ME)
    end

    %The error was trapped and so the following display line will run and print to screen
    disp('code here still runs')


    %However, this error will not be caught
    for ii=1:5, disp(x(ii)), end %Loop through the vector and create an error

    % So the following is never run
    disp('This will not run')
    disp('Does not matter what happens here: you will not see it because of the error in the final for loop');
