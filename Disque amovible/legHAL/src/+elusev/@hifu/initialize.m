% ELUSEV.HIFU.INITIALIZE (PROTECTED)
%   Build the remoteclass ELUSEV.HIFU.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ELUSEV.HIFU instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ELUSEV.HIFU instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ELUSEV.HIFU instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
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
%       [0 1]
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
%   Note - This function is defined as a method of the remoteclass ELUSEV.HIFU.
%   It cannot be used without all methods of the remoteclass ELUSEV.HIFU and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/11

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.hifu';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize superclass
obj = initialize@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% HIFU emission frequency
Par = common.parameter( ...
    'TwFreq', ...
    'single', ...
    'sets the hifu emission frequency', ...
    {[0.5 system.hardware.MaxTxFreq]}, ...
    {'hifu emission frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% HIFU emission duration
Par = common.parameter( ...
    'TwDuration', ...
    'single', ...
    'sets the hifu emission duration', ...
    {[1 20e6]}, ...
    {'hifu emission duration [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% HIFU transmitting elements
Par = common.parameter( ...
    'TxElemts', ...
    'int32', ...
    'sets the emitting elements', ...
    {[1 system.probe.NbElemts]}, ...
    {'emitting elemts'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% HIFU phase offset
Par = common.parameter( ...
    'Phase', ...
    'single', ...
    'sets the hifu emission phase offset', ...
    {[0 2*pi]}, ...
    {'hifu phase offset [rad]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% HIFU duty cycle
Par = common.parameter( ...
    'DutyCycle', ...
    'single', ...
    'sets the hifu duty cycle', ...
    {[0 1]}, ...
    {'hifu duty cycle'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Cavitation receive frequency
Par = common.parameter( ...
    'RxFreq', ...
    'single', ...
    'sets the sampling frequency', ...
    {[0 60]}, ...
    {'sampling frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Cavitation receive duration
Par = common.parameter( ...
    'RxDuration', ...
    'single', ...
    'sets the acquisition duration', ...
    {0 [1 1e5]}, ...
    {'no cavitation reception' 'cavitation receive duration [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Cavitation receiving elements
Par = common.parameter( ...
    'RxElemts', ...
    'int32', ...
    'set the receiving elements', ...
    {0 [1 system.probe.NbElemts]}, ...
    {'no receiving elements' 'receiving elemts'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'initialize');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end