% REMOTE.TX.INITIALIZE (PROTECTED)
%   Create a REMOTE.TX instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TX instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TX instance with
%   its name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TX instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TXCLOCK180MHZ (int32) sets the waveform sampling rate.
%       0 = 90-MHz sampling, 1 = 180-MHz sampling - default = 1
%     - TWID (int32) sets the id of the waveform.
%       0 = none, [1 Inf] = waveform id - default = 0
%     - DELAYS (single) sets the transmit delays.
%       [0 1000] us - default = 0
%
%   Note - This function is defined as a method of the remoteclass REMOTE.TX. It
%   cannot be used without all methods of the remoteclass REMOTE.TX and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'system.lte_shi';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.object(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Imaging voltage (default = 22 V)
% imaging HV lower limit due to the current limitation issue on Tpc board (V) see HW-256
Par = common.parameter( ...
    'imagingVoltage', ...
    'single', ...
    'sets the voltage on astek power supply', ...
    {[ 22.0 39.5 ]}, ...
    {'Imaging Voltage [V]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(22);

% Add parameter to the object parameters
obj = obj.addParam(Par);

% ============================================================================ %

% Mode (power supply and relays) (default = )
Par = common.parameter( ...
    'Mode', ...
    'int32', ...
    'sets the mode of use', ...
    { -1, 0, 1, 2, 3 }, ...
    { 'user defined rails/relays', 'therapy', 'therapy_with_hydro', 'imaging', 'imaging_with_MAGNA' }, ...
    obj.Debug, current_class );
Par = Par.setValue( 0 );

% Add parameter to the object parameters
obj = obj.addParam(Par);

% ============================================================================ %

% Probe temperature alarm treshold
Par = common.parameter( ...
    'ProbeTemperatureAlarmTreshold', ...
    'single', ...
    'sets probe temperature alarm treshold', ...
    {[10 70]}, ...
    {'probe temperature alarm treshold (Celsius degrees)'}, ...
    obj.Debug, current_class );
Par = Par.setValue(50);

% Add parameter to the object parameters
obj = obj.addParam(Par);

% ============================================================================ %

% LD alarm treshold nbTx
Par = common.parameter( ...
    'ldAlarmTreshold_nbTx', ...
    'single', ...
    'sets LD alarm treshold nbTx', ...
    {[1 128]}, ...
    {'nbTx to consider for LD alarm treshold'}, ...
    obj.Debug, current_class );

Par = Par.setValue(128);

% Add parameter to the object parameters
obj = obj.addParam(Par);

% ============================================================================ %

% LD alarm treshold freq
Par = common.parameter( ...
    'ldAlarmTreshold_freq', ...
    'single', ...
    'sets LD alarm treshold frequency', ...
    {[0 4]}, ...
    {'frequency to consider for LD alarm treshold [MHz]'}, ...
    obj.Debug, current_class );

Par = Par.setValue(4);

% Add parameter to the object parameters
obj = obj.addParam(Par);

% ============================================================================ %

% interlock mask
Par = common.parameter( ...
    'ProbeInterlockMask', ...
    'int32', ...
    'set the probe interlock mask', ...
    { 0, 1, 2, 3 }, ...
    {'no interlock', 'imaging probe interlock', 'therapy probe interlock', ...
    'both interlocks'}, ...
    obj.Debug, current_class );

Par = Par.setValue(0);

% Add parameter to the object parameters
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
