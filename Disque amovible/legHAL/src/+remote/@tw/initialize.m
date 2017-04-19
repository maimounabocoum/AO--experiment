% REMOTE.TW.INITIALIZE (PROTECTED)
%   Create a REMOTE.TW instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TW instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TW instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TW instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
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
%   Note - This function is defined as a method of the remoteclass REMOTE.TW. It
%   cannot be used without all methods of the remoteclass REMOTE.TW and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tw';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Number of waveform repetitions (default = 0)
Par = common.remotepar( ...
    'repeat', ...
    'int32', ...
    'sets the number of waveform repetitions', ...
    {0 [1 1023]}, ...
    {'no repetition', 'number of waveform repetition'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% 256 repetitions mode (default = 0)
Par = common.remotepar( ...
    'repeat256', ...
    'int32', ...
    'enables the 256-repetitions mode', ...
    {0 1}, ...
    {'no 256-repetitions mode' '256-repetitions mode'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Apodisation function (default = 'none')
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
Par = Par.setValue('none');
obj = obj.addParam(Par);

% ============================================================================ %

% Transmit elements list
Par = common.parameter( ...
    'TxElemts', ...
    'int32', ...
    'sets the TX channels', ...
    {[1 system.probe.NbElemts]}, ...
    {'id of the TX channels'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Duty cycle limit
Par = common.parameter( ...
    'DutyCycle', ...
    'single', ...
    'sets the maximum duty cycle', ...
    {[0 1]}, ...
    {'maximum duty cycle'}, ...
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