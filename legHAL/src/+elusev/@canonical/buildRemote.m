
function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Build the class name for the error dialog box
ErrClass = upper(class(obj));
ErrClass(findstr(ErrClass, '.')) = ':';
ErrClass = [ErrClass ':BUILDREMOTE'];

% ============================================================================ %

% ELUSEV TX index
[VarName Idx] = obj.isParam('tx');
if ( ~isempty(obj.(VarName{1}){Idx{1}, 3}) )
    Id0.tx = length(obj.(VarName{1}){Idx{1}, 3}) + 1;
else
    Id0.tx = 1;
end

% ELUSEV TW index
[VarName Idx] = obj.isParam('tw');
if ( ~isempty(obj.(VarName{1}){Idx{1}, 3}) )
    Id0.tw = length(obj.(VarName{1}){Idx{1}, 3}) + 1;
else
    Id0.tw = 1;
end

% ELUSEV RX index
[VarName Idx] = obj.isParam('rx');
if ( ~isempty(obj.(VarName{1}){Idx{1}, 3}) )
    Id0.rx = length(obj.(VarName{1}){Idx{1}, 3}) + 1;
else
    Id0.rx = 1;
end

% ELUSEV FC index
[VarName Idx] = obj.isParam('fc');
if ( ~isempty(obj.(VarName{1}){Idx{1}, 3}) )
    Id0.fc = length(obj.(VarName{1}){Idx{1}, 3}) + 1;
else
    Id0.fc = 1;
end

% ============================================================================ %
% ============================================================================ %

% Retrieve parameters
try
    NbFirings  = 1; % TODO: manage that

    TxElemts   = obj.getParam('TxElemts');
    TxDelays   = obj.getParam('TxDelays');
    TwFreq     = obj.getParam('TwFreq');
    NbHcycle   = single( obj.getParam('NbHcycle') );
    DutyCycle  = obj.getParam('DutyCycle');
    RxElemts   = obj.getParam('RxElemts');
    RxFreq     = obj.getParam('RxFreq');
    RxDelay    = obj.getParam('RxDelay');
    RxDuration = obj.getParam('RxDuration');
    VGAInputFilter  = obj.getParam('VGAInputFilter');
    QFilter    = single(obj.getParam('QFilter'));
    Bandwidth  = single(obj.getParam('Bandwidth'));
    Pause      = obj.getParam('Pause');
    PauseEnd   = obj.getParam('PauseEnd');
    
catch exception
    uiwait(errordlg(exception.message, exception.identifier));
    varargout{1} = [];
    return
end

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
    * floor(max(min(RxFreq * RxDuration / QFilter, 4096), 128) / 128);
NumSamples(2) = 128 ...
    * ceil(max(min(RxFreq * RxDuration / QFilter, 4096), 128) / 128);
RxDuration    = NumSamples / (RxFreq / QFilter);
[Value Idx]   = min(abs(RxDuration - obj.getParam('RxDuration')));
RxDuration    = RxDuration(Idx);
NumSamples    = NumSamples(Idx);
if (Value / RxDuration) > 1e-2
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

% ============================================================================ %

% Control the synthetic acquisition
% TODO: case of multiple elements in less than system.hardware.NbTxChan/2
% consecutive chans
if length(RxElemts) == 1    
    SyntAcq = 0;
else 
	SyntAcq = 1;
end

% ============================================================================ %
% ============================================================================ %

% Initialize RX and FC objects
FcList = {};
RxList = {};

if SyntAcq
    
    % 1st RX object
    RX  = remote.rx('fcId', Id0.fc, 'RxFreq', RxFreq, 'QFilter', QFilter, ...
        'RxElemts', 1, 'VGAInputFilter', VGAInputFilter, obj.Debug);
    RxList{end+1} = RX;
    
    % 1st FC object
    FC  = remote.fc('Bandwidth', Bandwidth, obj.Debug);
    FcList{end+1} = FC;
    
    % 2nd RX object
    RX  = RX.setParam('fcId', Id0.fc + 1, 'RxElemts', system.hardware.NbTxChan);
    RxList{end+1} = RX;
    
    % 2nd FC object
    FC  = remote.fc('Bandwidth', Bandwidth, obj.Debug);
    FcList{end+1} = FC;
    
