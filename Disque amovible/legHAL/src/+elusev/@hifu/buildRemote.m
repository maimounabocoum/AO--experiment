% ELUSEV.HIFU.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.HIFU instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.HIFU instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.HIFU.
%   It cannot be used without all methods of the remoteclass ELUSEV.HIFU and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/11

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

% Retrieve hifu parameters
TwFreq     = obj.getParam('TwFreq');
TwDuration = obj.getParam('TwDuration');
TxElemts   = unique(sort(obj.getParam('TxElemts')));
Phase      = obj.getParam('Phase');
DutyCycle  = obj.getParam('DutyCycle');
RxFreq     = obj.getParam('RxFreq');
RxDuration = obj.getParam('RxDuration');
RxElemts   = unique(sort(obj.getParam('RxElemts')));

% ============================================================================ %

% Control on the TxElemts
if ( isempty(TxElemts) )
    
    TxElemts  = 1 : system.probe.NbElemts;
    DutyCycle = 0;
    Phase     = 0;
    
end

% ============================================================================ %

% Control if the cavitation is synthetic
if ( length(RxElemts) ...
        ~= length(unique(mod(RxElemts, system.hardware.NbRxChan))) )
    
    % Elements
    Rcv1  = RxElemts(RxElemts > system.hardware.NbRxChan);
    ElStr = '';
    for k = 1 : length(Rcv1)
        Idx = find(RxElemts(RxElemts < system.hardware.NbRxChan + 1) ...
            == mod(Rcv1(k), system.hardware.NbRxChan));
        if ( ~isempty(Idx) )
            ElStr = [ElStr ', ' num2str(RxElemts(Idx)) '/' num2str(Rcv1(k))];
        end
    end
    
    % Build the prompt of the help dialog box
    ErrMsg = ['Some receiving elements (' ElStr(3:end) ') are using the ' ...
        'same MUX position.'];
    error(ErrMsg);
    
