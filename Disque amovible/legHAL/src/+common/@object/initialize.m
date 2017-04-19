% COMMON.OBJECT.INITIALIZE (PROTECTED)
%   Build the remoteclass COMMON.OBJECT.
%
%   OBJ = OBJ.INITIALIZE() returns the authorized syntaxes.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an COMMON.OBJECT instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   COMMON.OBJECT instance with parameters PARSNAME set to PARSVALUE.
%
%   Note - This function is defined as a method of the class COMMON.OBJECT. It
%   cannot be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( nargin == 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' constructor requires 4 or 5 ' ...
        'arguments:\n' ...
        '    1. the object name,\n' ...
        '    2. the description of the object,\n' ...
        '    3. the name of a parameter to change,\n' ...
        '    4. the new value for the parameter,\n' ...
        '    5. ...\n' ...
        '    #. the optional debug state [0/1].\n'];
    error(ErrMsg);
    
% The constructor needs at least 2 arguments!
elseif ( nargin < 3 ) % wrong number of arguments
    
    % Return error
    ErrMsg = ['There is only one argument while it needs at least 2 ' ...
        'arguments:\n' ...
        '    1. The object name,\n' ...
        '    2. The object description.'];
    error(ErrMsg);
    
% The DEBUG variable is set to a new value
elseif ( (nargin > 3) && (rem(nargin, 2) == 0) )

    if ( isnumeric(varargin{end}) )
        
        % Sets the value of the DEBUG variable
        obj.Debug = int32(varargin{end} == 1);
        
    else
        
        % Return error
        ErrMsg = 'A last argument value of 1 sets on the DEBUG MODE.';
        error(ErrMsg);
        
    end
    
    % Update the input arguments
    varargin = {varargin{1:end-1}};
    
end

% ============================================================================ %
% ============================================================================ %

%% Set NAME variable (string)

if ( ischar(varargin{1}) )

    obj.Name = varargin{1};
    obj.Type = class(obj);
    
else
    
    % Return error
    ErrMsg = ['The 1st argument is the name of the object. It should be a ' ...
        'CHAR value.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Set DESC variable

if ( ~ischar(varargin{2}) )
    
    % Return error
    ErrMsg = ['The 2nd argument is the description of the object. It ' ...
        'should be a CHAR value.'];
    error(ErrMsg);
    
else
    
    obj.Desc = varargin{2};
    
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'initialize');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end