function anonymousFunctionExample
    % Example - how to use anonymous functions and function handles in MATLAB
    %
    % function anonymousFunctionExample
    %
    % Purpose
    % Demo showing a few simple use-cases for anonymous functions and function handles.
    % These crop up quite often if you use functions like arrayfun or cellfun. They 
    % also crop up in GUI programming and DAQ tasks. For example, the function 
    % daqtoolbox.AO.analogOutput_Continuous in this repository uses an anonymous function 
    % to queue data to the output buffer, and windowCloseFunction.m uses a function 
    % handle to change what happens when a figure window is closed.
    %
    %
    % For details see:
    % http://www.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
    %
    %
    % Rob Campbell - Basel 2016



    % Create an anonymous function that makes a sine wave. It has one input argument
    % that determines the number of cycles in the sine wave. 
    sinWave = @(nCycles) ( sin(linspace(-nCycles*pi,nCycles*pi,100*nCycles)) );

    % In other words, you now have a function handle (similar to a variable) called "sinWave"
    % and you can feed it an input argument like this:
    sinWave(10);


    %So it's possible to do things like pass it to a plot command:
    clf
    n=3;
    plot(sinWave(n))
    title(sprintf('%d cycles of a sine wave',n))
    set(gca,'XTickLabel',[],'YTickLabel',[])
    grid



    %Use a function handle to an existing MATLABA function to calculate the mean of each vector in a cell array
    r = {rand(1,30), randn(1,150)*100, rand(1,1000)};
    fprintf('\nThe contents of cell array "r" are:\n')
    disp(r)


    fprintf('Use cellfun and a function handle to calculate the mean of each vector in "r":\n' );
    disp(cellfun(@mean,r))
    %More details at: https://www.mathworks.com/help/matlab/ref/cellfun.html

    fprintf('Use cellfun and an anonymous function to calculate 1.96 SD of each each vector in "r":\n' );

    SD95 = @(x) (std(x)*1.96);

    disp(cellfun(SD95,r))

