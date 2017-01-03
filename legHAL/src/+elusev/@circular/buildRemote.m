% ELUSEV.CIRCULAR.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.CIRCULAR instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.CIRCULAR instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.CIRCULAR.
%   It cannot be used without all methods of the remoteclass ELUSEV.CIRCULAR and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

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

% Retrieve circular parameters
TwFreq       = obj.getParam('TwFreq');
NbHcycle     = single(obj.getParam('NbHcycle'));
Polarity     = obj.getParam('Polarity');
xApex   = obj.getParam('xApex');
zApex   = obj.getParam('zApex');
Pause        = obj.getParam('Pause');
PauseEnd     = obj.getParam('PauseEnd');
DutyCycle    = obj.getParam('DutyCycle');
TxCenter     = obj.getParam('TxCenter');
TxWidth      = obj.getParam('TxWidth');
ApodFct      = obj.getParam('ApodFct');
RxFreq       = obj.getParam('RxFreq');
RxCenter     = obj.getParam('RxCenter');
RxWidth      = obj.getParam('RxWidth');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
PulseInv     = obj.getParam('PulseInv');

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
NumSamples = 128 ...
    * ceil(max(min(RxFreq * RxDuration / 2^(RxBandwidth-1), 4096), 128) / 128);
RxDuration = NumSamples / (RxFreq / 2^(RxBandwidth-1));
Value      = abs(RxDuration - obj.getParam('RxDuration'));
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

% Sets the RX channels positions
ElemtXpos = ((1 : system.probe.NbElemts) - 0.5) * system.probe.Pitch;

% 1st RX channel
MinRx = max(RxCenter - RxWidth / 2, ElemtXpos(1));
MinRx = find(MinRx <= ElemtXpos, 1, 'first');

% Last RX channel
MaxRx = min(RxCenter + RxWidth / 2, ElemtXpos(end));
MaxRx = find(MaxRx >= ElemtXpos, 1, 'last');

% Synthetic acquisition
if ( isempty(MinRx) )
    
    ErrMsg = ['No first element belonging to the probe could be identified ' ...
        'for reception.'];
    error(ErrMsg);
    
elseif ( isempty(MaxRx) )
    
    ErrMsg = ['No last element belonging to the probe could be identified ' ...
        'for reception.'];
    error(ErrMsg);
    
else
    
    SyntAcq = ((MaxRx - MinRx + 1) > system.hardware.NbRxChan);
    
end

% ============================================================================ %

% Initialize FC objects
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

% RX and FC objects
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
    RX = RX.setParam('RxElemts', MinRx:MaxRx);
    RxList{end+1} = RX;
    
end

% Update FC and RX parameters
obj = obj.setParam('fc', FcList);
obj = obj.setParam('rx', RxList);

% ============================================================================ %
% ============================================================================ %

%% Build the emission

% Sets the TX channels
NbElemts   = system.probe.NbElemts;
switch system.probe.Type
    
    case 'linear'
        
        % Estimate element position
        PrPitch   = system.probe.Pitch;               % probe pitch
        ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch; % element positions
        
    case 'curved'
        
        % Estimate element position
        PrPitch   = system.probe.Pitch;               % probe pitch [m]
        ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch; % element positions
        
    otherwise
        
        ErrMsg = ['The ' upper(class(obj)) ' setDelays function is not yet ' ...
            'implemented for ' lower(system.probe.Type) ' probes.'];
        error(ErrMsg);
        
end

% 1st TX channel
MinApert = double(max(floor(TxCenter - TxWidth / 2), ElemtXpos(1))) - PrPitch/4;
MinApert = find(MinApert <= ElemtXpos, 1, 'first');

% Last TX channel
MaxApert = double(min(ceil(TxCenter + TxWidth / 2), ElemtXpos(end))) + PrPitch/4;
MaxApert = find(MaxApert >= ElemtXpos, 1, 'last');

% Check transmission elements
if ( isempty(MinApert) )
    
    ErrMsg = ['No first element belonging to the probe could be identified ' ...
        'for emission.'];
    error(ErrMsg);
    
