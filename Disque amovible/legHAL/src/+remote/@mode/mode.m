% REMOTE.MODE (COMMON.REMOTEOBJ)
%   Create a REMOTE.MODE instance.
%
%   OBJ = REMOTE.MODE() creates a generic REMOTE.MODE instance.
%
%   OBJ = REMOTE.MODE(NAME, DESC, DEBUG) creates a REMOTE.MODE instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.MODE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.MODE instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - NBHOSTBUFFER (int32) sets the number of host buffers.
%       [1 20]
%     - MODERX (int32) describes the rx of the mode (numSamples+rxId).
%       [0 Inf]
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.MODE.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.MODE.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.MODE.
%     - GETPARAM retrieves the value/object of a REMOTE.MODE  parameter.
%     - SETPARAM sets the value of a REMOTE.MODE parameter.
%     - ISEMPTY checks if all REMOTE.MODE parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.MODE and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/02

classdef mode < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 4; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.MODE
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = mode(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'Mode', ...
                    'default mode', ...
                    varargin{1:end}};
            else

            end
        else
            varargin = { ...
                'Mode', ...
                'default mode', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end