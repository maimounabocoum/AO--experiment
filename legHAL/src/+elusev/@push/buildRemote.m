% ELUSEV.PUSH.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.PUSH instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.PUSH instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.PUSH.
%   It cannot be used without all methods of the remoteclass ELUSEV.FLAT and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04$
% MATLAB class method

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

% ============================================================================ %
% ============================================================================ %

%% Retrieve parameters and control their value

% Retrieve push parameters
TwFreq       = obj.getParam('TwFreq');
Duration     = obj.getParam('Duration');
PushDuration = obj.getParam('PushDuration');
DutyCycle    = obj.getParam('DutyCycle');
PosX         = obj.getParam('PosX');
PosZ         = obj.getParam('PosZ');
TxCenter     = obj.getParam('TxCenter');
RatioFD      = obj.getParam('RatioFD');
ApodFct      = obj.getParam('ApodFct');

% ============================================================================ %

% Control PushDuration and Duration
if ( PushDuration > Duration )
    
    ErrMsg = ['The PUSHDURATION parameter (' num2str(PushDuration) ' us) ' ...
        'cannot be greater than the DURATION parameter (' num2str(Duration) ...
        'us).'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Control if several pushes needs to be generated
NbPushes = max([length(PosX) length(PosZ) length(RatioFD) length(TxCenter) length(DutyCycle)]);

% Adapt the length of DutyCycle
if ( length(DutyCycle) == 1 )
    DutyCycle = repmat(DutyCycle, [1 NbPushes]);
elseif ( length(DutyCycle) ~= NbPushes )
    
    ErrMsg = ['The DutyCycle parameter has ' num2str(length(DutyCycle)) ' values, ' ...
        'while it should contain 1 or ' num2str(NbPushes) ' values.'];
    error(ErrMsg);
    
end 

% Adapt the length of POSX
if ( length(PosX) == 1 )
    PosX = repmat(PosX, [1 NbPushes]);
elseif ( length(PosX) ~= NbPushes )
    
    ErrMsg = ['The POSX parameter has ' num2str(length(PosX)) ' values, ' ...
        'while it should contain 1 or ' num2str(NbPushes) ' values.'];
    error(ErrMsg);
    
end    

% Adapt the length of POSZ
if ( length(PosZ) == 1 )
    PosZ = repmat(PosZ, [1 NbPushes]);
elseif ( length(PosZ) ~= NbPushes )
    
    ErrMsg = ['The POSZ parameter has ' num2str(length(PosZ)) ' values, ' ...
        'while it should contain 1 or ' num2str(NbPushes) ' values.'];
    error(ErrMsg);
    
end    

% Adapt the length of RATIOFD
if ( length(RatioFD) == 1 )
    RatioFD = repmat(RatioFD, [1 NbPushes]);
elseif ( length(RatioFD) ~= NbPushes )
    
    ErrMsg = ['The RATIOFD parameter has ' num2str(length(RATIOFD)) ...
        ' values, while it should contain 1 or ' num2str(NbPushes) ' values.'];
    error(ErrMsg);
    
end    

% Adapt the length of TxCenter
if ( length(TxCenter) == 1 )
    TxCenter = repmat(TxCenter, [1 NbPushes]);
elseif ( length(TxCenter) ~= NbPushes )
    
    ErrMsg = ['The TXCENTER parameter has ' num2str(length(TxCenter)) ...
        ' values, while it should contain 1 or ' num2str(NbPushes) ' values.'];
    error(ErrMsg);
    
end    

% ============================================================================ %

% Evaluate the Repeat and Repeat256 values
MaxSamples   = single(system.hardware.MaxSamples);
TwPeriod     = 1 / TwFreq;
NSampPeriod  = floor(system.hardware.ClockFreq / TwFreq);
PossRepeat   = [(1:1024) ((1:1024) * 256)];
NbPossCycles = PossRepeat' * (1 : floor(MaxSamples / NSampPeriod));
PossDuration = NbPossCycles .* TwPeriod;
PossDuration = PossDuration .* (PossDuration <= PushDuration);

[Repeat NbHcycle] = find(PossDuration == max(PossDuration(:)), 1, 'first');

Eval = abs(PossDuration(Repeat, NbHcycle) - PushDuration);
if ( Eval > (.05 * PushDuration) )
    WarnMsg = ['The PUSHDURATION parameter has been changed to ' ...
        num2str(PossDuration(Repeat, NbHcycle)) ' us.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('PushDuration', PossDuration(Repeat, NbHcycle));

% Create the REPEAT, REPEAT256 and NBHCYCLE variables
Repeat256 = int32( rem(PossRepeat(Repeat), 256) == 0 );
Repeat    = PossRepeat(Repeat) / (1 + 255 * Repeat256);
NbHcycle  = 2 * NbHcycle;

% ============================================================================ %
% ============================================================================ %

%% Build the emission

% Sets the TX channels
ApertWidth = PosZ ./ RatioFD;
NbElemts   = system.probe.NbElemts;
switch system.probe.Type
    
    case 'linear'
        
        % Estimate element positions
        PrPitch   = system.probe.Pitch;               % probe pitch
        ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch; % element positions
        
    case 'curved'
        
        % Estimate element positions
        PrPitch   = system.probe.Pitch;               % probe pitch
        ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch; % element positions
        
    otherwise
        
        ErrMsg = ['The ' upper(class(obj)) ' setDelays function is not yet ' ...
            'implemented for ' lower(system.probe.Type) ' probes.'];
        error(ErrMsg);
        
end

MinApert = zeros(1, NbPushes);
MaxApert = zeros(1, NbPushes);
for k = 1 : NbPushes
    
    % 1st TX channel
    tmpMin = double(max(floor(TxCenter(k) - ApertWidth(k) / 2), ElemtXpos(1)));
    tmpMin = find(tmpMin <= ElemtXpos, 1, 'first');
    
    % Last TX channel
    tmpMax = double(min(ceil(TxCenter(k) + ApertWidth(k) / 2), ElemtXpos(end)));
    tmpMax = find(tmpMax >= ElemtXpos, 1, 'last');
    
    % Check transmission elements
    if ( isempty(tmpMin) )
        
        ErrMsg = ['No first element belonging to the probe could be identified ' ...
            'for emission.'];
        error(ErrMsg);
        
    elseif ( isempty(tmpMax) )
        
        ErrMsg = ['No last element belonging to the probe could be identified ' ...
            'for emission.'];
        error(ErrMsg);
        
    else
        
        MinApert(k) = tmpMin;
        MaxApert(k) = tmpMax;
        
    end
    
end

% ============================================================================ %

% Sets the push events

% Initialize Event

EVENT = remote.event( ...
    'txId', Id0.tx, ...
    'noop', 200, ...
    'duration', PushDuration, ...
    obj.Debug);

% Initialize TW

TW  = remote.tw_pulse( ...
    'TxElemts', 1:system.probe.NbElemts, ...
    'repeat', Repeat - 1, 'repeat256', Repeat256, ...
    'ApodFct', ApodFct, 'DutyCycle', DutyCycle(1), 'NbHcycle', NbHcycle,...
    'TwFreq', TwFreq, ...
    obj.Debug);

% Initialize TX
TX  = remote.tx_focus(obj.Debug);

% Loop for all events
for k = 1 : NbPushes

    if k==1
        EVENT = EVENT.setParam('tpcTxe', NbPushes, 'noop', round(Duration - PushDuration), ...
    	'duration', PushDuration,'txId', Id0.tx);
    else
        EVENT = EVENT.setParam('tpcTxe', 0, 'noop', round(Duration - PushDuration), ...
    	'duration', PushDuration,'txId', Id0.tx + k -1);
    end

    % TX
    TX  = TX.setParam('twId', Id0.tw + k -1, 'PosX', PosX(k), 'PosZ', PosZ(k));
    TxList{k} = TX;
    
    % TW
    TW  = TW.setParam( 'TxElemts',MinApert(k):MaxApert(k), 'DutyCycle',DutyCycle(k));
    TwList{k} = TW;
    
    % EVENT
    EventList{k} = EVENT;
    
end

% ============================================================================ %

% Update TX, TW and EVENT parameters
obj = obj.setParam('tx', TxList);
obj = obj.setParam('tw', TwList);
obj = obj.setParam('event', EventList);

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

% Build structure out of existing remotepar
[obj Struct] = buildRemote@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %

% Control the event duration
for k = 1 : NbPushes
    
    % Estimate event duration with delays and noop duration
    NewDuration = ceil(single(Struct.event(k).duration) ...
        + max(Struct.tx(k).Delays(:)));
    NewNoop     = ceil(single(Struct.event(k).noop) ...
        - (NewDuration - PushDuration));
    
    if ( NewNoop < system.hardware.MinNoop )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The DURATION parameter (' num2str(Duration) ') should be set at least to ' ...
            num2str(NewDuration + system.hardware.MinNoop) ' us.'];
        error(ErrMsg);

    else
        
        Struct.event(k).duration = int32(NewDuration);
        Struct.event(k).noop     = int32(NewNoop);
        
    end
end

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