% COMMON.OBJECT.GETPARAM (PUBLIC)
%   Retrieve the value of a parameter/object of the COMMON.OBJECT object.
%
%   PARAM = OBJ.GETPARAM(PARAMNAME) returns the parameter/object PARAMNAME of
%   the COMMON.OBJECT instance.
%
%   Note - This function is defined as a method of the class COMMON.OBJECT. It
%   cannot be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function Param = getParam(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' getParam function only requires 1 ' ...
        'argument:\n' ...
        '    1. the parameter name.'];
    error(ErrMsg);
    
elseif ( nargin > 2 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getParam function only requires 1 ' ...
        'argument:\n' ...
        '    1. the parameter name.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve the parameter value

% Initialize
ParName = varargin{1};

% Test the parameter name existence
if size( obj.Pars, 1 ) == 0    
    Idx = [];

else
    Idx = find( strcmp( obj.Pars(:,1), ParName ), 1, 'first' );

end

% ============================================================================ %

% Retrieve value
if ( ~isempty(Idx) )
    
    Par = obj.Pars(Idx, 3);
    
    if ( isa(Par{1}, 'common.parameter') )
        
        if ( isempty(Par{1}.Value) ) % parameter is empty
            ErrMsg = ['The parameter ' upper(ParName) ' is empty.'];
            error(ErrMsg);
        else                 % parameter is not empty
            Param = Par{1}.Value;
        end
        
    else
        
        if ( isempty(Par{1}) )
            ErrMsg = ['The parameter ' upper(ParName) ' is empty.'];
            error(ErrMsg);
        else                % cell is not empty
            Param = Par{1};
        end
        
    end
    
else
    
    % Return error
    ErrMsg = ['The parameter ' ParName ' does not belong to the ' ...
        'current ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'getParam');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end