else
    % TODO: understand mux computation
    if RxElemts > system.hardware.NbTxChan/2
        RxElemts_acq = system.hardware.NbTxChan;
    else
        RxElemts_acq = 1;
    end

    % RX object
    RX  = remote.rx('fcId', Id0.fc, 'RxFreq', RxFreq, 'QFilter', QFilter, ...
        'RxElemts', RxElemts_acq, 'VGAInputFilter', VGAInputFilter, obj.Debug);
    obj = obj.setParam('rx', RX);
    
    % FC object
    FC  = remote.fc('Bandwidth', Bandwidth, obj.Debug);
    FcList{end+1} = FC;
    
end

obj = obj.setParam('rx', RxList);
obj = obj.setParam('fc', FcList);

% ============================================================================ %
% ============================================================================ %

% Initialize TX and TW objects

% WF size minization for all possible durations (in cycles)
% repeat : [0:1023]*[1 256] = 
% duration : [0:1024]
%   - WF : 1

% TODO: manage repeat256 if needed
repeat = 1;
repeat256 = 0;

TwList = {};
TxList = {};

txClock180MHz = 1;

for k = 1:length(TxElemts)

    % TW object
    TW  = remote.tw_pulse( 'repeat', repeat, 'repeat256', repeat256, 'ApodFct', 'none', ...
        'TxElemts', TxElemts(k), 'DutyCycle', DutyCycle, 'TwFreq', TwFreq, 'NbHcycle', 2, ...NbHcycle, ... 
        'Polarity', 1, 'txClock180MHz', txClock180MHz, obj.Debug );
%     TW  = remote.tw_pulse( 'repeat', repeat, 'repeat256', repeat256, 'ApodFct', 'none', ...
%         'TxElemts', TxElemts, 'DutyCycle', DutyCycle, 'TwFreq', TwFreq, 'NbHcycle', NbHcycle, ... 
%         'Polarity', 1, 'txClock180MHz', txClock180MHz, obj.Debug );
    % NbHcycle
    if rem(NbHcycle, 2)
        NewHcycle = factor( single(NbHcycle) );
        TW = TW.setParam( ...
            'NbHcycle', NewHcycle(1), ...
            'repeat', single(NbHcycle) / NewHcycle(1) - 1 );
    else
        TW = TW.setParam('NbHcycle', 2, 'repeat', NbHcycle / 2 - 1);
    end

    TwList{end + 1} = TW;

    % TX object
    TX  = remote.tx_arbitrary('txClock180MHz', txClock180MHz, 'twId', Id0.tw + k - 1, ...
        'Delays', TxDelays, obj.Debug);
    TxList{end + 1} = TX;

end

obj = obj.setParam('tx', TxList);
obj = obj.setParam('tw', TwList);

% ============================================================================ %
% ============================================================================ %

% Initialize EVENT
EventList = {};

EventRxDur = ceil( RxDuration + RxDelay );
EventTxDur = ceil( single(NbHcycle)/TwFreq/2 );
EventDur = max( EventRxDur, EventTxDur );

% Build the events
for k = 1:length(TxElemts)
    
    if SyntAcq

        % 1st reception
        EVENT = remote.event( 'txId', int32(Id0.tx + k - 1), 'rxId', Id0.rx, ...
            'noop', system.hardware.MinNoop, 'numSamples', NumSamples, ...
            'skipSamples', SkipSamples, ...
            'duration', EventDur, obj.Debug);
        EventList{end+1} = EVENT;
        
        % 2nd reception
        EVENT = remote.event( 'txId', int32(Id0.tx + k - 1), 'rxId', Id0.rx + 1, ...
            'noop', Pause, 'numSamples', NumSamples, ...
            'skipSamples', SkipSamples, ...
            'duration', EventDur, obj.Debug);
        EventList{end+1} = EVENT;
        
    else
        EVENT = remote.event( 'txId', int32(Id0.tx + k - 1), 'rxId', Id0.rx, ...
            'noop', Pause, 'numSamples', NumSamples, ...
            'skipSamples', SkipSamples, ...
            'duration', EventDur, obj.Debug);
        EventList{end+1} = EVENT;
        
    end
    
end

EventList{end} = EventList{end}.setParam('noop', PauseEnd);
obj   = obj.setParam('event', EventList);


% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

    % Build structure out of existing remotepar
    [obj Struct] = buildRemote@elusev.elusev(obj, varargin{1:end});

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
