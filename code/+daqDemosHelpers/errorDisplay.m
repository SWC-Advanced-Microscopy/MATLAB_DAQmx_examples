function errorDisplay(ME)
    % Neatly display a caught error message
    % 
    % function daqDemosHelpers.errorDisplay(ME)
    %
    % 
    % Purpose
    % We don't want to rethrow errors, but we do want to know what they
    % are. This funcion displays a MATLAB error message structure to 
    % the command line. 
    %
    % 
    % Inputs
    % ME - MATLAB error structure
    %
    % Outputs
    % none
    %
    %
    % Example usage
    % In a function you might do:
    %
    %  try
    %     %stuff here
    %  catch ME
    %     %stuff here
    %     daqDemosHelpers.errorDisplay(ME)
    %  end
    %
    %
    %
    %  Rob Campbell - Basel, 2017
    %
    % Also see: rethrow, dbstack, assert


    %Print error to the command line

    fprintf('ERROR: %s\n',ME.message)
    for ii=1:length(ME.stack)
        fprintf(' on line %d of %s\n', ME.stack(ii).line,  ME.stack(ii).name)
    end
    fprintf('\n')
