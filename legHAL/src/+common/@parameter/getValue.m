% COMMON.PARAMETER.GETVALUE (PUBLIC)
%   Retrieve the value of the COMMON.PARAMETER object.
%
%   VALUE = OBJ.GETVALUE() returns the value VALUE of the COMMON.PARAMETER
%   instance.
%
%   Note - This function is defined as a method of the class COMMON.PARAMETER.
%   It cannot be used without all methods of the class COMMON.PARAMETER
%   developed by SuperSonic Imagine and without a system with a REMOTE server
%   running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/29

function varargout = getValue(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( nargin ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getValue function requires no ' ...
        'input argument.'];
    error(ErrMsg);
    
elseif ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getValue function requires an ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve the value

% Test if the parameter is defined
if ( isempty(obj.Value) )
    
    % Return error
    ErrMsg = ['The parameter ' upper(obj.Name) ' is empty.'];
    error(ErrMsg);
 
end

% ============================================================================ %

% Set the output argument
varargout{1} = obj.Value;

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'getValue');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end