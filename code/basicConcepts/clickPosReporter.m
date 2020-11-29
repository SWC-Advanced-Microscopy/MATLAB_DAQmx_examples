function clickPosReporter
    % clickReporter
    %
    % Brings up a figure window which places a marker on the
    % axes where the user clicks. Each time the user clicks, 
    % marker moves and the position is reported to the title.
    %
    %


    % Make an empty figure window
    fig = figure(7824);
    fig.NumberTitle='off';
    fig.Name = 'Click on the plot to report mouse position';

    clf

    % Set the axes to be square in the range -10 to 10
    xlim([-10,10])
    ylim([-10,10])


    grid on
    box on
    axis square


    % Overlay an invisible red circle
    hold on
    ax = gca;
    ax.UserData.lastPoint = plot(nan,nan,'or','MarkerSize',6,'LineWidth',2);
    hold off

    title('CLICK IT!');

    % Set up a callback functyion to run each time the user clicks on the axes
    ax.ButtonDownFcn = @clicker;
   


    function clicker(src,~)
        % Get the current mouse position (at the clicked location) and use it
        % to place a point there and display coords to the axes title.
        pos = src.CurrentPoint;
        msg = sprintf('X=%0.2f Y=%0.2f',pos(1,1),pos(1,2));
        set(get(src,'Title'),'String',msg)

        src.UserData.lastPoint.XData = pos(1,1);
        src.UserData.lastPoint.YData = pos(1,2);