elseif ( isempty(MaxApert) )
    
    ErrMsg = ['No last element belonging to the probe could be identified ' ...
        'for emission.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Build the TX and TW objects
EventTxDur = zeros(1, length(xApex));

% Initialize TW
TwList = {};
TW     = remote.tw_pulse( ...
            'ApodFct', ApodFct, ...
            'TxElemts', MinApert:MaxApert, ...
            'DutyCycle', DutyCycle, ...
            'TwFreq', TwFreq, ...
            'Polarity', Polarity, ...
            obj.Debug);
if ( rem(NbHcycle, 2) )
    NewHcycle = factor(NbHcycle);
    
    TW = TW.setParam( ...
            'NbHcycle', NewHcycle(1), ...
            'repeat', NbHcycle / NewHcycle(1) - 1);
else
    TW = TW.setParam('NbHcycle', 2, 'repeat', NbHcycle / 2 - 1);
end

% Initialize TX
TxList = {};
TX     = remote.tx_circular(obj.Debug);

% Loop over all circular sources
for k = 1 : length(xApex)
    TW = TW.setParam('Polarity', Polarity);
    % TW object
    TwList{end + 1} = TW;
    
    % TX object
    TX  = TX.setParam('twId', Id0.tw + (1+PulseInv)*(k-1) , 'xApex', xApex(k),'zApex', zApex(k));
    TxList{end + 1} = TX;
    
    % Pulse inversion mode
    if ( PulseInv )
        
        TW = TW.setParam('Polarity', - Polarity);
        
        % TW object
        TwList{end + 1} = TW;
        
        % TX object
        TX  = TX.setParam( ...
            'twId', Id0.tw + 2*k-1);
        TxList{end + 1} = TX;
  
    end
    
    % Transmit duration of event
    EventTxDur(k) = ceil(TwFreq * NbHcycle / 2 + max(TX.getParam('Delays')));
    
end


% Update TW and TX parameters
obj = obj.setParam('tw', TwList);
obj = obj.setParam('tx', TxList);

% ============================================================================ %
% ============================================================================ %

%% Build the events

% Initialize EVENT
EventList = {};
EVENT     = remote.event( ...
                'noop', system.hardware.MinNoop, ...
                'numSamples', NumSamples, ...
                'skipSamples', SkipSamples, ...
                obj.Debug);

for k = 1 : length(xApex)
    
    if ( SyntAcq )
        
        % 1st reception
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + (1+PulseInv)*(k - 1), ...
            'rxId', Id0.rx, ...
            'duration', max(EventRxDur, EventTxDur(k)), ...
            'noop', system.hardware.MinNoop);
        EventList{end+1} = EVENT;
        
        % Pulse inversion mode
        if ( PulseInv )
            
            % 2nd reception
            EVENT = EVENT.setParam( ...
                'txId', Id0.tx + 2*k - 2, ...
                'rxId', Id0.rx + 1, ...
                'noop', system.hardware.MinNoop);
            EventList{end+1} = EVENT;
            
            % 1st reception inverted pulse
            EVENT = EVENT.setParam( ...
                'txId', Id0.tx + 2*k -1, ...
                'rxId', Id0.rx , ...
                'noop', system.hardware.MinNoop);
            EventList{end+1} = EVENT;
            
            % 2nd reception inverted pulse
            
            EVENT = EVENT.setParam( ...
                'txId', Id0.tx + 2*k -1 , ...
                'rxId', Id0.rx + 1, ...
                'noop', Pause);
            EventList{end+1} = EVENT;
            
        else
            % 2nd reception
            EVENT = EVENT.setParam( ...
                'txId', Id0.tx + k - 1, ...
                'rxId', Id0.rx + 1, ...
                'noop', Pause);
            EventList{end+1} = EVENT;
        end
        
    else
        
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + (1+PulseInv)*(k - 1), ...
            'rxId', Id0.rx, ...
            'duration', max(EventRxDur, EventTxDur(k)), ...
            'noop', Pause);
        EventList{end+1} = EVENT;
        
        % Pulse inversion mode
        if ( PulseInv )
            EventList{end} = EventList{end}.setParam( ...
                'noop', system.hardware.MinNoop);
            EVENT = EVENT.setParam( ...
                'txId', Id0.tx + 2*k -1 , ...
                'noop', Pause);
            EventList{end+1} = EVENT;
        end
        
    end
    
end

% Update EVENT parameter
EventList{end} = EventList{end}.setParam('noop', PauseEnd);
obj = obj.setParam('event', EventList);

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

% Build structure out of existing remotepar
[obj Struct] = buildRemote@elusev.elusev(obj, varargin{1:end});

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