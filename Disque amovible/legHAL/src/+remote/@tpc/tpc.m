% REMOTE.TPC (COMMON.REMOTEOBJ)
%   Create a REMOTE.TPC instance.
%
%   OBJ = REMOTE.TPC() creates a generic REMOTE.TPC instance.
%
%   OBJ = REMOTE.TPC(NAME, DESC, DEBUG) creates a REMOTE.TPC instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.TPC(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TPC instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - IMGVOLTAGE (single) sets maximum imaging voltage.
%       [10 80] V - default = 10
%     - PUSHVOLTAGE (single) sets maximum push voltage.
%       [10 80] V - default = 10
%     - IMGCURRENT sets maximum imaging current.
%       [0 2] A - default = 0.1
%     - PUSHCURRENT sets maximum push current.
%       [0 20] A - default = 0.1
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.TPC.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.TPC.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.TPC.
%     - GETPARAM retrieves the value/object of a REMOTE.TPC parameter.
%     - SETPARAM sets the value of a REMOTE.TPC parameter.
%     - ISEMPTY checks if all REMOTE.TPC parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.TPC and its superclass
%   COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

classdef tpc < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 6; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.TPC
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = tpc(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'TPC', ...
                    'default power control', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'TPC', ...
                'default power control', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end