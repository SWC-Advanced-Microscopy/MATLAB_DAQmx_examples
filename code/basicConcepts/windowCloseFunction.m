function windowCloseFunction
    % Example - run user-defined function when the figure window is closed
    %
    % function windowCloseFunction
    %
    % Purpose
    % Demo showing how to run a defined sub-function when the figure window is closed.
    % This is basic object-oriented programming, since you are interacting with the 
    % the figure "object".
    %
    %
    % Instructions
    % Run the function then close the window
    %
    %
    % Rob Campbell - Basel 2016



    hFig = figure; %Make a new figure
    % The variable "hFig" is an object of class figure. You can try this yourself
    % now at the command line. Go there and type the following:
    % >> F=figure
    % >> class(F)
    %
    % It will tell you that F is of class "matlab.ui.Figure"
    %
    % You can see the "properties" and "methods" that F embodies:
    % >> properties(F)
    % >> methods(F)
    %
    % Note that one of the properties you see is called "CloseRequestFcn"
    % This tells the figure what functio to run when the close button is pressed. 
    % In this demo we modify CloseRequestFcn so it does something a bit different.


    % Modify the figure's "close request function" to call the sub-function "figClose"
    % More info: https://www.mathworks.com/help/matlab/ref/figure-properties.html#prop_CloseRequestFcn
    % also see: anonymousFunctionExample.m
    hFig.CloseRequestFcn = @figClose; % This line is very basic object-oriented programming 

    % Note, it is also valid to assign the CloseRequestFunction using set:
    % set(hFig,'CloseRequestFcn', @figClose);


    y = sin(-2*pi : pi*0.01 : 2*pi);
    plot(y,'-', 'color',[1,1,1]*0.5)
    axis tight

    fprintf('\n\n ** CLOSE THE WINDOW! **\n\n')
    title('Press the close button')




    %-----------------------------------------------
    function figClose(figHandle,closeEvent)
        %Runs when the window close button is pressed

        title('YOU PRESSED THE CLOSE BUTTON')
        x=xlim;
        y=ylim;

        fSize=16;
        t=text(mean(x), mean(y), 'CLOSING', ...
            'FontWeight', 'bold', ...
            'FontSize', fSize,...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle');


        %Create a dazzling and amazing effect
        cols = 'rk';
        for ii=1:10
            set(t,'color', cols(1+mod(ii,2)), 'FontSize', fSize+ii*2)
            pause(0.25)
        end

        pause(0.25)

        delete(figHandle)
        fprintf('The window was closed\n\n')
