% REMOTE.TW_PULSE.INITIALIZE (PROTECTED)
%   Create a REMOTE.TW_PULSE instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TW_PULSE instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TW_PULSE instance
%   with its name and description values set to NAME and DESC (character
%   values) using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TW_PULSE instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TWFREQ (single) sets the waveform frequency.
%       [0 20] MHz
%     - NBHCYCLE (int32) sets the number of half cycle.
%       [0 60]
%     - POLARITY (int32) sets the waveform polarity.
%       -1 = negative 1st arch, 1 = positive 1st arch - default = 1
%     - TXCLOCK180MHZ (int32) sets the waveform sampling rate.
%       0 = 90-MHz sampling, 1 = 180-MHz sampling - default = 1
%       
%   Inherited parameters:
%     - REPEAT (int32) sets the number of waveform repetitions.
%       0 = no repetition, [1 1023] = number of repetition - default = 0
%     - REPEAT256 (int32) enables the 256-repetitions mode.
%       0 = none, 1 = 256-repetition mode - default = 0
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch - default = none
%     - TXELEMTS (int32) sets the TX channels.
%       [1 system.probe.NbElemts]
%     - DUTYCYLE (single) sets the maximum duty cycle.
%       [0 1]
%
%   Note - This function is defined as a method of the remoteclass
%   REMOTE.TW_PULSE. It cannot be used without all methods of the remoteclass
%   REMOTE.TW_PULSE and all methods of its superclass REMOTE.TW developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/02

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tw_pulse';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize REMOTE.TW superclass
obj = initialize@remote.tw(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Transmit frequency
Par = common.parameter( ...
    'TwFreq', ...
    'single', ...
    'sets the waveform frequency', ...
    {[0 system.hardware.MaxTxFreq]}, ...
    {'waveform frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% # of half cycles (default = 2)
Par = common.parameter( ...
    'NbHcycle', ...
    'int32', ...
    'sets the number of half cycle', ...
    {[0 floor( double( system.hardware.MaxSamples ) / ( 0.5 * system.hardware.ClockFreq/2 /system.hardware.MaxTxFreq ) ) ]}, ...
    {'number of waveform half cycle'}, ...
    obj.Debug, current_class );
Par = Par.setValue(2);
obj = obj.addParam(Par);

% ============================================================================ %

% Waveform polarity (default = 1)
Par = common.parameter( ...
    'Polarity', ...
    'int32', ...
    'sets the waveform polarity', ...
    {[-1 1]}, ...
    {'-1: negative first arch, 1: positive first arch'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
obj = obj.addParam(Par);

% ============================================================================ %

% Waveform sampling rate (default = 1)
Par = common.parameter( ...
    'txClock180MHz', ...
    'int32', ...
    'sets the waveform sampling rate', ...
    {0 1}, ...
    {'sampling rate = 90 MHz', 'sampling rate = 180 MHz'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
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
