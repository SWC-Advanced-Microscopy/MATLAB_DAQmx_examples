classdef simpleOOexample < handle

	% This file defines a simple example class called "simpleOOexample"
	%
	% You can use it as follows:
	%
	% Create an instance of the class:
	% >> EG = simpleOOexample;
	%
	% Run the "displayProperty" method to print nicely to screen what is in the 
	% property "exampleProperty":
	% >> EG.displayProperty
	%
	%
	% Run the "plotProperty" method to make a line plot of this property:
	% property "exampleProperty"
	% >> EG.plotProperty
	%
	%
	% Advanced info:
	% This class inherits the built-in "handle" abstract class. The handle
	% class has some useful properties that are described here:
	% http://uk.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html
	% Our simple scanning software will also inherit handle. 
	% If you are not already familiar with references and objects, then the reasons
	% are not important right now. For those who are familiar: objects that inherit
	% handle return a *reference* to the object after construction. So you can pass 
	% a copy of the reference to another function and have it modify it without 
	% creating a new copy of the object that controls the DAQ. 
	% It also allows you to create notifiers and listeners:
	% http://uk.mathworks.com/help/matlab/matlab_oop/the-handle-superclass.html
	% 
	%
	%
	%
	% Rob Campbell - Basel 2016


	properties
		exampleProperty %declare exampleProperty but don't populate it with anything
	end %close properties

	methods
		function obj=simpleOOexample
			% This method ("method" is the OO term for a function that is part of an class) is
			% special and is known as a "constructor". The constructor method has the same name
			% as the class. It is run once, when an instance of the class is created. The instance
			% is created at the command line by doing something like: EG = simpleOOexample. 
			% "EG" is an object that is an instance of class simpleOOexample
			obj.exampleProperty = randn(1,60);
			obj.exampleProperty(20:40) = obj.exampleProperty(40:60)*10;
		end %close simpleOOexample constructor


		function displayProperty(obj)
			%This method just prints the contents of the obj.exampleProperty property to screen
			fprintf('\nexampleProperty contains the vector:\n\n')
			disp(obj.exampleProperty)
		end %close displayProperty

		function plotProperty(obj)
			%This method makes a plot of obj.exampleProperty 
			clf 
			plot(obj.exampleProperty,'-k')
			hold on 
			plot(obj.exampleProperty,'ok','MarkerFaceColor',[1,1,1]*0.5)
		end %close plotProperty

	end %close methods

end %close simpleOOexample