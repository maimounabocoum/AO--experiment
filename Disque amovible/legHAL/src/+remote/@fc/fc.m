% REMOTE.FC (COMMON.REMOTEOBJ)
%   Create a REMOTE.FC instance.
%
%   OBJ = REMOTE.FC(NAME, DESC, DEBUG) creates an REMOTE.FC instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.FC(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.FC instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - BANDWIDTH (int32) sets the digital filter coefficients.
%       -1 = none, [0 100] = pre-calculated - default = 100
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.FC.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.FC.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.FC.
%     - GETPARAM retrieves the value/object of a REMOTE.FC parameter.
%     - SETPARAM sets the value of a REMOTE.FC parameter.
%     - ISEMPTY checks if all REMOTE.FC parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.FC and its superclass
%   COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

classdef fc < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 1; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

%% Private property of REMOTE.FC class
properties ( SetAccess = 'private', GetAccess = 'private' )
    
    DABFilterCoeff % pre-calculated filter coefficients
    
end

% ============================================================================ %
% ============================================================================ %

%% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.FC
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = fc(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'Fc', ...
                    'default digital filter coefficients', ...
                    varargin{1:end}};
            else
%                 varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'Fc', ...
                'default digital filter coefficients', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end