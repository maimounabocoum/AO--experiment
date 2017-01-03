% TODO: verify RX elems impact

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

% Retrieve focused parameters
% Retrieve flat parameters
TwFreq       = obj.getParam('TwFreq');
NbHcycle     = single(obj.getParam('NbHcycle'));
SteerAngle  = obj.getParam('SteerAngle');
Focus        = obj.getParam('Focus');
Pause        = obj.getParam('Pause');
PauseEnd     = obj.getParam('PauseEnd');
DutyCycle    = obj.getParam('DutyCycle');
TxCenter     = obj.getParam('TxCenter');
TxWidth      = obj.getParam('TxWidth');
ApodFct      = obj.getParam('ApodFct');
RxFreq       = obj.getParam('RxFreq');
RxCenter     = obj.getParam('RxCenter');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
TxElemsPattern = obj.getParam('TxElemsPattern');
TxPolarity   = obj.getParam('TxPolarity');

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

% Control if several focused lines needs to be generated
NbFocusedLines = max([length(TxCenter) length(Focus) length(TxWidth) length(RxCenter) length(SteerAngle)]);

% Adapt the length of TxCenter
if ( length(TxCenter) == 1 )
    TxCenter = repmat(TxCenter, [1 NbFocusedLines]);
elseif ( length(TxCenter) ~= NbFocusedLines )
    
    ErrMsg = ['The TxCenter parameter has ' num2str(length(TxCenter)) ' values, ' ...
        'while it should contain 1 or ' num2str(NbFocusedLines) ' values.'];
    error(ErrMsg);
    
end

% Adapt the length of Focus
if ( length(Focus) == 1 )
    Focus = repmat(Focus, [1 NbFocusedLines]);
elseif ( length(Focus) ~= NbFocusedLines )
    
    ErrMsg = ['The Focus parameter has ' num2str(length(Focus)) ' values, ' ...
        'while it should contain 1 or ' num2str(NbFocusedLines) ' values.'];
    error(ErrMsg);
    
end    

% Adapt the length of TxWidth
if ( length(TxWidth) == 1 )
    TxWidth = repmat(TxWidth, [1 NbFocusedLines]);
elseif ( length(TxWidth) ~= NbFocusedLines )
    
    ErrMsg = ['The TxWidth parameter has ' num2str(length(TxWidth)) ...
        ' values, while it should contain 1 or ' num2str(NbFocusedLines) ' values.'];
    error(ErrMsg);
    
end

% Adapt the length of RxCenter
if ( length(RxCenter) == 1 )
    RxCenter = repmat(RxCenter, [1 NbFocusedLines]);
elseif ( length(RxCenter) ~= NbFocusedLines )
    
    ErrMsg = ['The RxCenter parameter has ' num2str(length(RxCenter)) ...
        ' values, while it should contain 1 or ' num2str(NbFocusedLines) ' values.'];
    error(ErrMsg);
    
end

% Adapt the length of SteerAngle
if ( length(SteerAngle) == 1 )
    SteerAngle = repmat(SteerAngle, [1 NbFocusedLines]);
