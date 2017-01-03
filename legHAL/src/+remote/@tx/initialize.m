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

current_class = 'remote.tx';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Waveform sampling rate (default = 1)
Par = common.remotepar( ...
    'txClock180MHz', ...
    'int32', ...
    'sets the waveform sampling rate', ...
    {0 1}, ...
    {'sampling rate = 90 MHz', 'sampling rate = 180 MHz'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
obj = obj.addParam(Par);

% ============================================================================ %

% Id of the waveform (default = 0)
Par = common.remotepar( ...
    'twId', ...
    'int32', ...
    'sets the id of the waveform', ...
    {0 [1 Inf]}, ...
    {'no waveform', 'id of the waveform'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Delays for each tx elements (default = 0)
Par = common.remotepar( ...
    'Delays', ...
    'single', ...
    'sets the transmit delays', ...
    {[0 1000]}, ...
    {'transmit delays [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% TimeOfFlightToFocalPoint
Par = common.remotepar( ...
    'tof2Focus', ...
    'single', ...
    'sets the time of flight to focal point from the time origin of transmit', ...
    {[0 100]}, ...
    {'time of flight to focal point from the time origin of transmit [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================= %

% Transmit elements list
Par = common.parameter( ...
    'TxElemts', ...
    'int32', ...
    'sets the TX channels', ...
    {[1 system.probe.NbElemts]}, ...
    {'id of the TX channels'}, ...
    obj.Debug, current_class );

Par = Par.setValue( int32(1:system.probe.NbElemts) );
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
