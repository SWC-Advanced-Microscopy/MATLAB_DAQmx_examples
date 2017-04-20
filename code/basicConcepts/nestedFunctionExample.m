function nestedFunctionExample
    % Example - shows how nested functions work in MATLAB
    %
    % function nestedFunctionExample
    %
    % Purpose
    % sub-functions nested within the main function share the same *scope*
    % as the main function. "Scope" defines the region of code within which
    % a variable is visible. Nesting functions is a nice alternative to 
    % using "global"
    %
    %
    % Rob Campbell - Basel 2016
    %


    myVariable =123;

    fprintf('\nmyVariable is %d in the main function body\n',myVariable)

    myNestedFunction %Note no input arguments


    % Run a different nested function that changes the value of myVariable and show that 
    % this propagates back to the main function body
    fprintf('\nRunning "myNestedFunctionThatChangesStuff" ')
    myNestedFunctionThatChangesStuff
    fprintf('myVariable is now %d in the main function body\n',myVariable)


    % Run the non-nested function "myNonNestedFunction" and show that it has a different scope
    % to the main function body
    % this propagates back to the main function body
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



end %close nestedFunctionExample



%--------------------------------------------------------------------------------------
% non-nested sub-functions follow
function myNonNestedFunction(myVariable)
    %This function does not share the same scope as the main function body
    myVariable=myVariable+9999;
    fprintf('myVariable is %d in the non-nested "myNonNestedFunction"\n',myVariable)
end