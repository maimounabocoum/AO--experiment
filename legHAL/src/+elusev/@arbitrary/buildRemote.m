% ELUSEV.ARBITRARY.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.ARBITRARY instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.ARBITRARY
%   instance OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ELUSEV.ARBITRARY. It cannot be used without all methods of the remoteclass
%   ELUSEV.ARBITRARY and all methods of its superclass ELUSEV.ELUSEV developed
%   by SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/11/26

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
Delays       = obj.getParam('Delays');
Pause        = obj.getParam('Pause');
PauseEnd     = obj.getParam('PauseEnd');
ApodFct      = obj.getParam('ApodFct');
RxFreq       = obj.getParam('RxFreq');
RxCenter     = obj.getParam('RxCenter');
RxWidth      = obj.getParam('RxWidth');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');

% Estimate the number of independant firings
NbFirings = max(size(Waveform, 3), size(Delays, 2));

% ============================================================================ %

% Control the waveform

% bug if repeatCH == 1 ?

% Control if the waveform is defined for all probes elements
if size(Waveform, 3) == 1 && (NbFirings > 1) % repeat waveform for each firing
    RepeatWfFirings = NbFirings;

elseif size(Waveform, 3) ~= NbFirings
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The waveform should be:\n' ...
        ' - defined for all firings (3rd dimension = ' ...
        num2str(NbFirings) '),\n' ...
        ' - or repeated for all firings (3rd dimension = 1).'];
    error(ErrMsg);
    
else
    RepeatWfFirings = 1;
end

if size(Waveform, 1) == 1 % repeat waveform for all probe elements
    
    Waveform = repmat(Waveform, [system.probe.NbElemts 1 RepeatWfFirings]);

elseif size(Waveform, 1) ~= system.probe.NbElemts ... % bad definition...
    && size(Waveform, 1) ~= system.hardware.NbTxChan
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The waveform should be:\n' ...
        ' - defined for all tx channels elements (1st dimension = ' ...
        num2str(system.hardware.NbTxChan) '),\n' ...
        ' - defined for all probe elements (1st dimension = ' ...
        num2str(system.probe.NbElemts) '),\n' ...
        ' - or repeated for all probe elements (1st dimension = 1).'];
    error(ErrMsg);
    
elseif ( (size(Waveform, 1) == system.hardware.NbTxChan) ... % truncate waveform
        && (system.hardware.NbTxChan ~= system.probe.NbElemts) )
    
    Waveform = repmat(Waveform(1:system.probe.NbElemts, :, :), ...
        [1 1 RepeatWfFirings]);
    
end

% ============================================================================ %

% Control the delays

% Control if the waveform is defined for all probes elements
if ( (size(Delays, 2) == 1) && (NbFirings > 1) ) % repeat waveform
    RepeatDt = NbFirings;
elseif ( size(Delays, 2) ~= NbFirings )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The delays should be:\n' ...
        ' - defined for all firings (2nd dimension = ' ...
        num2str(NbFirings) '),\n' ...
        ' - or repeated for all firings (2nd dimension = 1).'];
    error(ErrMsg);
    
else
    RepeatDt = 1;
end

if size(Delays, 1) == 1 % repeat delays for all probe elements
    
    Delays = repmat( Delays, [system.probe.NbElemts RepeatDt] );

elseif (size(Delays, 1) ~= system.probe.NbElemts) ... % bad definition...
        && (size(Delays, 1) ~= system.hardware.NbTxChan)
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The delays should be:\n' ...
        ' - defined for all tx channels elements (1st dimension = ' ...
        num2str(system.hardware.NbTxChan) '),\n' ...
        ' - defined for all probe elements (1st dimension = ' ...
        num2str(system.probe.NbElemts) '),\n' ...
        ' - or repeated for all probe elements (1st dimension = 1).'];
    error(ErrMsg);

elseif size(Delays, 1) == system.hardware.NbTxChan ... % truncate waveform
        && system.hardware.NbTxChan ~= system.probe.NbElemts
    
    Delays = repmat(Delays(1:system.probe.NbElemts, :), [1 RepeatDt]);

elseif size(Delays, 2) == 1
    Delays = repmat(Delays, [1 RepeatDt]);
    
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

% Sets the RX channels
NbElemts = system.probe.NbElemts;

% Estimate element position
PrPitch   = system.probe.Pitch;               % probe pitch
ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch; % element positions

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
    
    SyntAcq    = ((MaxRx - MinRx + 1) > system.hardware.NbRxChan);
    
end


% ============================================================================ %

% Build the RX and FC objects

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

% Build the TX and TW objects
EventTxDur = zeros(1, length(NbFirings));

% Initialize TW
TwList = {};
TW     = remote.tw_arbitrary( ...
            'ApodFct', ApodFct, ...
            'TxElemts', 1:system.probe.NbElemts, ...
            'DutyCycle', 1, ...
            'RepeatCH', 0, ...
            obj.Debug);

% Initialize TX
TxList = {};
TX     = remote.tx_arbitrary(obj.Debug);

for k = 1 : NbFirings
    
    % TX object
    TX = TX.setParam('twId', Id0.tw + k - 1, 'Delays', Delays(:,k));
    TxList{end+1} = TX;
    
    % TW object
    TW = TW.setParam('Waveform', Waveform(:,:,k));
    TwList{end+1} = TW;
    
    % Transmit duration of event
    EventTxDur(k) = ceil(max(Delays(:,k)) ...
        + size(Waveform(:,:,k), 2) / system.hardware.ClockFreq);
    
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
                'numSamples', NumSamples, ...
                'skipSamples', SkipSamples, ...
                obj.Debug);

for k = 1 : NbFirings

    % 1st reception
    EVENT = EVENT.setParam( ...
        'txId', Id0.tx + k - 1, ...
        'rxId', Id0.rx, ...
        'noop', system.hardware.MinNoop, ...
        'duration', max(EventRxDur, EventTxDur(k)));
    EventList{end+1} = EVENT;

    if SyntAcq

        % 2nd reception
        EVENT = EVENT.setParam( ...
            'rxId', Id0.rx + 1, ...
            'noop', Pause);
        EventList{end+1} = EVENT;
        
    end
    
end

% Update EVENT parameter
EventList{end} = EventList{end}.setParam('noop', PauseEnd);
obj = obj.setParam('event', EventList);

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

% Build the associated structure
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