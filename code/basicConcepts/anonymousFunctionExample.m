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



    % ** Anonymous Functions
    %
    % An anonymous function is not stored in a file, but is associated with a variable. 
    % So you can define an anonymous function at the command line, for instance. 
    % Anonymous functions are limited, since they can contain only a single executable statement.
    % They are useful for telling another function to perform an arbitrary operation. 
    % Examples of this are shown below.
    % 

    % Create an anonymous function that makes a sine wave. It has one input argument
    % that determines the number of cycles in the sine wave. 
    sinWave = @(nCycles) ( sin(linspace(-nCycles*pi,nCycles*pi,100*nCycles)) );

    % The variable "sineWave" is known as a "function handle" and you can feed it an input argument like this:
    sinWave(10);


    %So it's possible to do things like pass it to a plot command:
    clf
    n=3;
    plot(sinWave(n))
    title(sprintf('%d cycles of a sine wave',n))
    set(gca,'XTickLabel',[],'YTickLabel',[])
    grid



    % ** More uses of function handles
    % 
    % In the above example, sineWave is a handle to an anonymous function we cooked up
    % on the spot. You can create a handle to *existing* MATLAB functions too. Let's see 
    % how by creating and using a handle to MATLAB's "mean" command that calculates averages. 

    % First we make three random vectors and store them in a cell array.
    r = {rand(1,30), randn(1,150)*100, rand(1,1000)};
    fprintf('\nThe contents of cell array "r" are:\n')
    disp(r)

    % Now we use the "cellfun" function to calculate the average of each vector
    fprintf('Use cellfun and a function handle to calculate the mean of each vector in "r":\n' );
    disp(cellfun(@mean,r))
    %More details at: https://www.mathworks.com/help/matlab/ref/cellfun.html


    % Of course we can use cellfun with anonymous functions too.
    fprintf('Use cellfun and an anonymous function to calculate 1.96 SD of each each vector in "r":\n' );

    SD95 = @(x) (std(x)*1.96);

    disp(cellfun(SD95,r))


    % * When would you use these techniques?
    % You will find these approaches helpful from time to time as they simplify your code. Function handles 
    % allow you pass around brief "concepts" and yet treat these as regular variables. 
