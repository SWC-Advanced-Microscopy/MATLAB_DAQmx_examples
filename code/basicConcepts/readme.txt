Basic Concepts ReadMe

The functions under this directory introduce basic MATLAB concepts that 
crop up in the data acquisition examples but are also of more general use. 


Instructions
Open each file in an editor. Read through it then run it. A suggested order
is provided below. Skip content you understand. 



The following examples show more advanced ways of working with functions. For example, 
how to end functions in graceful ways and how to call functions using function handles. 

trappingErrors.m         -  Demonstrates the use of try/catch for trapping errors
nestedFunctionExample.m  -  Shows how nested functions work in MATLAB.
cleanUp                  -  how to run arbitrary code when your function ends (includes nested 
                            functions and try/catch blocks).
anonymousFunctionExample -  How to use anonymous functions and function handles in MATLAB.
windowCloseFunction      -  Uses an anonymous function and basic object-oriented programming to 
                            change what happens when a figure window is closed.



The following examples show object-oriented programming. They demonstrate how a simple class 
is defined and used in MATLAB. Programming GUIs and DAQ tasks is often more natural using classes. 
Before proceeding with these examples read this page: 
https://www.mathworks.com/help/matlab/matlab_oop/why-use-object-oriented-design.html
The goal of the following examples is simply to give you an overview of what object-oriented 
programming is about. There might be a lot to digest if you have not seen this stuff before. 
Try to focus on how the class definition files are laid out and what is happening in the 
different sections of the class definition. Keep in mind that that the purpose of these 
class files is to define the behavior of an interactive code+data object that will exist in 
the base workspace. 

simpleOOexample  -  How to build and work with a simple class
listenerExample  -  Uses a notifier, listener, and a callback function to more elegantly perform 
                    the operations introduced in simpleOOexample.

Those examples are somewhat abstract and it may not be clear what advantage object-oriented programming provides. 
The following example illustrates a simple use case that would be hard to create without OO:

streamingPlotter  - Build a "streaming" line plot with properties that can be modified as it runs
