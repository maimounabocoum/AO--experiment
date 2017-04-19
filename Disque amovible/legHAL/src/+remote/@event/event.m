% REMOTE.EVENT (COMMON.REMOTEOBJ)
%   Create a REMOTE.EVENT instance.
%
%   OBJ = REMOTE.EVENT() creates a generic REMOTE.EVENT instance.
%
%   OBJ = REMOTE.EVENT(NAME, DESC, DEBUG) creates a REMOTE.EVENT instance with
%   its name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.EVENT(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.EVENT instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TXID (int32) sets the transmit id.
%       0 = none, [1 Inf] - default = 0
%     - RXID (int32) sets the receive id.
%       0 = none, [1 Inf] - default = 0
%     - HVMUXID (int32) sets the HVMUX id.
%       0 = none, [1 Inf] - default = 0
%     - TPCTXE (int32) enables extended power for pushes.
%       0 = no extended power, [1 Inf] = pushes reservoir - default = 0
%     - LOCALBUFFER (int32) sets index of the local buffer.
%       [0 Inf] - default = 0
%     - DMACONTROLID (int32) sets the DMA control id.
%       0 = none, [1 Inf] - default = 0
%     - NOOP (int32) sets the dead time after event.
%       [system.hardware.MinNoop 5e5] us - default = system.hardware.MinNoop
%     - SOFTIRQ (int32) sets the soft IRQ label.
%       -1 = none, [0 Inf] = soft IRQ label - default = -1
%     - RETURN (int32) returns to calling event.
%       0 = nothing, 1 = return to calling event - default = 0
%     - GOSUBEVENTID (int32) executes a specific event.
%       0 = nothing, [1 Inf] = go to event id - default = 0
%     - WAITEXTTRIG (int32) waits for external trigger.
%       0 = no trigger in, 1 = trigger in - default = 0
%     - GENEXTTRIG (single) generates a trigger.
%       0 = no trigger out, [1e-3 720.8] us = trigger out duration - default = 0
%     - GENEXTTRIGDELAY (single) sets the trigger delay.
%       [0 1000] us = trigger out delay - default = 0
%     - DURATION (int32) sets the duration of the event.
%       0 = empty event, [1 1e7] us = event duration
%     - NUMSAMPLES (int32) sets the number of acquired samples.
%       [0 4096]
%     - SKIPSAMPLES (int32) sets the number of skipped samples.
%       [0 4096]
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.EVENT.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.EVENT.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.EVENT.
%     - GETPARAM retrieves the value/object of a REMOTE.EVENT parameter.
%     - SETPARAM sets the value of a REMOTE.EVENT parameter.
%     - ISEMPTY checks if all REMOTE.EVENT parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.EVENT and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

classdef event < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 23; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.EVENT
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = event(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'Event', ...
                    'default event', ...
                    varargin{1:end}};
            else
%                 varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'Event', ...
                'default event', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end