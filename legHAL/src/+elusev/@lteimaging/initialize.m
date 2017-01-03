% ELUSEV.FLAT.LTEIMAGING (PROTECTED)
%   Build the remoteclass ELUSEV.LTEIMAGING.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ELUSEV.LTEIMAGING instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ELUSEV.LTEIMAGING instance
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ELUSEV.LTEIMAGING
%   instance with its name and description values set to NAME and DESC
%   (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   ELUSEV.LTEIMAGING instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TWFREQ (single) sets the emission frequency.
%       [1 15] MHz
%     - NBHCYCLE (int32) sets the number of half cycle.
%       [1 600]
%     - DELAYS (single) sets the delays for each transmitting elements.
%       [0 1000] us
%     - PAUSE (int32) sets the pause duration after events.
%       [system.hardware.MinNoop 1000] us
%     - DUTYCYCLE (single) sets the maximum duty cycle.
%       [0 1]
%     - TXELEMTS (int32) sets the emitting elements.
%       [1 system.probe.NbElemts]
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
%     - RXELEMTS (int32) sets the receiving elements.
%       0 = no acquisition, [1 system.probe.NbElemts]
%     - RXDURATION (single) sets the acquisition duration.
%       [0 1000] us
%     - RXDELAY (single) sets the acquisition delay.
%       [0 1000] us
%     - FIRBANDWIDTH (int32) sets the digital filter coefficients.
%       -1 = none, [0 100] = pre-calculated - default = 100
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
%   ELUSEV.LTEIMAGING. It cannot be used without all methods of the remoteclass
%   ELUSEV.LTEIMAGING and all methods of its superclass ELUSEV.ELUSEV developed
%   by SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12$
% MATLAB class method

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.lteimaging';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize superclass
obj = initialize@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Emission frequency
Par = common.parameter( ...
    'TwFreq', ...
    'single', ...
    'sets the emission frequency', ...
    {[1 system.hardware.MaxTxFreq]}, ...
    {'flat emission frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Number of half cycle
Par = common.parameter( ...
    'NbHcycle', ...
    'int32', ...
    'sets the number of half cycle', ...
    {[1 600]}, ...
    {'number of half cycle'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Delays
Par = common.parameter( ...
    'Delays', ...
    'single', ...
    'sets the delays for each transmitting elements', ...
    {[0 1000]}, ...
    {'delays [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Pause duration after flat
Par = common.parameter( ...
    'Pause', ...
    'int32', ...
    'sets the pause duration after events', ...
    {[system.hardware.MinNoop 1000]}, ...
    {'pause duration after events [us]'}, ...
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

% Transmitting elements
Par = common.parameter( ...
    'TxElemts', ...
    'int32', ...
    'sets the emitting elements', ...
    {[1 system.probe.NbElemts]}, ...
    {'emitting elemts'}, ...
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

% Flat reception frequency
Par = common.parameter( ...
    'RxFreq', ...
    'single', ...
    'sets the sampling frequency', ...
    {[1 60]}, ...
    {'reception frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Cavitation receiving elements
Par = common.parameter( ...
    'RxElemts', ...
    'int32', ...
    'sets the receiving elements', ...
    {0 [1 system.probe.NbElemts]}, ...
    {'no receiving elements' 'receiving elemts'}, ...
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
    'set the acquisition delay', ...
    {[0 1000]}, ...
    {'acquisition delay [us]'}, ...
    obj.Debug, current_class );
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