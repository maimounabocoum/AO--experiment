% ELUSEV.PUSH (ELUSEV.ELUSEV)
%   Create an ELUSEV.PUSH instance.
%
%   OBJ = ELUSEV.PUSH() creates a generic ELUSEV.PUSH instance.
%
%   OBJ = ELUSEV.PUSH(DEBUG) creates a generic ELUSEV.PUSH instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ELUSEV.PUSH(NAME, DESC, DEBUG) creates an ELUSEV.PUSH instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = ELUSEV.PUSH(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ELUSEV.PUSH instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TWFREQ (single) sets the push emission frequency.
%       [1 20] MHz
%     - PUSHDURATION (single) sets the push emission duration.
%       [1 300] us
%     - DURATION (single) sets the push event duration.
%       [5 1000] us
%     - DUTYCYCLE (single) sets the maximum duty cycle.
%       [0 1]
%     - POSX (single) sets the focus lateral position.
%       [0 100] mm
%     - POSZ (single) sets the focus axial position.
%       [0 100] mm
%     - TXCENTER (single) sets the emitting center position.
%       [0 100] mm
%     - RATIOFD (single) sets the ration F/D.
%       [0 1000]
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch
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
%     - INITIALIZE builds the remoteclass ELUSEV.PUSH.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ELUSEV.PUSH.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ELUSEV.PUSH.
%     - GETPARAM retrieves the value/object of a ELUSEV.PUSH parameter.
%     - SETPARAM sets the value of a ELUSEV.PUSH parameter.
%     - ISEMPTY checks if all ELUSEV.PUSH parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ELUSEV.PUSH and its
%   superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

classdef push < elusev.elusev
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass ELUSEV.PUSH
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = push(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'PUSH', ...
                            'default push elementary ultrasound events', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'PUSH', ...
                        'default push elementary ultrasound events', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@elusev.elusev(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end