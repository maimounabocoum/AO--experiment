% COMMON.OBJECT.ISPARAM (PUBLIC)
%   Check if PARSNAME are parameter names of the COMMON.OBJECT instance.
%
%   SUCCESS = OBJ.ISPARAM(PARSNAME, ...) returns TRUE if all parameters PARSNAME
%   belong to the COMMON.OBJECT instance.
%
%   [VARSNAME IDX] = OBJ.ISPARAM(PARSNAME, ...) returns the variable name
%   VARSNAME (PARS and OBJS) containing for each parameter PARSNAME and their
%   index IDX in the variable.
%
%   Note - This function is defined as a method of the class COMMON.OBJECT. It
%   cannot be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function varargout = isParam(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' isParam function requires at ' ...
        'least 1 argument:\n' ...
        '    1. 1st parameter name,\n' ...
        '    2. ...'];
    error(ErrMsg);
    
elseif ( (nargout < 1) && (nargout > 2) )
    
    % Return error
    ErrMsg = ['The 1st use of the ' upper(class(obj)) ' isParam function ' ...
        'requires 1 output argument:\n' ...
        '    1. the result of the test.\n\n' ...
        'The 2nd use of the ' upper(class(obj)) ' isParam function ' ...
        'requires 2 output arguments:\n' ...
        '    1. the cell array of the variable names,\n' ...
        '    2. the index position of the parameter.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Check that all ParsName are CHAR object
if ( ~iscellstr(varargin) )
        
        % Return error
        ErrMsg = 'The parameter names should be CHAR objects';
        error(ErrMsg);
        
end

% ============================================================================ %
% ============================================================================ %

%% Identify the variable and the position for each parameter

% Localize the parameters
ParsName  = varargin;
[log loc] = ismember( ParsName, obj.Pars(:,1) );

% Check if each parameters exist
if ( sum(log) ~= length(ParsName) )
    Success = false;
else
    Success = true;
end

if ( nargout == 1 ) % single output argument
    
    varargout{1} = Success;
    
else % two output arguments
    
    if ( Success )
        
        VarName(:, 1:length(loc)) = {'Pars'};
        Idx(1:length(loc)) = loc(:);
        
        % Output arguments
        varargout{1} = VarName;
        varargout{2} = num2cell(Idx);
        
    else
        
        % Return error
        ErrMsg = ['The following parameter names do not belong to the ' ...
            upper(class(obj)) ' class:\n'];
        Idx = find(log == 0);
        for k = 1 : length(Idx)
            ErrMsg = [ErrMsg '    - ' upper(ParsName{Idx(k)}) ',\n'];
        end
        ErrMsg = [ErrMsg(1:end-3) '.'];
        error(ErrMsg);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'isParam');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end