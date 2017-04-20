function anonymousFunctionExample
	% Example - how to use anonymous functions in MATLAB
	%
	% function anonymousFunctionExample
	%
	% Purpose
	% Demo showing a few use-cases for anonymouse functions. 
	%
	% For details see:
	% http://uk.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
	%
	%
	% Rob Campbell - Basel 2016




	% Create an anonymous function that makes a sine wave. It has one input argument
	% that determines the number of cucles in the sinwave
	sinWave = @(nCycles) ( sin(linspace(-nCycles*pi,nCycles*pi,100*nCycles)) );

	clf
	n=3;
	plot(sinWave(n))
	title(sprintf('%d cycles of a sine wave',n))
	set(gca,'XTickLabel',[],'YTickLabel',[])
	grid




	%Use a function handle (not an anonymous function) to calculate the mean of each vector in a cell array
	r = {rand(1,30), randn(1,150)*100, rand(1,1000)};
	fprintf('\nThe contents of cell array "r" are:\n')
	disp(r)


	fprintf('Use cellfun and a function handle to calculate the mean of each vector in "r":\n' );
	disp(cellfun(@mean,r))


	fprintf('Use cellfun and an anonymous function to calculate 1.96 SD of each each vector in "r":\n' );

	SD95 = @(x) (std(x)*1.96);

	disp(cellfun(SD95,r))


