% REMOTE.HVMUX.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the REMOTE.HVMUX instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.HVMUX.
%   It cannot be used without all methods of the remoteclass REMOTE.HVMUX and
%   all methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic
%   Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/27

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check syntax
if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Build the generic COMMON.REMOTEOBJ structure
Struct = buildRemote@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Check output arguments


if ( isempty(fieldnames(Struct)) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
else
    varargout{1} = Struct;
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'buildRemote');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end