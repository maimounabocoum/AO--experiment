% ELUSEV.INIT_BLS (ELUSEV.ELUSEV)
%   Create an ELUSEV.INIT_BLS instance.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ELUSEV.FLAT instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ELUSEV.FLAT instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ELUSEV.FLAT instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   ELUSEV.FLAT instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
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
% initialize the BLS by executing a RX event
% used as work arround when emmiting only events are used after BLS startup
% can be used to setup RxFreq for stabilization purposes

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.init_bls';

% Initialize superclass
try
    obj = initialize@elusev.elusev(obj, varargin{1:end});
    
    % Flat reception frequency
    Par = common.parameter( ...
        'RxFreq', ...
        'single', ...
        'sets the sampling frequency', ...
        {[1 60]}, ...
        {'flat reception frequency [MHz]'}, ...
        obj.Debug, current_class );
    obj = obj.addParam(Par);

catch exception
    uiwait(errordlg(exception.message, exception.identifier));
end

end