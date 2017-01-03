% ELUSEV.INIT_BLS (ELUSEV.ELUSEV)
%   Create an ELUSEV.INIT_BLS instance.
%
%   OBJ = ELUSEV.INIT_BLS() creates a generic ELUSEV.INIT_BLS instance.
%
%   OBJ = ELUSEV.INIT_BLS(DEBUG) creates a generic ELUSEV.INIT_BLS instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ELUSEV.INIT_BLS(NAME, DESC, DEBUG) creates an ELUSEV.INIT_BLS instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = ELUSEV.INIT_BLS(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ELUSEV.INIT_BLS instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%
%   Inherited parameters:
%     - TRIGIN (int32) enables the trigger in.
%       0 = no trigger in, 1 = trigger in - default = 0
%     - TRIGOUT (single) enables the trigger out.
%       0 = no trigger out, [1e-3 720.8] us = trigger out duration - default = 0
%     - TRIGOUTDELAY (single) sets the trigger out delay.
%       [0 1000] us = trigger out delay - default = 0
%     - TRIGALL (int32) enables triggers on all events.
%       0 = triggers on 1st event, 1 = triggers on all events - default = 0
%     - REPEAT (int32) sets the number of ELUSEV repetition.
%       [1 Inf] - default = 1
%
%   Inherited objects:
%     - TX contains REMOTE.TX instances.
%     - TW contains REMOTE.TW instances.
%     - RX contains REMOTE.RX instances.
%     - FC contains REMOTE.FC instances.
%     - EVENT contains REMOTE.EVENT instances.
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass ELUSEV.INIT_BLS.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ELUSEV.INIT_BLS.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ELUSEV.INIT_BLS.
%     - GETPARAM retrieves the value/object of a ELUSEV.INIT_BLS parameter.
%     - SETPARAM sets the value of a ELUSEV.INIT_BLS parameter.
%     - ISEMPTY checks if all ELUSEV.INIT_BLS parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ELUSEV.INIT_BLS and its
%   superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

% ELUSEV.INIT_BLS
% initialize the BLS by executing a minimal RX event
% used as work arround when emmiting only events are used after BLS startup

classdef init_bls < elusev.elusev
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    obj = initalize(obj, varargin) % builds the ELUSEV.INIT_BLS object
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    obj       = setValue(obj, varargin)    % set the value of the object.
    varargout = buildRemote(obj, varargin) % build the remote structure.
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = init_bls(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~strcmpi(varargin{1}, 'init_bls') )
                varargin = {'elusev', 'init_bls elusev', varargin{1:end}};
            end
        else
            varargin = {'elusev', 'init_bls elusev', varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@elusev.elusev(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end