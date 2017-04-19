% ELUSEV.ARBITRARY.INITIALIZE (PROTECTED)
%   Build the remoteclass ELUSEV.ARBITRARY.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ELUSEV.ARBITRARY instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ELUSEV.ARBITRARY instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   ELUSEV.ARBITRARY instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - WAVEFORM (single) sets the waveforms.
%       [-1 1]
%     - DELAYS (single) sets the transmit delays.
%       [0 1000] us - default = 0
%     - PAUSE (int32) sets the pause duration after arbitrary events.
%       [system.hardware.MinNoop 1e6] us
%     - PAUSEEND (int32) sets the pause duration at the end of the ELUSEV.
%       [system.hardware.MinNoop 1e6]
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
%     - RXCENTER (single) sets the receive center position.
%       [0 100] mm
%     - RXWIDTH (single) sets the receive width.
%       [0 100] mm
%     - RXDURATION (single) sets the acquisition duration.
%       [0 1000] us
%     - RXDELAY (single) sets the acquisition delay.
%       [0 1000] us
%     - RXBANDWIDTH (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50% - default = 1
%     - FIRBANDWIDTH (int32)sets the digital filter coefficients.
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
%   Note - This function is defined as a method of the remoteclass
%   ELUSEV.ARBITRARY. It cannot be used without all methods of the remoteclass
%   ELUSEV.ARBITRARY and all methods of its superclass ELUSEV.ELUSEV developed
%   by SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/11/26

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.arbitrary';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize superclass
obj = initialize@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Waveform for each tx elements
Par = common.parameter( ...
    'Waveform', ...
    'single', ...
    'sets the waveforms', ...
    {[-1 1]}, ...
    {'waveform values'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Delays for each tx elements (default = 0)
Par = common.parameter( ...
    'Delays', ...
    'single', ...
    'sets the transmit delays', ...
    {[0 1000]}, ...
    {'transmit delays [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Pause duration after arbitrary event
Par = common.parameter( ...
    'Pause', ...
    'int32', ...
    'sets the pause duration after arbitrary events', ...
    {[system.hardware.MinNoop 1e6]}, ...
    {'pause duration after arbitrary events [us]'}, ...
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

% Receive center position
Par = common.parameter( ...
    'RxCenter', ...
    'single', ...
    'sets the receive center position', ...
    {[0 100]}, ...
    {'receive center position [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Receive width
Par = common.parameter( ...
    'RxWidth', ...
    'single', ...
    'set the receive width', ...
    {[0 100]}, ...
    {'receive width [mm]'}, ...
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
    obj.Debug, current_class , current_class );
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
    'sets the decimation mode', ...
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
    'sets the digital filter coefficients.', ...
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