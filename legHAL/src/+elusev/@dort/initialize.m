% ELUSEV.DORT.INITIALIZE (PROTECTED)
%   Build the remoteclass ELUSEV.DORT.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ELUSEV.DORT instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ELUSEV.DORT instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ELUSEV.DORT instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
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
%   Note - This function is defined as a method of the remoteclass ELUSEV.DORT.
%   It cannot be used without all methods of the remoteclass ELUSEV.DORT and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/12/02

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.dort';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

obj = initialize@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Waveform to be emitted
Par = common.parameter( ...
    'Waveform', ...
    'single', ...
    'sets the waveform', ...
    {[-1 1]}, ...
    {'waveform values'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Pause duration after arbitrary event
Par = common.parameter( ...
    'Pause', ...
    'int32', ...
    'sets the pause duration after dort events', ...
    {[system.hardware.MinNoop 1e6]}, ...
    {'pause duration after emission events [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Pause duration at the end
Par = common.parameter( ...
    'PauseEnd', ...
    'int32', ...
    'sets the pause duration at the end of the ELUSEV', ...
    {[system.hardware.MinNoop 1e6]}, ...
    {'pause duration at the end [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Duty cycle
Par = common.parameter( ...
    'DutyCycle', ...
    'single', ...
    'sets the waveform duty cycle', ...
    {[0 1]}, ...
    {'waveform duty cycle'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Reception frequency
Par = common.parameter( ...
    'RxFreq', ...
    'single', ...
    'sets the sampling frequency', ...
    {[1 60]}, ...
    {'reception frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Acquisition duration
Par = common.parameter( ...
    'RxDuration', ...
    'single', ...
    'sets the acquisition duration', ...
    {[0 1000]}, ...
    {'acquisition duration [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Acquisition delay
Par = common.parameter( ...
    'RxDelay', ...
    'single', ...
    'sets the acquisition delay', ...
    {[0 1000]}, ...
    {'acquisition delay [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Decimation mode (default = 1)
Par = common.parameter( ...
    'RxBandwidth', ...
    'int32', ...
    'set the decimation mode', ...
    {1 2 3}, ...
    {'no decimation', '100% mode', '50% mode'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
obj = obj.addParam(Par);

% ============================================================================ %

% Definition of the digital filter coefficients (default = 100)
Par = common.parameter( ...
    'FIRBandwidth', ...
    'int32', ...
    'define the digital filter coefficients', ...
    {-1 [0 100]}, ...
    {'FIR BP coeffs for impulse', 'Load pre-calculated FIR BP coeffs'}, ...
    obj.Debug, current_class );
Par = Par.setValue(100);
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