elseif ( (RxDuration ~= 0) && isempty(RxElemts ~= 0) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['Receiving elements should be defined for a non-zero ' ...
        'receiving duration.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Control the phase offset
if ( length(Phase) == 1 )
    Phase = zeros(1, system.hardware.NbTxChan);
elseif ( length(Phase) ~= length(TxElemts) )
    % Build the prompt of the help dialog box
    ErrMsg = ['The PHASE dimension is defined for ' num2str(length(Phase)) ...
        ' elements while it should be defined for each emitting elements, ' ...
        'i.e. for ' num2str(length(TxElemts)) ' elements.'];
    error(ErrMsg);
elseif ( length(Phase) < system.hardware.NbTxChan )
    Tmp             = Phase;
    Phase           = zeros(1, system.hardware.NbTxChan);
    Phase(TxElemts) = Tmp;
end

% ============================================================================ %

% Control the duty cycle
if ( (length(DutyCycle) == 1) && (length(TxElemts) ~= 1) )
    DutyCycle = DutyCycle * ones(1, length(TxElemts));
elseif ( length(DutyCycle) ~= length(TxElemts) )
    % Build the prompt of the help dialog box
    ErrMsg = ['The DUTYCYCLE dimension is defined for ' ...
        num2str(length(DutyCycle)) ' elements while it should be defined ' ...
        'for each emitting elements, i.e. for ' num2str(length(TxElemts)) ...
        ' elements.'];
    error(ErrMsg);
end

% ============================================================================ %
% ============================================================================ %

%% Build the cavitation events
if ( (RxDuration ~= 0) && isempty(find(RxElemts == 0, 1)) )
    
    % Control RXFREQ
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
    
    % Build the cavitation events
    RxTxTw     = obj.buildCavitation();
    TwDuration = TwDuration - sum(RxTxTw(:,1)) * 1e6;
    
else
    RxTxTw = [];
end

% ============================================================================ %

% Build the HIFU emission events
if ( TwDuration > 0 )
    TxTw = obj.buildEmission(TwDuration);
else
    TxTw = [];
end

% ============================================================================ %

% Initialize TW
TwList = {};
TW     = remote.tw_pulse( ...
    'TwFreq', TwFreq, ...
    'TxElemts', TxElemts, ...
    'DutyCycle', DutyCycle, ...
    obj.Debug);

% Initialize TX
TxList = {};
TX     = remote.tx_arbitrary(obj.Debug);

% Initialize FC
FcList = {};
FC     = remote.fc( ...
            'Bandwidth', -1, ...
            obj.Debug);

% Initialize RX
RxList = {};
RX     = remote.rx( ...
            'RxFreq', RxFreq, ...
            'QFilter', 1, ...
            'RxElemts', RxElemts, ...
            'HifuRx', 1, ...
            'fcId', Id0.fc, ...
            obj.Debug);

% Initialize EVENT
EventList = {};
EVENT     = remote.event( ...
                'noop', system.hardware.MinNoop, ...
                obj.Debug);

% ============================================================================ %
% ============================================================================ %

%% Emission events definition

if ~isempty(TxTw)
    
    % Optimized TW and TX for emission events
    OptTxTw = unique(TxTw, 'rows');
    Delays  = Phase / (2*pi * TwFreq);
    
    % Elementary TX
    TX = TX.setParam('Delays', Delays);
    
    for k = 1 : size(OptTxTw, 1)
        
        % Update TW
        TW = TW.setParam( ...
            'NbHcycle', 2 * OptTxTw(k, 2), ...
            'repeat', OptTxTw(k, 3), ...
            'repeat256', OptTxTw(k, 4));
        TwList{end+1} = TW;
        
        % Update TX
        TX  = TX.setParam('twId', Id0.tw + k - 1);
        TxList{end+1} = TX;
        
    end

% ============================================================================ %

    % Update the emission events
    for k = 1 : size(TxTw, 1)

        % Retrieve optimized TW/TX
        Idx = find(TxTw(k, 1) == OptTxTw(:,1), 1, 'first');
        Dur = ceil(OptTxTw(Idx, 1) * 1e6);

        % Update EVENT
        EVENT = EVENT.setParam('txId', Id0.tx + Idx - 1, 'duration', Dur);
        EventList{end+1} = EVENT;

    end
    
end

% ============================================================================ %
% ============================================================================ %

%% Cavitation events definition

% Rescale the TW/TX indexes
Id0.tw = Id0.tw + length(TwList);
Id0.tx = Id0.tx + length(TxList);

% ============================================================================ %

% Build the cavitation events
if ( ~isempty(RxTxTw) )
    
    % Optimized TW and TX for emission events
    OptTxTw = unique(RxTxTw, 'rows');
    Delays  = Phase / (2*pi * TwFreq);
    
    % Elementary TW
    TxDiff = setdiff(TxElemts, RxElemts(ismember(RxElemts, TxElemts))); % get Tx that are not Rx
    if ( isempty(TxDiff) )
        
        TxElemts  = 1 : system.probe.NbElemts;
        DutyCycle = zeros(1, length(TxElemts));
        Delays    = zeros(1, length(TxElemts));
        
    else
        
        DutyCycle        = DutyCycle(TxDiff);
        Delays(RxElemts) = 0;
        
    end
    TxElemts = TxDiff;
    TW = TW.setParam('TxElemts', TxElemts, 'DutyCycle', DutyCycle);
    
    % Elementary TX
    TX = TX.setParam('Delays', Delays);
    
    % Elementary FC
    FcList{end+1} = FC;
    
    % Elementary
    RxList{end+1} = RX;
    
    for k = 1 : size(OptTxTw, 1)
        
        % Update TW
        TwList{end+1} = TW;
        
        % Update TX
        TX  = TX.setParam('twId', Id0.tw + k - 1);
        TxList{end+1} = TX;
        
    end
    
% ============================================================================ %

    % Update the emission events
    EVENT = EVENT.setParam('rxId', Id0.rx);
    for k = 1 : size(RxTxTw, 1)

        % Retrieve optimized TW/TX
        Idx      = find(RxTxTw(k, 1) == OptTxTw(:,1), 1, 'first');
        Dur      = ceil(OptTxTw(Idx, 1) * 1e6);
        NSamples = ...
            min(4096, floor(Dur * obj.getParam('RxFreq') / 128) * 128);

        % Update EVENT
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + Idx - 1, ...
            'numSamples', NSamples, ...
            'duration', Dur);
        EventList{end+1} = EVENT;

    end
    
    % Update FC and RX parameters
    obj = obj.setParam('fc', FcList);
    obj = obj.setParam('rx', RxList);
    
end

% Update TW, TX and EVENT parameters
obj = obj.setParam('tw', TwList);
obj = obj.setParam('tx', TxList);
obj = obj.setParam('event', EventList);

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