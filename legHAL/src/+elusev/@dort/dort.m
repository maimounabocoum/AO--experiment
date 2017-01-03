% ELUSEV.DORT (ELUSEV.ELUSEV)
%   Create an ELUSEV.DORT instance.
%
%   OBJ = ELUSEV.DORT() creates a generic ELUSEV.DORT instance.
%
%   OBJ = ELUSEV.DORT(DEBUG) creates a generic ELUSEV.DORT instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ELUSEV.DORT(NAME, DESC, DEBUG) creates an ELUSEV.DORT instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = ELUSEV.DORT(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ELUSEV.DORT instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - WAVEFORM (single) sets the waveforms.
%       [-1 1]
%     - PAUSE (int32) sets the pause duration after DORT events.
%       [system.hardware.MinNoop 1e6] us
%     - PAUSEEND (int32) sets the pause duration at the end of the ELUSEV.
%       [system.hardware.MinNoop 1e6] us
%     - DUTYCYCLE (single) sets the waveform duty cycle.
%       [0 1]
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
%     - RXDURATION (single) sets the acquisition duration.
%       [0 1000] us
%     - RXDELAY (single) sets the acquisition delay.
%       [0 1000] us
%     - RXBANDWIDTH (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50% - default = 1
%     - FIRBANDWIDTH (int32) sets the digital filter coefficients.
%       -1 = none, [0 100] = pre-calculated- default = 100
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
%     - INITIALIZE builds the remoteclass ELUSEV.DORT.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ELUSEV.DORT.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ELUSEV.DORT.
%     - GETPARAM retrieves the value/object of a ELUSEV.DORT parameter.
%     - SETPARAM sets the value of a ELUSEV.DORT parameter.
%     - ISEMPTY checks if all ELUSEV.DORT parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ELUSEV.DORT and its
%   superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/12/02

classdef dort < elusev.elusev
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass ELUSEV.DORT
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = dort(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'DORT', ...
                            'default DORT elementary ultrasound events', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'DORT', ...
                        'default DORT elementary ultrasound events', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@elusev.elusev(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end