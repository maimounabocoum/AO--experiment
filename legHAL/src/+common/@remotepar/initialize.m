% COMMON.REMOTEPAR.INITIALIZE (PROTECTED)
%   Create a COMMON.REMOTEPAR instance.
%
%   OBJ = COMMON.INITIALIZE() returns the authorized syntaxes.
%
%   OBJ = OBJ.INITIALIZE(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC) creates a
%   COMMON.REMOTEPAR instance with its name set to NAME, its value type to TYPE,
%   its description to DESC, its authorized values to AUTHVALUES and the
%   authorized values description to AUTHDESC.
%
%   OBJ = OBJ.INITIALIZE(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC, DEBUG) creates
%   a COMMON.REMOTEPAR instance with a DEBUG value (1 is enabling the debug
%   mode).
%
%   Note - This function is defined as a method of the class COMMON.REMOTEPAR.
%   It cannot be used without all methods of the class COMMON.REMOTEPAR and the
%   superclass COMMON.PARAMETER developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Initialization of the parameter
obj = initialize@common.parameter(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Control over the data type

% Data should be numeric
tmp = str2func(varargin{2});
if ( ~isnumeric(tmp([])) )
    
    % Return error
    ErrMsg = ['Remote parameters are numeric parameters. It cannot be ' ...
        'a ' upper(varargin{2}) ' object.'];
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