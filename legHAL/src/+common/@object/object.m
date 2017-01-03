% COMMON.OBJECT
%   Create a COMMON.OBJECT instance.
%
%   OBJ = COMMON.OBJECT() returns the authorized syntaxes.
%
%   OBJ = COMMON.OBJECT(NAME, DESC, DEBUG) creates an COMMON.OBJECT instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = COMMON.OBJECT(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   COMMON.OBJECT instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the class COMMON.OBJECT.
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the class COMMON.OBJECT.
%     - ADDPARAM adds a parameter (explicit definition and cell array
%       definition) to the class COMMON.OBJECT.
%     - GETPARAM retrieves the value/object of a COMMON.OBJECT parameter.
%     - SETPARAM sets the value of a COMMON.OBJECT parameter.
%     - ISEMPTY checks if all COMMON.OBJECT parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagineand without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

classdef object
   
% ============================================================================ %
% ============================================================================ %

%% General variables (protected value)
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    Name % name of the parameter
    Type % class of the object
    Desc % description of the object
    
end

% ============================================================================ %

% General variables (protected value/access)
properties ( SetAccess = 'protected', GetAccess = 'protected' )
    
    Pars     = {}; % parameters
    
end

% ============================================================================ %

% Debug variables
properties ( SetAccess = 'public', GetAccess = 'public' )
    
    Debug = 0; % parameter to show debug info
    
end

% ============================================================================ %
% ============================================================================ %

%% Inline protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    % Authentification key generation
    function Key = validation(obj)
        Key = [];
        if ( isa(obj, 'common.remoteobj') )
            while ( length(unique(Key)) ~= 5 )
                Key = repmat(rand(1, 5), [1 3]);
            end
        end
    end
    
    % Warning messages
    function WarningMessage( obj, WarnMsg )
        if strcmp( common.legHAL.WarningType, 'text' )
            warning( WarnMsg )
        elseif strcmp( common.legHAL.WarningType, 'popup' )
            obj.WarningMessage( WarnMsg )
        else
            error('Unknown warning method')
        end
    end
end
    
% ============================================================================ %

%% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % builds class COMMON.OBJECT
    varargout = addParam(obj, varargin)  % add a new parameter
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    help(obj)
    
    % Parameter related functions
    varargout = isParam(obj, varargin)  % check if PARSNAME are parameter names
    varargout = getParam(obj, varargin) % retrieve the value of PARNAME
    varargout = setParam(obj, varargin) % set the value of PARSNAME to PARSVALUE
    
    % Object related functions
    varargout = isempty(obj, varargin)  % check if COMMON.OBJECT is correctly defined
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = object(varargin)
        
        % Initialization
        obj = obj.initialize(varargin{1:end});
        
        % Set parameters if any are given
        if ( (nargin > 2) && (rem(nargin, 2) == 0) )
            
            obj = obj.setParam(varargin{3:end});
            
        elseif ( nargin > 3 )
            
            obj = obj.setParam(varargin{3:end-1});
            
        end
        
    end
end

% ============================================================================ %
% ============================================================================ %

end