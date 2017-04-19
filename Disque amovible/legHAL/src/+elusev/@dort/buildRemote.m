% ELUSEV.DORT.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.DORT instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.DORT instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.DORT.
%   It cannot be used without all methods of the remoteclass ELUSEV.DORT and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/12/02

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls

% Check syntax
if ( (nargout ~= 1) && (nargout ~= 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Reindex objects (TX, TW, RX, FC)
ParsName = obj.Pars(:,1);

% ELUSEV TX index
ParName      = 'tx';
Idx = find( strcmp( ParsName, ParName ) );

if ( ~isempty(obj.Pars{Idx, 3}) )
    Id0.tx = length(obj.Pars{Idx, 3}) + 1;
else
    Id0.tx = 1;
end

% ELUSEV TW index
ParName = 'tw';
Idx = find( strcmp( ParsName, ParName ) );

if ( ~isempty(obj.Pars{Idx, 3}) )
    Id0.tw = length(obj.Pars{Idx, 3}) + 1;
else
    Id0.tw = 1;
end

% ELUSEV RX index
ParName = 'rx';
Idx = find( strcmp( ParsName, ParName ) );

if ( ~isempty(obj.Pars{Idx, 3}) )
    Id0.rx = length(obj.Pars{Idx, 3}) + 1;
else
    Id0.rx = 1;
end

% ELUSEV FC index
ParName = 'fc';
Idx = find( strcmp( ParsName, ParName ) );

if ( ~isempty(obj.Pars{Idx, 3}) )
    Id0.fc = length(obj.Pars{Idx, 3}) + 1;
else
    Id0.fc = 1;
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve parameters and control their value

% Retrieve push parameters
Waveform     = obj.getParam('Waveform');
Pause        = obj.getParam('Pause');
PauseEnd     = obj.getParam('PauseEnd');
DutyCycle    = obj.getParam('DutyCycle');
RxFreq       = obj.getParam('RxFreq');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = single(obj.getParam('FIRBandwidth'));
NbFirings    = size(Waveform, 3);

% ============================================================================ %

% Control the RxFreq
AuthFreq          = system.hardware.ClockFreq ...
    ./ (system.hardware.ADRate * system.hardware.ADFilter);
DiffFreq          = min(AuthFreq(AuthFreq >= (1 - 1e-3) * RxFreq) - RxFreq);
[ADRate ADFilter] = find((AuthFreq - RxFreq) == DiffFreq);
[ADFilter I]      = max(ADFilter);
ADRate            = system.hardware.ADRate(ADRate(I));
RxFreq            = system.hardware.ClockFreq ./ (ADRate * ADFilter);

if ( abs(RxFreq - obj.getParam('RxFreq')) > 1e-3  )
    WarnMsg = ['RxFreq was changed from ' num2str(obj.getParam('RxFreq')) ...
        ' MHz to ' num2str(RxFreq) ' MHz.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('RxFreq', RxFreq);

% ============================================================================ %

% Control the RxDuration
NumSamples(1) = 128 ...
    * floor(max(min(RxFreq * RxDuration / 2^(RxBandwidth-1), 4096), 128) / 128);
NumSamples(2) = 128 ...
    * ceil(max(min(RxFreq * RxDuration / 2^(RxBandwidth-1), 4096), 128) / 128);
RxDuration    = NumSamples / (RxFreq / 2^(RxBandwidth-1));
[Value Idx]   = min(abs(RxDuration - obj.getParam('RxDuration')));
RxDuration    = RxDuration(Idx);
NumSamples    = NumSamples(Idx);
if ( (Value / RxDuration) > 1e-2 )
    WarnMsg = ['RxDuration was changed from ' ...
        num2str(obj.getParam('RxDuration')) ' us to ' ...
        num2str(RxDuration) ' us.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('RxDuration', RxDuration);

% ============================================================================ %

% Control the RxDelay
SkipSamples = round(RxFreq * RxDelay);
RxDelay     = SkipSamples / RxFreq;
if ( abs(RxDelay - obj.getParam('RxDelay')) > 1e-2 )
    WarnMsg = ['RxDelay was changed from ' num2str(obj.getParam('RxDelay')) ...
        ' us to ' num2str(RxDelay) ' us.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('RxDelay', RxDelay);

% Reception duration of event
EventRxDur = ceil(RxDuration + RxDelay);

% ============================================================================ %
% ============================================================================ %

%% Build the reception

% Control the synthetic acquisition
if ( system.probe.NbElemts <= system.hardware.NbRxChan )
    SyntAcq = 0;
else 
	SyntAcq = 1;
end

% ============================================================================ %

% RX and FC objects

% Initialize FC
FcList = {};
FC     = remote.fc( ...
            'Bandwidth', FIRBandwidth, ...
            obj.Debug);

% Initialize RX
RxList = {};
RX     = remote.rx( ...
            'fcId', Id0.fc, ...
            'RxFreq', RxFreq, ...
            'QFilter', RxBandwidth, ...
            obj.Debug);

if ( SyntAcq )
    
    % 1st FC object
    FcList{end+1} = FC;
    
    % 1st RX object
    RX = RX.setParam('RxElemts', 1);
    RxList{end+1} = RX;
    
    % 2nd FC object
    FcList{end+1} = FC;
    
    % 2nd RX object
    RX = RX.setParam('fcId', Id0.fc + 1, 'RxElemts', system.hardware.NbTxChan);
    RxList{end+1} = RX;
    
else
    
    % FC object
    FcList{end+1} = FC;
    
    % RX object
    RX  = remote.rx('RxElemts', 1);
    RxList{end+1} = RX;
    
end

% Update FC and RX parameters
obj = obj.setParam('FC', FcList);
obj = obj.setParam('RX', RxList);

% ============================================================================ %
% ============================================================================ %

%% Build the emission

% Build the TX and TW objects
EventTxDur = zeros(1, length(NbFirings));

% Initialize TW
TwList = {};
TW     = remote.tw_arbitrary( ...
    'TxElemts', 1, ...
    'DutyCycle', DutyCycle, ...
    obj.Debug);

% Initialize TX
TxList = {};
TX     = remote.tx_arbitrary( ...
        'Delays', 0, ...
        obj.Debug);

for k = 1 : NbFirings
    
    % TX object
    TX  = TX.setParam('twId', Id0.tw + k - 1);
    TxList{end+1} = TX;
    
    % TW object
    TW  = TW.setParam('Waveform', Waveform(:,:,k));
    TwList{end+1} = TW;
    
    % Transmit duration of event
    EventTxDur(k) = ceil(size(Waveform(:,:,k), 1) / system.hardware.ClockFreq);
    
end

% Update TW and TX parameters
obj = obj.setParam('TW', TwList);
obj = obj.setParam('TX', TxList);

% ============================================================================ %
% ============================================================================ %

%% Build the events

% Initialize EVENT
EventList = {};
EVENT     = remote.event( ...
                'numSamples', NumSamples, ...
                'skipSamples', SkipSamples, ...
                obj.Debug);

for k = 1 : NbFirings
    
    if ( SyntAcq )
        
        % 1st reception
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + k - 1, ...
            'rxId', Id0.rx, ...
            'duration', max(EventRxDur, EventTxDur(k)), ...
            'noop', system.hardware.MinNoop);
        EventList{end+1} = EVENT;
        
        % 2nd reception
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + k - 1, ...
            'rxId', Id0.rx + 1, ...
            'duration', max(EventRxDur, EventTxDur(k)), ...
            'noop', Pause);
        EventList{end+1} = EVENT;
        
    else
        
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + k - 1, ...
            'rxId', Id0.rx, ...
            'duration', max(EventRxDur, EventTxDur(k)), ...
            'noop', Pause);
        EventList{end+1} = EVENT;
        
    end
    
end

% Update EVENT parameter
obj = obj.setParam('EVENT', EventList);

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

% Build structure out of existing remotepar
[obj Struct] = buildRemote@elusev.elusev(obj, varargin{1:end});

% Build the additional transmit, waveform and event
for k = 2 : system.probe.NbElemts
    for l = 1 : NbFirings
        
        % New TX for new element
        Struct.tx = [Struct.tx; Struct.tx(Id0.tx + l - 1)];
        Struct.tx(end).twId = length(Struct.tx);
        
        % New waveform
        TmpTw    = Struct.tw(l);
        NbPoints = TmpTw.maxWfPoints;
        TmpTw.wf((1:NbPoints) + (k-1) * NbPoints) = TmpTw.wf(1:NbPoints);
        TmpTw.wf(1:NbPoints) = 0;
        Struct.tw = [Struct.tw; TmpTw];
        
        % New event
        Struct.event = [Struct.event; Struct.event(1)];
        Struct.event(end).rxId = int32(Id0.rx);
        Struct.event(end).txId = int32(length(Struct.tx));
        if ( SyntAcq )
            Struct.event           = [Struct.event; Struct.event(2)];
            Struct.event(end).rxId = int32(Id0.rx + 1);
            Struct.event(end).txId = int32(length(Struct.tx));
        end
        
    end
end

% ============================================================================ %

% Change noop for last event
Struct.event(end).noop = int32(PauseEnd);

% ============================================================================ %

% Control the output arguments
if ( isempty(fieldnames(Struct)) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
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

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'buildRemote');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end