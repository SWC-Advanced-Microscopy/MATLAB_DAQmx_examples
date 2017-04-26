function nestedFunctionExample
    % Example - shows how nested functions work in MATLAB
    %
    % function nestedFunctionExample
    %
    % Purpose
    % You can use sub-functions to avoid repeating the same lines of code
    % several times. There are two types of sub-function:
    % a) Those "nested" within the main function that share the same *scope*
    %    as the main function. "Scope" defines the region of code within which
    %    a variable is visible. Nesting functions is a nice alternative to 
    %    using "global"
    % b) Those that are not nested within the main function and do not share
    %    the same scope. 
    % Both types of sub-function are only accesible by the main function.
    %
    % In this case, "nestedFunctionExample" is the main function and it contains
    % two nested functions and one non-nested function. 
    %
    %
    %
    % Instructions
    % Run this function at the command line then read through the code and 
    % satisfy yourself that you understand what was printed to screen. 
    %
    %
    % More info:
    % https://www.mathworks.com/help/matlab/matlab_prog/nested-functions.html
    %
    %
    % Rob Campbell - Basel 2016



    
    myVariable =123;

    fprintf('\nmyVariable is %d in the main function body\n',myVariable)


    % Call a function nested within the main function. This function has no input
    % arguments and is defined below. 
    myNestedFunction 


    % Run a different nested function that changes the value of myVariable and show that 
    % this propagates back to the main function body
    fprintf('\nRunning "myNestedFunctionThatChangesStuff" ')
    myNestedFunctionThatChangesStuff
    fprintf('myVariable is now %d in the main function body\n',myVariable)


    % Run the non-nested function "myNonNestedFunction" and show that it has a different scope
    % to the main function body
    fprintf('\nRunning "myNonNestedFunction", which assigns a different value to myVariable\n')
    myNonNestedFunction(myVariable)
    fprintf('myVariable is STILL %d in the main function body\n\n',myVariable)





    %--------------------------------------------------------------------------------------
    % nested sub-functions follow
    function myNestedFunction
        %This function is nested within the main function and so has access to "myVariable"
        fprintf('myVariable is %d in the nested "myNestedFunction"\n',myVariable)
    end %close myNestedFunction


    function myNestedFunctionThatChangesStuff
        %This function is nested within the main function and so has access to "myVariable"
        myVariable = 456;
    end %close myNestedFunction
    %--------------------------------------------------------------------------------------


end %close nestedFunctionExample



%--------------------------------------------------------------------------------------
% non-nested sub-functions follow
function myNonNestedFunction(myVariable)
    %This function does not share the same scope as the main function body
    myVariable=myVariable+9999;
    fprintf('myVariable is %d in the non-nested "myNonNestedFunction"\n',myVariable)
end
%--------------------------------------------------------------------------------------
