classdef simpleOOexample < handle

    % Simple example of defining a class in MATLAB 
    % 
    % simpleOOexample.m
    % 
    % 
    % INTRODUCTION
    % This class definition file shows how to define a simple example class called "simpleOOexample".
    % The class has a single "property". Properties are variables within a class that allow data
    % to be stored and shared. The simpleOOexample class also has three "methods". A method is a
    % function that exists within a class. Methods can interact with each other and also with
    % the class properties. Go through the following instructions and try to develop an intuition
    % for how everything works. Don't worry too much about *why* we're doing things this way (rather
    % than using normal functions and variables). This will become obvious when you start working 
    % with classes to get real things done. 
    %
    % 
    % USAGE
    % 
    % Create an instance of the class:
    % >> EG = simpleOOexample;
    %
    % Confirm that EG is an instance of "simpleOOexample"
    % >> class(EG)
    % ans =
    %    simpleOOexample
    %
    %
    % Confirm that EG has one property:
    % >> properties(EG)
    % Properties for class simpleOOexample:
    %    exampleProperty
    %
    % Confirm that EG has three properties:
    % >> methods(EG)
    % Methods for class simpleOOexample:
    % displayProperty  plotProperty   simpleOOexample  
    %
    % 
    % Run the "displayProperty" method to print nicely to screen what is in the 
    % property "exampleProperty":
    % >> EG.displayProperty
    % Look in the code and satisfy yourself that you understand what you just saw.
    % Hint: where did the data come from? Look at the simpleOOexample method.
    %
    %
    % Run the "plotProperty" method to make a line plot of this property:
    % property "exampleProperty"
    % >> EG.plotProperty
    % Look in the code and satisfy yourself that you understand what you just saw.
    %
    %
    % Run:
    % >> EG.populateExamplePropertyWithData
    % >> EG.plotProperty
    % Satisfy yourself that you understand what just happened
    % 
    % 
    % ADVANCED INFO:
    % You may have noticed the peculiar "< handle" thing on the first line of this class definition. 
    % This is an advanced object-oriented programming feature that need not concern us too much for
    % the purposes of these DAQ demos and a lot of jargon has to be introduced to explain what is 
    % happening here. Briefly, this class "inherits" the built-in "handle" abstract class. 
    % The "<" symbol tells MATLAB to make simpleOOexample a "sub-class" of handle. This empowers 
    % simpleOOexample with all of the capabilities provided by the handle class. The useful properties
    % of the handle class are described here:
    % http://www.mathworks.com/help/matlab/matlab_oop/comparing-handle-and-value-classes.html
    % This makes little practical difference here, but if you use object-oriented programming to
    % do more complicated things you will likely be working with classes that inherit handle.
    % For example, our simple scanning software (https://github.com/tenss/SimpleMScanner) contains
    % classes that inherit handle. 
    %
    % For those already familiar with "references: objects that inherit handle return a *reference* 
    % to the object after construction. So you can pass a copy of the reference to another function 
    % and have it modify it without creating a new copy of the object that controls the DAQ. 
    % The handle class also allows us to create notifiers and listeners:
    % http://www.mathworks.com/help/matlab/matlab_oop/the-handle-superclass.html
    % Do not worry if all of this makes no sense right now. 
    %
    %
    % Rob Campbell - Basel 2016



    % This block declares the properties (similar variables) that are locally available 
    % to the simpleOOexample class. 

    properties %open properties block
        exampleProperty %declare exampleProperty but don't populate it with anything
    end %close properties block


    % This block contains the definitions of the methods (similar to functions) that are
    % locally available to the simpleOOexample class. A "method" is the OO term for a 
    % function that is a member of an class. 


    methods %open methods block

        function obj=simpleOOexample
            % This method is special and is known as a "constructor". The constructor method always
            % has the same name as the class. It is run once, when an instance of the class is created.
            % The instance is created at the command line by doing something like: EG = simpleOOexample. 
            % (see the instructions, above). "EG" is an object that is an instance of class simpleOOexample
            
            % Populate the exampleProperty with data by calling the method that does this
            obj.populateExamplePropertyWithData
        end %close the simpleOOexample constructor method


        function populateExamplePropertyWithData(obj)
            obj.exampleProperty = randn(1,60);
            obj.exampleProperty(20:40) = obj.exampleProperty(40:60)*10;
        end %close populateExamplePropertyWithData method


        function displayProperty(obj)
            % This method just prints the contents of the obj.exampleProperty property to screen
            % Note how exampleProperty has been shared between this method and the constructor, above.
            fprintf('\nexampleProperty contains the vector:\n\n')
            disp(obj.exampleProperty)
        end %close displayProperty method


        function plotProperty(obj)
            %This method makes a plot of obj.exampleProperty 
            clf 
            plot(obj.exampleProperty,'-k')
            hold on 
            plot(obj.exampleProperty,'ok','MarkerFaceColor',[1,1,1]*0.5)
        end %close plotProperty method

    end %close methods block


end %close simpleOOexample classdef
