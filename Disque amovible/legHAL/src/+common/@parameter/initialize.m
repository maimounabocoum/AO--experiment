% COMMON.PARAMETER.INITIALIZE (PROTECTED)
%   Create a COMMON.PARAMETER instance.
%
%   OBJ = OBJ.INITIALIZE() returns the authorized syntaxes.
%
%   OBJ = OBJ.INITIALIZE(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC) creates a
%   COMMON.PARAMETER instance with its name set to NAME, its value type to TYPE,
%   its description to DESC, its authorized values to AUTHVALUES and the
%   authorized values description to AUTHDESC.
%
%   OBJ = OBJ.INITIALIZE(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC, DEBUG) creates
%   a COMMON.PARAMETER instance with a DEBUG value (1 is enabling the debug
%   mode).
%
%   Note - This function is defined as a method of the class COMMON.PARAMETER.
%   It cannot be used without all methods of the class COMMON.PARAMETER
%   developed by SuperSonic Imagine and without a system with a REMOTE server
%   running.
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
if nargin == 1
    
    % Return error
    ErrMsg = ['The ' upper(class(obj)) ' constructor requires 5 or 6 ' ...
        'arguments:\n' ...
        '    1. the parameter name,\n', ...
        '    2. the type of input/output values,\n', ...
        '    3. the description of the parameter,\n', ...
        '    4. the accepted values,\n', ...
        '    5. the label description for each accepted values,\n', ...
        '    6. the optional debug state [0/1].'];
    error(ErrMsg);
    
% The constructor needs 4 or 5 arguments!
elseif nargin < 6 % wrong number of arguments
    
    % Return error
    ErrMsg = ['There should be more than 5 arguments and not ' num2str(nargin) ...
        ' arguments:\n' ...
        '    1. the parameter name,\n', ...
        '    2. the type of input/output values,\n', ...
        '    3. the description of the parameter,\n', ...
        '    4. the accepted values,\n', ...
        '    5. the label description for each accepted values,\n', ...
        '    6. the optional debug state [0/1].'];
    error(ErrMsg);
    
% The DEBUG variable is set to a new value
elseif nargin >= 7
    
    if isnumeric(varargin{6})
        
        % Sets the value of the DEBUG variable
        obj.Debug = int32(varargin{6} == 1);
        
    else
        
        % Return error
        ErrMsg = 'A 6th argument value of 1 sets on the DEBUG MODE.';
        error(ErrMsg);
        
    end
    
end

if nargin >= 8
    if ischar( varargin{7} )
        obj.ParClass = varargin{7};
    end
end


% ============================================================================ %
% ============================================================================ %

%% Set NAME variable (string)

if ischar(varargin{1})

    obj.Name = varargin{1};
    
else
    
    % Return error
    ErrMsg = ['The 1st argument is the name of the parameter. It should ' ...
        'be a CHAR value.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Set TYPE variable

if ( ~ischar(varargin{2}) )
    
    % Return error
    ErrMsg = ['The 2nd argument should be a CHAR value corresponding to ' ...
        'the name of an existing class'];
    error(ErrMsg);
    
elseif ( exist(varargin{2}, 'class') ~= 8 )
    
    % Return error
    ErrMsg = ['The 2nd argument should correspond to an existing class ' ...
        '(numeric or string). The ' upper(varargin{2}) ' class does not ' ...
        'exist.'];
    error(ErrMsg);

else
    
    obj.Type = varargin{2};
    
end

% ============================================================================ %
% ============================================================================ %

%% Set DESC variable

if ( ~ischar(varargin{3}) )
    
    % Return error
    ErrMsg = ['The 3rd argument should be a CHAR value corresponding to a ' ...
        'description of the parameter'];
    error(ErrMsg);
    
else
    
    obj.Desc = varargin{3};
    
end

% ============================================================================ %
% ============================================================================ %

%% Set AUTHVALUES and AUTHDESC variables

% Compare the size of AUTHVALUES and AUTHDESC variables
if ( ~iscell(varargin{4}) )
    
    % Return error
    ErrMsg = ['The 4th argument (authorized values) should be defined as a ' ...
        'cell array.'];
    error(ErrMsg);
    
elseif ( ~iscell(varargin{5}) )
    
    % Return error
    ErrMsg = ['The 5th argument (description of authorized values) should ' ...
        'be defined as a cell array.'];
    error(ErrMsg);
    
elseif ( length(varargin{4}) ~= length(varargin{5}) )
    
    % Return error
    ErrMsg = ['There should be the same number of authorized values ' ...
        '(4th argument) and description tags (5th argument).'];
    error(ErrMsg);

end

% ============================================================================ %

% Control the authorize values
for k = 1 : length(varargin{4})
    tmp = str2func(obj.Type);
    
    if ( isnumeric(tmp([])) && ~isnumeric(varargin{4}{k}) )
        
        % Return error
        ErrMsg = ['The 4th argument (authorized values) should be numeric ' ...
            'as the TYPE is ' obj.Type ' class.'];
        error(ErrMsg);
        
    elseif ( ischar(tmp([])) && ~ischar(varargin{4}{k}) )
        
        % Return error
        ErrMsg = ['The 4th argument (authorized values) should be CHAR ' ...
            'values as the TYPE is ' obj.Type ' class.'];
        error(ErrMsg);
        
    elseif ( isnumeric(tmp([])) )
        
        if ( length(varargin{4}{k}) == 2 ) % range of authorized values
            varargin{4}{k} = sort(varargin{4}{k});
            obj.AuthRange{k} = 1;
        else                               % single authorized value
            obj.AuthRange{k} = 0;
        end
        
    elseif ( ischar(tmp([])) )
        
        obj.AuthRange{k} = 0; % single authorized value
        
    else
        
        % Return error
        ErrMsg = ['The 4th argument (authorized values) should only belong ' ...
            'to ' obj.Type ' class.'];
        error(ErrMsg);
        
    end
    
end
obj.AuthValues = varargin{4};

% ============================================================================ %

% Control the description tags
for k = 1 : length(varargin{5})
    if ( ~ischar(varargin{5}{k}) )
        
        % Return error
        ErrMsg = ['The 5th argument (description tags) should only contain ' ...
            'CHAR values.'];
        error(ErrMsg);
        
    end
end
obj.AuthDesc = varargin{5};

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