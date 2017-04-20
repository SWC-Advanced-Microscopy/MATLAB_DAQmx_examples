function windowCloseFunction
	% Example - run user-defined function when the figure window is closed
	%
	% function windowCloseFunction
	%
	% Purpose
	% Demo showing how to run a defined sub-function when the figure window is closed.
	%
	%
	% Rob Campbell - Basel 2016



	hFig = figure; %Make a new figure

	%Modify the figure's "close request function" to call the sub-function "figClose"
	set(hFig,'CloseRequestFcn', @figClose);

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

		cols = 'rk';
		for ii=1:10
			set(t,'color', cols(1+mod(ii,2)), ...
				'FontSize',fSize+ii*2)
			pause(0.25)
		end


		pause(0.25)

		delete(figHandle)
		fprintf('The window was closed\n\n')
