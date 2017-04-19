% REMOTE.TW_ARBITRARY.INITIALIZE (PROTECTED)
%   Create a REMOTE.TW_ARBITRARY instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TW_ARBITRARY instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TW_ARBITRARY
%   instance with its name and description values set to NAME and DESC
%   (character values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TW_ARBITRARY instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - WAVEFORM (single) sets the waveform for each channels.
%       [-1 1] - default = 0
%     - REPEATCH (int32) enables the waveform repetition for each channels.
%       0 = waveform defined for all, 1 = waveform to be repeated - default = 1
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
%   REMOTE.TW_ARBITRARY. It cannot be used without all methods of the
%   remoteclass REMOTE.TW_ARBITRARY and all methods of its superclass REMOTE.TW
%   developed by SuperSonic Imagine and without a system with a REMOTE server
%   running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/28

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tw_arbitrary';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize REMOTE.TW superclass
obj = initialize@remote.tw(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Waveform definition (default = 0)
Par = common.parameter( ...
    'Waveform', ...
    'single', ...
    'sets the waveform for each channels', ...
    {[-1 1]}, ...
    {'waveform data'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Repeat waveform for each channels (default = 1)
Par = common.parameter( ...
    'RepeatCH', ...
    'int32', ...
    'enables the waveform repetition for each channels', ...
    {0 1}, ...
    {'waveform defined for each channels', ...
        'waveform repeated for each channels'}, ...
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