elseif ( length(SteerAngle) ~= NbFocusedLines )
    
    ErrMsg = ['The SteerAngle parameter has ' num2str(length(SteerAngle)) ...
        ' values, while it should contain 1 or ' num2str(NbFocusedLines) ' values.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Build the reception

% Sets the RX channels positions
ElemtXpos = ((1 : system.probe.NbElemts) - 0.5)*system.probe.Pitch ;

% set RxWidth (max channels)
RxWidth = system.hardware.NbRxChan ;
RxCenterIdx = RxCenter/system.probe.Pitch ;

if system.probe.NbElemts <= system.hardware.NbRxChan % full aperture
    MinRx = ones(size(RxCenter)) ;
    MaxRx = MinRx*system.probe.NbElemts ;
    
else
    % max mux pos is when the last system.hardware.NbRxChan of the probe
    % are receiving
    MinRx = min(  max( int32( round(RxCenterIdx-single(RxWidth)/2) ), 1 ), ...
                  int32(system.probe.NbElemts)-system.hardware.NbRxChan+int32(1) ) ;
    MaxRx = MinRx + system.hardware.NbRxChan - 1 ;
    
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

for k=1:NbFocusedLines
    
    % FC object
    FcList{end+1} = FC;
    
    % RX object
    RX = RX.setParam('RxElemts', MinRx(k):MaxRx(k));
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
MinApert = max(1,floor((TxCenter - TxWidth/2 - 0.5)/system.probe.Pitch + 1)) ;

% Last TX channel
MaxApert = min(system.probe.NbElemts,floor((TxCenter + TxWidth/2 - 0.5)/system.probe.Pitch + 1)) ;

% ============================================================================ %

% Build the TX and TW objects
EventTxDur = zeros(1, NbFocusedLines);

% Initialize TW
TwList = {};
TW     = remote.tw_pulse( ...
            'ApodFct', ApodFct, ...
            'DutyCycle', DutyCycle, ...
            'TwFreq', TwFreq, ...
            obj.Debug);

if rem(NbHcycle, 2)
    NewHcycle = factor(NbHcycle);
    
    TW = TW.setParam( ...
            'NbHcycle', NewHcycle(1), ...
            'repeat', NbHcycle / NewHcycle(1) - 1);
else
    TW = TW.setParam('NbHcycle', 2, 'repeat', NbHcycle / 2 - 1);
end

% Initialize TX
TxList = {};
TX     = remote.tx_focus(obj.Debug);

% Initialize EVENT
EventList = {};
EVENT  = remote.event( ...
    'noop', system.hardware.MinNoop, ...
    'numSamples', NumSamples, ...
    'skipSamples', SkipSamples, ...
    obj.Debug);

TxPolarity( find(TxPolarity==0) ) = -1;
% Manage length of TxElemsPattern and 
if length(TxElemsPattern) ~= length(TxPolarity)
    % If one of them has length of 1: apply to all, otherwise: error
    if length(TxElemsPattern) == 1
        TxElemsPattern = repmat( TxElemsPattern, 1, length(TxPolarity) );
    elseif length(TxPolarity) == 1
        TxPolarity = repmat( TxPolarity, 1, length(TxElemsPattern) );
    else
        error('TxElemsPattern and TxPolarity must either have the same length or one of them have only one element.')
    end 
end
Nb_Tx_Per_Line = length(TxElemsPattern);

% if different TxElemsPattern, have an even number of elements
UseEvenAperture = 0;
if length( unique(TxElemsPattern) ) > 1
    UseEvenAperture = 1;
end

% Loop over all focused lines
for k = 1 : NbFocusedLines
    tw_line_id0 = Nb_Tx_Per_Line*(k-1); % start at 0
    
    % Focus
    TX = TX.setParam( 'PosX', TxCenter(k) + Focus(k)*tan(SteerAngle(k)), ...
                      'PosZ', Focus(k) );

    % Aperture
    LocalAperture = MinApert(k):MaxApert(k);
    if UseEvenAperture && mod(length(LocalAperture),2) == 1
        LocalAperture = LocalAperture(1:end-1);
    end
    
    % Loop over Patterns TXs for one line
    for n = 1:Nb_Tx_Per_Line

        if TxElemsPattern(n) == 0
            LocalAperturePattern = LocalAperture ;
        elseif TxElemsPattern(n) == 1
            LocalAperturePattern = LocalAperture(1:2:end) ;
        elseif TxElemsPattern(n) == 2
            LocalAperturePattern = LocalAperture(2:2:end) ;
        else
            error( [ 'Unknown Tx pattern: ' num2str( TxElemsPattern(n) ) ] )
        end

        % TW
        TW = TW.setParam( 'Polarity', TxPolarity(n), ...
                          'TxElemts', LocalAperturePattern );
        TwList{ tw_line_id0 + n } = TW;

        % TX
        TX = TX.setParam( ...
            'twId', Id0.tw + tw_line_id0 + n-1, ...
            'TxElemts', LocalAperturePattern );
        TxList{ tw_line_id0 + n } = TX;
        
        % Transmit duration of event
        EventTxDur = ceil( TwFreq * NbHcycle / 2 + max(TX.getParam('Delays')) );

        % EVENT
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + tw_line_id0 + n-1, ...
            'rxId', Id0.rx + k - 1, ...
            'duration', max(EventRxDur, EventTxDur), ...
            'noop', Pause);
        EventList{end+1} = EVENT;

    end
end


% Update TW and TX parameters
obj = obj.setParam('tw', TwList);
obj = obj.setParam('tx', TxList);

% ============================================================================ %
% ============================================================================ %

%% Build the events

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
if isempty(fieldnames(Struct))
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
end

%% update TX in order to have constant ReconDalays in POPE
tof2FocusMax = max( [ Struct.tx.tof2Focus ] );
for n = 1:length(Struct.tx)
    Struct.tx(n).Delays = Struct.tx(n).Delays + tof2FocusMax - Struct.tx(n).tof2Focus;
    Struct.tx(n).tof2Focus = tof2FocusMax;
end

% One output argument
varargout{1} = Struct;

% Two output arguments
if ( nargout == 2 )
    varargout{2} = varargout{1};
    varargout{1} = obj;
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