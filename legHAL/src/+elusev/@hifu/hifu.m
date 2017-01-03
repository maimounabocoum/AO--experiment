% ELUSEV.HIFU (ELUSEV.ELUSEV)
%   Create an ELUSEV.HIFU instance.
%
%   OBJ = ELUSEV.HIFU() creates a generic ELUSEV.HIFU instance.
%
%   OBJ = ELUSEV.HIFU(DEBUG) creates a generic ELUSEV.HIFU instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ELUSEV.FLAT(NAME, DESC, DEBUG) creates an ELUSEV.HIFU instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = ELUSEV.FLAT(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ELUSEV.HIFU instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TWFREQ (single) sets the HIFU emission frequency.
%       [0.5 4] MHz
%     - TWDURATION (single) sets the HIFU emission duration.
%       [1e3 1e6] us
%     - TXELEMTS (int32) sets the emitting elements.
%       [1 system.probe.NbElemts]
%     - PHASE (single) sets the HIFU emission phase offsets.
%       [0 2*pi] rad
%     - DUTYCYCLE (single) sets the maximum duty cycle.
%       [0 0.9]
%     - RXFREQ (single) sets the sampling frequency.
%       [0 60] MHz
%     - RXDURATION (single) sets the acquisition duration.
%       0 = no acquisition, [1 1e5] us
%     - RXELEMTS (int32) sets the reception elements.
%       0 = no acquisition, [1 system.probe.NbElemts]
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
%     - INITIALIZE builds the remoteclass ELUSEV.HIFU.
%     - BUILDCAVITATION builds the cavitation events.
%     - BUILDEMISSION builds the emission events.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ELUSEV.HIFU.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ELUSEV.HIFU.
%     - GETPARAM retrieves the value/object of a ELUSEV.HIFU parameter.
%     - SETPARAM sets the value of a ELUSEV.HIFU parameter.
%     - ISEMPTY checks if all ELUSEV.HIFU parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ELUSEV.HIFU and its
%   superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/11

classdef hifu < elusev.elusev
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin)       % build remoteclass ELUSEV.HIFU
    varargout = buildCavitation(obj, varargin) % build the cavitation events
    varargout = buildEmission(obj, varargin)   % build the emission events
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = hifu(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'HIFU', ...
                            'default HIFU elementary ultrasound events', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'HIFU', ...
                        'default HIFU elementary ultrasound events', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@elusev.elusev(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end