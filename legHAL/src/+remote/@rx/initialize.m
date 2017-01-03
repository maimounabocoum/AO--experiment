% REMOTE.RX.INITIALIZE (PROTECTED)
%   Create a REMOTE.RX instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.RX instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) creates a generic REMOTE.RX instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.RX instance with
%   its name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.RX instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - FCID (int32) sets the filter coefficients id.
%       [1 Inf]
%     - CLIPMODE (int32) sets the clip mode level.
%       0 = none, 1 = maximum, 2 = medium, 3 = lowest - default = 0
%     - RXFREQ (single) sets the receive frequency.
%       [1 60] MHz
%     - QFILTER (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50%
%     - HARMONICFILTER (int32) sets the harmonic filtering.
%       1 = none, 2 = -15dB @<2MHz, min @3MHz, to -2.5dB @[3MHz;5MHz],
%       0 = -15dB @<2MHz, min @3.75MHz, to 0dB @[3MHz;10MHz]- default = 1
%     - VGAINPUTFILTER (int32) sets notches to block frequencies.
%       0 = none, 4 = notch @ 2.25 MHz, 2 = notch @ 3.75 MHz,
%       1 = notch @ 5.5 MHz - default = 0
%     - VGALOWGAIN (int32) sets a filter for low gain.
%       0 = no attenuation, 1 = -20dB after 10µs - default = 0
%     - RXELEMTS (int32) sets the receiving elements.
%       0 = none, [1 system.probe.NbElemts]
%     - HIFURX (int32) enables reception on non-contiguous elements.
%       0 = contiguous channels, 1 = distinct channels - default = 0
%
%   Note - This function is defined as a method of the remoteclass REMOTE.RX. It
%   cannot be used without all methods of the remoteclass REMOTE.RX and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.rx';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Id of the filter coefficients
Par = common.remotepar( ...
    'fcId', ...
    'int32', ...
    'sets the filter coefficients id', ...
    {[1 Inf]}, ...
    {'index of filter coefficients'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Clip mode level (default = 0)
Par = common.remotepar( ...
    'clipMode', ...
    'int32', ...
    'sets the clip mode level', ...
    {0 1 2 3}, ...
    {'no clipping', 'maximum clip level', 'medium clip level', ...
        'lowest clip level'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Receive frequency
Par = common.parameter( ...
    'RxFreq', ...
    'single', ...
    'sets the receive frequency', ...
    {[1 60]}, ...
    {'receive frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Decimation mode
Par = common.remotepar( ...
    'QFilter', ...
    'int32', ...
    'sets the decimation mode', ...
    {1 2 3}, ...
    {'no decimation', '100% mode', '50% mode'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Harmonic filtering mode (default = 1)
Par = common.remotepar( ...
    'harmonicFilter', ...
    'int32', ...
    'sets the harmonic filtering', ...
    {1 2 0}, ...
    {'no filter', '-15 dB @ < 2 MHz, min @ 3 MHz, to -2.5 dB @ [ 3 5 ] MHz', ...
        '-15 dB @ < 2MHz, min @ 3.75 MHz, to 0 dB @ [ 3 ; 10 ] MHz '}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
obj = obj.addParam(Par);

% ============================================================================ %

% VGA input filtering
if strcmp( system.hardware.Tag, 'BTE' )
    Par = common.remotepar( ...
        'VGAInputFilter', ...
        'int32', ...
        'sets measurement type', ...
        { 0 3 }, ...
        { 'Intensity measurement', 'Voltage measurement' }, ...
        obj.Debug, current_class );
    Par = Par.setValue(3);
else
    Par = common.remotepar( ...
        'VGAInputFilter', ...
        'int32', ...
        'sets notches to block frequencies', ...
        { 0 4 2 1 }, ...
        { 'no notch', 'notch @ 2.25 MHz', 'notch @ 3.75 MHz', 'notch @ 5.5 MHz' }, ...
        obj.Debug, current_class );
    Par = Par.setValue(0);
end    
obj = obj.addParam(Par);

% ============================================================================ %

% VGA low gain filtering (default = 0)
Par = common.remotepar( ...
    'VGALowGain', ...
    'int32', ...
    'sets a filter for low gain', ...
    { 0 1 }, ...
    { 'no attenuation', '-20 dB after 10 µs' }, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Receiving elements
Par = common.parameter( ...
    'RxElemts', ...
    'int32', ...
    'sets the receiving elements', ...
    { 0 [1 system.hardware.NbTxChan] }, ...
    { 'no receiving elements', 'indexes of receiving elements' }, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% HIFU receiving (default = 0)
Par = common.parameter( ...
    'HifuRx', ...
    'int32', ...
    'enables reception on non-contiguous elements', ...
    {0 1}, ...
    {'contiguous receiving channels', 'distinct receiving channels'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
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