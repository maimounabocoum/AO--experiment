% ELUSEV.INIT_BLS.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.INIT_BLS instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.INIT_BLS instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.INIT_BLS.
%   It cannot be used without all methods of the remoteclass ELUSEV.INIT_BLS and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Build the class name for the error dialog box
ErrClass = upper(class(obj));
ErrClass(findstr(ErrClass, '.')) = ':';
ErrClass = [ErrClass ':BUILDREMOTE'];

% ============================================================================ %

% ELUSEV RX index
Id0.rx = 1;

% ELUSEV FC index
Id0.fc = 1;

% ============================================================================ %
% ============================================================================ %

% fixed parameters

RxElemts   = single(1:min(system.probe.NbElemts,system.hardware.NbRxChan));
RxFreq     = obj.getParam('RxFreq');
RxDelay    = single(0);
RxDuration = single(128/RxFreq); % minimum time
QFilter    = single(1);
Bandwidth  = single(100);
Pause      = single(system.hardware.MinNoop);

% ============================================================================ %

% Control the RxFreq
AuthFreq          = system.hardware.ClockFreq ...
    ./ (system.hardware.ADRate * system.hardware.ADFilter);
DiffFreq          = min(AuthFreq(AuthFreq >= (1 - 1e-3) * RxFreq) - RxFreq);
[ADRate ADFilter] = find((AuthFreq - RxFreq) == DiffFreq);
[ADFilter I]      = max(ADFilter);
ADRate            = system.hardware.ADRate(ADRate(I));
tmpRxFreq         = system.hardware.ClockFreq ./ (ADRate * ADFilter);

if ( abs(RxFreq - RxFreq) > 1e-3  )
    WarnMsg = ['RxFreq was changed from ' num2str(RxFreq) ...
        ' MHz to ' num2str(tmpRxFreq) ' MHz.'];
    obj.WarningMessage( WarnMsg )
end
RxFreq = tmpRxFreq;

% ============================================================================ %

% Control the RxDuration
NumSamples(1) = 128 ...
    * floor(max(min(RxFreq * RxDuration / QFilter, 4096), 128) / 128);
NumSamples(2) = 128 ...
    * ceil(max(min(RxFreq * RxDuration / QFilter, 4096), 128) / 128);
tmpRxDuration    = NumSamples / (RxFreq / QFilter);
[Value Idx]   = min(abs(tmpRxDuration - RxDuration));
tmpRxDuration    = tmpRxDuration(Idx);
NumSamples    = NumSamples(Idx);
if ( (Value / RxDuration) > 1e-2 )
    WarnMsg = ['RxDuration was changed from ' ...
        num2str(RxDuration) ' us to ' ...
        num2str(tmpRxDuration) ' us.'];
    obj.WarningMessage( WarnMsg )
end
RxDuration = tmpRxDuration;

% ============================================================================ %

% Control the RxDelay
SkipSamples = round(RxFreq * RxDelay);
tmpRxDelay     = SkipSamples / RxFreq;
if ( abs(tmpRxDelay - RxDelay) > 1e-2 )
    WarnMsg = ['RxDelay was changed from ' num2str(RxDelay) ...
        ' us to ' num2str(tmpRxDelay) ' us.'];
    obj.WarningMessage( WarnMsg )
end
RxDelay = tmpRxDelay;

% Reception duration of event
EventRxDur = ceil(RxDuration + RxDelay);

% ============================================================================ %
% ============================================================================ %

% RX object
RX  = remote.rx('fcId', Id0.fc, 'RxFreq', RxFreq, 'QFilter', QFilter, ...
    'RxElemts', RxElemts, obj.Debug);
obj = obj.setParam('rx', RX);

% FC object
FC  = remote.fc('Bandwidth', Bandwidth, obj.Debug);
obj = obj.setParam('fc', FC);

% ============================================================================ %
% ============================================================================ %

% Build the event
EVENT = remote.event( 'rxId', Id0.rx, ...
    'noop', Pause, 'duration', EventRxDur, ...
    'numSamples', NumSamples, 'skipSamples', SkipSamples, obj.Debug);
obj   = obj.setParam('event', EVENT);

% ============================================================================ %
% ============================================================================ %

TX  = remote.tx_arbitrary('txClock180MHz', 0, 'twId', 1, ...
    'Delays', 0, 0);
obj = obj.setParam('tx', TX);

TW  = remote.tw_pulse('repeat', 0, 'repeat256', 0, 'ApodFct', 'none', ...
'TxElemts', 1, 'DutyCycle', 0, 'TwFreq', system.hardware.MaxTxFreq, 'NbHcycle', 0, ...
'Polarity', 1, 'txClock180MHz', 0, 0);
obj = obj.setParam('tw', TW);


% ELUSEV.ELUSEV general BUILDREMOTE function
try
    
    % Build structure out of existing remotepar
    [obj Struct] = buildRemote@elusev.elusev(obj, varargin{1:end});
    
    % New event
    Struct.event.rxId = int32(1);
    Struct.event.txId = int32(1); % If remove this, remote says "Trying to generate run ack without TX: forbiden case"
    
catch exception
    uiwait(errordlg(exception.message, exception.identifier));
    varargout{1} = [];
    return;
end

% ============================================================================ %

if ( isempty(fieldnames(Struct)) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrClass, ErrMsg);
    
else
    
    % One output argument
    varargout{1} = Struct;
    
    % Two output arguments
    if ( nargout == 2 )
        varargout{2} = varargout{1};
        varargout{1} = obj;
    end
end

% ============================================================================ %
% ============================================================================ %

end