% COMMON.OBJECT.ADDPARAM (PROTECTED)
%   Add a new parameter.
%
%   OBJ = OBJ.ADDPARAM(PARAM) adds the parameter/object PARAM to the
%   COMMON.OBJECT instance.
%
%   OBJ = OBJ.ADDPARAM(PARNAME, PARTYPE) adds a container PARAMNAME to the
%   COMMON.OBJECT instance containing instances of PARAMTYPE class and
%   subclasses.
%
%   Note - This function is defined as a method of the class COMMON.OBJECT. It
%   cannot be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function obj = addParam(obj, varargin)
   
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
    ErrMsg = ['The 1st use of the ' upper(class(obj)) ' addParam function ' ...
        'requires 1 argument:\n' ...
        '    1. the parameter object.\n\n\n' ...
        'The 2nd use of the ' upper(class(obj)) ' addParam function ' ...
        'requires 2 arguments:\n' ...
        '    1. the parameter name,\n', ...
        '    2. the type of content.'];
    error(ErrMsg);
    
% ============================================================================ %

% Add parameter or object
elseif ( nargin == 2 )
    
    % Retrieve data
    Par       = varargin{1};
    ParName   = Par.Name;
    ParType   = Par.Type;
    ParRemote = double(isa(Par, 'common.remotepar'));
        
% ============================================================================ %

% Add a container of parameters/objects
elseif ( nargin == 3 )
    
    % Initialize
    Par       = {};
    ParName   = varargin{1};
    ParType   = varargin{2};
    ParRemote = 0;
    
end

% ============================================================================ %
% ============================================================================ %

%% Add the new parameter

% Test the parameter name existence
if size( obj.Pars, 1 ) == 0
    Test = 0;
else
    % Logical test
    Test = sum( strcmp( obj.Pars(:,1), ParName ) );
end

if Test
    
    % Return error
    ErrMsg = ['The parameter name ' upper(ParName) ' is already used ' ...
        'for the current ' upper(class(obj)) ' object.\n\n' ...
        'Another parameter name should be used.'];
    error(ErrMsg);
    
else
    
    % Temporary variable
    Tmp = obj.Pars;
    
    % Add new parameter/object label
    Tmp{end+1, 1} = ParName;
    
    % Add new parameter/label type
    Tmp{end, 2} = ParType;
    
    % Add new parameter/label value
    Tmp{end, 3} = Par;
    
    % Add new parameter/label remote label
    Tmp{end, 4} = ParRemote;
    
    % Update the PARS variable
    obj.Pars = Tmp;
    
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'addParam');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end