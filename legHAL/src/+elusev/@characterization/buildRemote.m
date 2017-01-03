% ELUSEV.CHARACTERIZATION.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.CHARACTERIZATION instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.CHARACTERIZATION instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.CHARACTERIZATION.
%   It cannot be used without all methods of the remoteclass ELUSEV.CHARACTERIZATION and all
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
    
    % Retrieve characterization parameters
    CharactElements  = obj.getParam('CharactElements');
    Pause        = obj.getParam('Pause');
    PauseEnd     = obj.getParam('PauseEnd');
    RxFreq       = obj.getParam('RxFreq');
    RxDuration   = obj.getParam('RxDuration');
    RxDelay   = obj.getParam('RxDelay');
    Waveform      = obj.getParam('Waveform');
    
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
    
    RxBandwidth = 1 ; % we want RF data for caracterization and 1 = 200% (wtf)
    
    NumSamples = 128 ...
        * ceil(max(min(RxFreq * RxDuration , 4096), 128) / 128);
    RxDuration = NumSamples / RxFreq;
    Value      = abs(RxDuration - obj.getParam('RxDuration'));
    if (Value / RxDuration) > 1e-2
        WarnMsg = ['RxDuration was changed from ' ...
            num2str(obj.getParam('RxDuration')) ' us to ' ...
            num2str(RxDuration) ' us.'];
        obj.WarningMessage( WarnMsg )
    end
    obj = obj.setParam('RxDuration', RxDuration);
    
    % ============================================================================ %
    
    % Control the RxDelay
    SkipSamples = floor(RxFreq * RxDelay);
    RxDelay     = SkipSamples / RxFreq ;
    if abs(RxDelay - obj.getParam('RxDelay')) > 1e-2
        WarnMsg = ['RxDelay was changed from ' num2str(obj.getParam('RxDelay')) ...
            ' us to ' num2str(RxDelay) ' us.'];
        obj.WarningMessage( WarnMsg )
    end
    obj = obj.setParam('RxDelay', RxDelay);
    
    % Reception duration of event
    EventRxDur = ceil(RxDuration + RxDelay + 10); % adding 10 µs (not critical in that case)
    
    % ============================================================================ %
    % ============================================================================ %
    
    % Initialize FC objects
    FcList = {};
    FC     = remote.fc( ...
        'Bandwidth', -1, ... %
        obj.Debug);
    
    % Initialize RX
    RxList = {};
    RX     = remote.rx( ...
        'fcId', Id0.fc, ...
        'RxFreq', RxFreq, ...
        'QFilter', RxBandwidth, ...
        obj.Debug);
    
    % RX and FC objects
    
    % 1st FC object
    FcList{1} = FC;
    
    % 1st RX object
    RX = RX.setParam('RxElemts', 1:system.hardware.NbRxChan);
    RxList{1} = RX;
    
    % 2nd FC object
    FcList{2} = FC;
    
    % 2nd RX object
    RX = RX.setParam('fcId', Id0.fc + 1, 'RxElemts', 128+(1:system.hardware.NbRxChan));
    RxList{2} = RX;
    
    % Update FC and RX parameters
    obj = obj.setParam('fc', FcList);
    obj = obj.setParam('rx', RxList);
    
    % ============================================================================ %
    
    % Build the TX and TW objects
    
    % Initialize TW
    TwList = {};
    TW     = remote.tw_arbitrary( ...
        'Waveform', Waveform(1,:), ...
        'DutyCycle',1,...
        obj.Debug);
    
    
    % Initialize TX
    TxList = {};
    TX     = remote.tx_arbitrary(obj.Debug);
    
    % Events and TX
    EventList = {};
    EVENT     = remote.event( ...
        'noop', system.hardware.MinNoop, ...
        'numSamples', NumSamples, ...
        'skipSamples', SkipSamples, ...
        obj.Debug);
    
    
    % loop over element to characterize
    
    for k = 1 : length(CharactElements)
        
        if size(Waveform,1) > 1
            TW = TW.setParam( 'Waveform', Waveform(k,:) );
        end
        TW = TW.setParam( 'TxElemts', CharactElements(k) );
        TwList{k} = TW;
        
        % TX
        TX = TX.setParam( 'twId', Id0.tw + k - 1 );
        TxList{k} = TX;
        
        % Events
        
        if CharactElements(k) > system.hardware.NbRxChan 
            rxIdx = 1;
        else
            rxIdx = 0;
        end
        
        EVENT = EVENT.setParam( ...
            'txId', Id0.tx + k - 1, ...
            'rxId', Id0.rx + rxIdx, ...
            'duration', EventRxDur, ...
            'noop', Pause );
        EventList{k} = EVENT;
        
    end
    
    EventList{end} = EventList{end}.setParam( 'noop', PauseEnd );
    
    
    % Update TW and TX parameters
    obj = obj.setParam( 'tw', TwList );
    obj = obj.setParam( 'tx', TxList );
    
    % Update EVENT parameter
    obj = obj.setParam( 'event', EventList );
    
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
