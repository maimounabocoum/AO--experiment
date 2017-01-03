% ELUSEV.PUSH.INITIALIZE (PROTECTED)
%   Build the remoteclass ELUSEV.PUSH.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ELUSEV.PUSH instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ELUSEV.PUSH instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ELUSEV.PUSH instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
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
%   Note - This function is defined as a method of the remoteclass ELUSEV.PUSH.
%   It cannot be used without all methods of the remoteclass ELUSEV.PUSH and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.push';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize superclass
obj = initialize@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Push emission frequency
Par = common.parameter( ...
    'TwFreq', ...
    'single', ...
    'sets the push emission frequency', ...
    {[1 system.hardware.MaxTxFreq]}, ...
    {'push emission frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Push emission duration
Par = common.parameter( ...
    'PushDuration', ...
    'single', ...
    'sets the push emission duration', ...
    {[1 300]}, ...
    {'push emission duration [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Push event duration
Par = common.parameter( ...
    'Duration', ...
    'single', ...
    'sets the push event duration', ...
    {[5 1000]}, ...
    {'push event duration [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Maximum duty cycle
Par = common.parameter( ...
    'DutyCycle', ...
    'single', ...
    'sets the maximum duty cycle', ...
    {[0 1]}, ...
    {'maximum duty cycle'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Lateral position of the focus
Par = common.parameter( ...
    'PosX', ...
    'single', ...
    'sets the focus lateral position', ...
    {[0 100]}, ...
    {'lateral position [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Axial position of the focus
Par = common.parameter( ...
    'PosZ', ...
    'single', ...
    'sets the focus axial position', ...
    {[0 100]}, ...
    {'axial position [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Aperture center position
Par = common.parameter( ...
    'TxCenter', ...
    'single', ...
    'sets the emitting center position', ...
    {[0 100]}, ...
    {'aperture center position [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Ratio F/D
Par = common.parameter( ...
    'RatioFD', ...
    'single', ...
    'sets the ratio F/D', ...
    {[0 1000]}, ...
    {'ratio F/D'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Apodisation function
Par = common.parameter( ...
    'ApodFct', ...
    'char', ...
    'sets the apodisation function', ...
    {'none' 'bartlett' 'blackman' 'connes' 'cosine' 'gaussian' 'hamming' ...
        'hanning' 'welch'}, ...
    {'no apodisation' 'bartlett function' 'blackman function' ...
        'connes function' 'cosine function' 'gaussian function' ...
        'hamming function' 'hanning function' 'welch function'}, ...
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