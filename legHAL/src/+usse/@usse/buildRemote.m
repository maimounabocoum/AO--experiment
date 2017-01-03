% USSE.USSE.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   OBJ = OBJ.BUILDREMOTE() returns the updated USSE.USSE instance OBJ.
%
%   [OBJ NBDMA] = OBJ.BUILDREMOTE() returns the updated USSE.USSE instance OBJ
%   and the number of independent acquisitions.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/09

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Validation object
varargin = {obj.validation()};

% ============================================================================ %

% Check function syntax
if ( nargin ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function does not ' ...
        'need any input argument.'];
    error(ErrMsg);
    
elseif ( (nargout ~= 1) && (nargout ~= 2) && (nargout ~= 3) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 (or ' ...
        '2) output argument(s):\n' ...
        '    1. a variable to receive the updated ' upper(class(obj)) ...
        ' instance.\n' ...
        '    2. a variable to receive the number of independent acquisitions' ...
        '    3. Acmo'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Export ACMO.ACMO objects (tx/tw/rx/fc/event)

% Initialize REMOTE structure
obj.RemoteStruct.tx         = [];
obj.RemoteStruct.tw         = [];
obj.RemoteStruct.rx         = [];
obj.RemoteStruct.fc         = [];
obj.RemoteStruct.mode       = [];
obj.RemoteStruct.tgc        = [];
obj.RemoteStruct.dmaControl = [];

% Export ACMO.ACMO objects
[VarName Idx] = obj.isParam('acmo');
if ( ~isempty(obj.(VarName{1}){Idx{1}, 3}) )

    % Temporary variable
    TmpAcmo = obj.(VarName{1}){Idx{1}, 3};

    for k = 1 : length(TmpAcmo)
        [TmpAcmo{k} Tmp] = ...
            TmpAcmo{k}.buildRemote(obj.validation());
        Repeat        = single(TmpAcmo{k}.getParam('Repeat'));
        NbLocalBuffer = double(TmpAcmo{k}.getParam('NbLocalBuffer'));
        
        % Updating indexes
        if ( isempty(obj.RemoteStruct.tx)  )
            Id0.tx = 0;
        else
            Id0.tx = length(obj.RemoteStruct.tx);
        end
        if ( isempty(obj.RemoteStruct.tw) )
            Id0.tw = 0;
        else
            Id0.tw = length(obj.RemoteStruct.tw);
        end
        if ( isempty(obj.RemoteStruct.rx) )
            Id0.rx = 0;
        else
            Id0.rx = length(obj.RemoteStruct.rx);
        end
        if ( isempty(obj.RemoteStruct.fc) )
            Id0.fc = 0;
        else
            Id0.fc = length(obj.RemoteStruct.fc);
        end
        if ( isempty(obj.RemoteStruct.mode) )
            Id0.mode = 0;
            Id0.host = 0;
        else
            Id0.mode = length(obj.RemoteStruct.mode);
            Id0.host = obj.RemoteStruct.mode(end).hostBufferIdx(end) + 1;
        end
        if ( isempty(obj.RemoteStruct.tgc) )
            Id0.tgc = 0;
        else
            Id0.tgc = length(obj.RemoteStruct.tgc);
        end
        if ( isempty(obj.RemoteStruct.dmaControl) )
            Id0.dmaControl = 0;
        else
            Id0.dmaControl = length(obj.RemoteStruct.dmaControl);
        end
        
        % Update twId
        if ( ~isempty(Tmp.tw) )
            if ( (Id0.tw ~= 0) && ~isempty(Tmp.tx) )
                for m = 1 : length(Tmp.tx)
                    Tmp.tx(m).twId = Tmp.tx(m).twId + Id0.tw;
                end
                
            end
            
            obj.RemoteStruct.tw = [obj.RemoteStruct.tw; Tmp.tw];
            obj.RemoteStruct.tx = [obj.RemoteStruct.tx; Tmp.tx];
        end
        
        % Update fcId
        if ( ~isempty(Tmp.fc) )
            if ( (Id0.fc ~= 0) && ~isempty(Tmp.rx) )
                for m = 1 : length(Tmp.rx)
                    Tmp.rx(m).fcId = Tmp.rx(m).fcId + Id0.fc;
                end
            end
            
            obj.RemoteStruct.fc = [obj.RemoteStruct.fc; Tmp.fc];
            obj.RemoteStruct.rx = [obj.RemoteStruct.rx; Tmp.rx];
        end
        
        % Update modeId
        if ( ~isempty(Tmp.mode) )
            if ( (Id0.mode ~= 0) && ~isempty(Tmp.tgc) )
                for m = 1 : length(Tmp.tgc)
                    Tmp.tgc(m).modeId = Tmp.tgc(m).modeId + Id0.mode;
                end
            end
            
            if ( Id0.host ~= 0 )
                for m = 1 : length(Tmp.mode)
                    Tmp.mode.hostBufferIdx = ...
                        Tmp.mode.hostBufferIdx + Id0.host;
                end
            end
            
            if ( Id0.tx ~= 0 )
                Tmp.mode.ModeRx(4, :) = Tmp.mode.ModeRx(4, :) + Id0.tx;
            end
            
            if ( Id0.rx ~= 0 )
                Tmp.mode.ModeRx(3, :) = Tmp.mode.ModeRx(3, :) + Id0.rx;
            end
            
            obj.RemoteStruct.mode = [obj.RemoteStruct.mode Tmp.mode];
            obj.RemoteStruct.tgc  = [obj.RemoteStruct.tgc Tmp.tgc];
            
            if ( (Id0.dmaControl ~= 0) && ~isempty(Tmp.dmaControl) )
                Tmp.dmaControl.localBuffer = ...
                    Tmp.dmaControl.localBuffer + Id0.dmaControl;
            end
            obj.RemoteStruct.dmaControl = ...
                [obj.RemoteStruct.dmaControl Tmp.dmaControl];
        end
        
        % Update ids in event
        if ( ~isempty(Tmp.event) )
            
            % Extract Tmp.event
            EventStruct = cell2mat(struct2cell(Tmp.event));
            EventNames  = fieldnames(Tmp.event);
            
            % Initialize labels indexes
            IdxTxId      = find(strcmp('txId', EventNames), 1, 'first');
            IdxRxId      = find(strcmp('rxId', EventNames), 1, 'first');
            IdxNoop      = find(strcmp('noop', EventNames), 1, 'first');
            IdxDuration  = find(strcmp('duration', EventNames), 1, 'first');
            IdxNumSamp   = find(strcmp('numSamples', EventNames), 1, 'first');
            IdxSkipSamp  = find(strcmp('skipSamples', EventNames), 1, 'first');
            IdxModeId    = find(strcmp('modeId', EventNames), 1, 'first');
            IdxTgcId     = find(strcmp('tgcId', EventNames), 1, 'first');
            IdxDmaId     = find(strcmp('dmaControlId', EventNames), 1, 'first');
            IdxLocalBuff = find(strcmp('localBuffer', EventNames), 1, 'first');
            IdxNoopMult  = find(strcmp('noopMultiplier', EventNames), 1, 'first');
            
            % Update txId
            IdxEvent = find(EventStruct(IdxTxId,:) > 0);
            if ( ~isempty(IdxEvent) )
                EventStruct(IdxTxId,IdxEvent) = ...
                    EventStruct(IdxTxId,IdxEvent) + Id0.tx;
            end
            
            % Update duration and rxId
            IdxEvent = find(EventStruct(IdxRxId,:) > 0);
            if ( ~isempty(IdxEvent) )
                IdxRx       = unique(EventStruct(IdxRxId,IdxEvent));
                for kRx = 1 : length(IdxRx)
                    kEvent  = find(EventStruct(IdxRxId,:) == IdxRx(kRx));
                    QFilter = double(Tmp.rx(IdxRx(kRx)).QFilter);
                    Freq = double(Tmp.rx(IdxRx(kRx)).Freq); % [MHz]
                    SampPer = QFilter / Freq; % [us]
                    
                    % Estimate sampling duration
                    NewDur = ceil(EventStruct(IdxNumSamp,kEvent) * SampPer ...
                        + EventStruct(IdxSkipSamp,kEvent) / Freq ...
                        ); % + 0.11 * SampPer + 4); % wtf ?

                    % New value for event and noop duration
                    EventDur = EventStruct(IdxDuration,kEvent) ...
                        + EventStruct(IdxNoop,kEvent);
                    EventStruct(IdxDuration,kEvent) = max([squeeze(NewDur) ...
                        squeeze(EventStruct(IdxDuration,kEvent))], [], 2);
                    EventStruct(IdxNoop,kEvent) = ...
                        max( single(EventDur - EventStruct(IdxDuration,kEvent)), ...
                        system.hardware.MinNoop);
                    
                end
                EventStruct(IdxRxId,IdxEvent) = ...
                    EventStruct(IdxRxId,IdxEvent) + Id0.rx;
            end
            
            % Update modeId
            IdxEvent  = find(EventStruct(IdxModeId,:) > 0);
            if ( ~isempty(IdxEvent) )
                EventStruct(IdxModeId,IdxEvent) = ...
                    EventStruct(IdxModeId,IdxEvent) + Id0.mode;
            end
            
            % Update tgcId
            IdxEvent = find(EventStruct(IdxTgcId,:) > 0);
            if ( ~isempty(IdxEvent) )
                EventStruct(IdxTgcId,IdxEvent) = ...
                    EventStruct(IdxTgcId,IdxEvent) + Id0.tgc;
            end
            
            % Update dmaControlId
            IdxEvent = find(EventStruct(IdxDmaId,:) > 0);
            if ( ~isempty(IdxEvent) )
                EventStruct(IdxDmaId,IdxEvent) = ...
                    EventStruct(IdxDmaId,IdxEvent) + Id0.dmaControl;
            end
            
            % Update localBuffer
            EventStruct(IdxLocalBuff,:) = ...
                EventStruct(IdxLocalBuff,:) + Id0.dmaControl;
            
            % Update NoopMultiplier
            IdxEvent = find(EventStruct(IdxNoop,:) > 1024);
            if ( ~isempty(IdxEvent) )
                
                % Estimate Noop variables
                Noop = permute( ...
                    single(squeeze(EventStruct(IdxNoop,IdxEvent))), [2 1]);
                NoopMult = repmat(1 : min(round(max(2 * Noop(:))), 512), ...
                    [length(Noop), 1]);
                Noop     = repmat(Noop, [1, size(NoopMult, 2)]);
                NewNoop  = round(Noop ./ NoopMult);
                NewNoop(NewNoop > 1024) = Inf;
                
                % Determine NoopMult and NewNoop
                [Val NoopMult] = min(abs(Noop - NewNoop .* NoopMult), [], 2);
                Noop   = single(squeeze(EventStruct(IdxNoop,IdxEvent)));
                IdxErr = find((Val(:) ./ Noop(:)) > 1e-3, 1, 'first');
                if ( isempty(IdxErr) )
                    EventStruct(IdxNoop,IdxEvent) = ...
                        round(Noop(:) ./ NoopMult(:));
                    
                    EventStruct(IdxNoopMult,IdxEvent) = NoopMult;
                else
                    
                    % Build the prompt of the help dialog box
                    ErrMsg = ['It was not possible to determine an adequat ' ...
                        'noop multiplier. You should change the noop ' ...
                        'duration.'];
                    error(ErrMsg);
                    
                end
                
            end
            
            % ACMO repetition
            if Repeat > 1
                
                if NbLocalBuffer ~= 0
                    
                    if ( mod(Repeat, NbLocalBuffer) ~= 0 )
                        % Build the prompt of the help dialog box
                        ErrMsg = ['The number of repetition (' ...
                            num2str(Repeat) ') should be a multiple of the ' ...
                            'number of local buffer (' ...
                            num2str(NbLocalBuffer) ').'];
                        error(ErrMsg);
                    end
                    
                else
                    
                    NbLocalBuffer = 2;
                    
                end
                
                % Duplicate events
                NbEvents    = size(EventStruct, 2);
                IdxEvent    = find(EventStruct(IdxDmaId,:) > 0);
                NbDMAs      = max(EventStruct(IdxDmaId,IdxEvent)) - Id0.dmaControl;
                EventStruct = repmat(EventStruct, [1 NbLocalBuffer]);

                % Add the new dmaControl fields
                if NbDMAs > 0
                    IdxDMA = size(obj.RemoteStruct.dmaControl, 2);
                    obj.RemoteStruct.dmaControl = [obj.RemoteStruct.dmaControl ...
                        repmat(Tmp.dmaControl, [1 NbLocalBuffer-1])];

                    for kLocal = 1 : NbLocalBuffer - 1

                        % Update the dmaControl fields
                        for kDMA = ( (1 : NbDMAs) + IdxDMA + NbDMAs * (kLocal - 1))
                            obj.RemoteStruct.dmaControl(kDMA).localBuffer = ...
                                obj.RemoteStruct.dmaControl(kDMA).localBuffer + NbDMAs * kLocal;
                        end

                        % Update dmaControlId and localBuffer fields of the EVENT field
                        EventStruct(IdxDmaId,IdxEvent + NbEvents * kLocal) = ...
                            EventStruct(IdxDmaId,IdxEvent + NbEvents * kLocal) ...
                            + NbDMAs * kLocal;
                        TmpIdxEvent = kLocal * NbEvents + 1 : (kLocal+1) * NbEvents;
                        EventStruct(IdxLocalBuff,TmpIdxEvent,1) = ...
                            EventStruct(IdxLocalBuff,TmpIdxEvent,1) + kLocal*NbDMAs;

                    end
                end
                
                % Set the even number of repetition
                EventStruct = repmat(EventStruct, [1 floor(Repeat/NbLocalBuffer)]);
                
                % Set the additional events if odd number of repetition
                if rem(Repeat, 2) == 1  &&  size( EventStruct, 2 ) < Repeat
                    EventStruct = [EventStruct EventStruct(:, 1:NbEvents)];
                end
                
            end
            
            % Update AcmoStruct.event
            AcmoStruct(k).event = EventStruct;
            AcmoStruct(k).Desc  = obj.Pars{Idx{1}, 3}{k}.Desc;
            AcmoStruct(k).Type  = obj.Pars{Idx{1}, 3}{k}.Type;
            
        end
        
    end
    
    % Update acmo list
    obj.(VarName{1}){Idx{1}, 3} = TmpAcmo;

end

% ============================================================================ %
% ============================================================================ %

%% Organize events

% Initialize variables
Ordering    = obj.getParam('Ordering');
EventStruct = [];

% Oragnize events regarding the ORDERING parameter
if ( (length(Ordering) == 1) && (Ordering == 0) ) % chronological order
    
    for k = 1 : length(AcmoStruct)
        EventStruct = [EventStruct squeeze(AcmoStruct(k).event)];
    end
    
% Ordering values does not correspond to an ELUSEV
elseif ( ~isempty(find(Ordering > length(AcmoStruct), 1)) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ORDERING parameter contains at a least a value ' ...
        'greater than the number of ACMO objects (' ...
        num2str(length(AcmoStruct)) '):\n'];
    for k = 1 : length(AcmoStruct)
        ErrMsg = [ErrMsg ...
            '    #' num2str(k) ' - ' AcmoStruct(k).Desc ' (' ...
            upper(AcmoStruct(k).Type) ')\n'];
    end
    error(ErrMsg(1:end-2));
    
    % Ordering values does not call at least on value
elseif ( length(unique(Ordering)) ~= length(AcmoStruct) )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The ORDERING parameter does not use:\n';
    for k = 1 : length(AcmoStruct)
        if ( isempty(find(Ordering == k, 1)) )
            ErrMsg = [ErrMsg ...
                '    #' num2str(k) ' - ' AcmoStruct(k).Desc ' (' ...
                upper(AcmoStruct(k).Type) ')\n'];
        end
    end
    error(ErrMsg(1:end-2));
    
% Build the customed ordering
else
    
    for k = 1 : length(Ordering)
        EventStruct = [EventStruct AcmoStruct(Ordering(k)).event];
    end
    
end

% ============================================================================ %
% ============================================================================ %

%% Final steps of the remote structure and build InfoStruct

% Build TPC
[tpc tpcFields]      = obj.getParam('TPC').buildRemote(varargin{1:end});
obj.RemoteStruct.tpc = cell2struct(tpc, tpcFields, 2);

% ============================================================================ %

% Initialize indexes
IdxDuration    = find(strcmp('duration', EventNames), 1, 'first');
IdxNoop        = find(strcmp('noop', EventNames), 1, 'first');
IdxNoopMult    = find(strcmp('noopMultiplier', EventNames), 1, 'first');
IdxDmaId       = find(strcmp('dmaControlId', EventNames), 1, 'first');
IdxWaitTrig    = find(strcmp('waitExtTrig', EventNames), 1, 'first');
IdxJumpEventId = find(strcmp('jumpToEventId', EventNames), 1, 'first');

% Estimate timeout duration
Duration    = EventStruct(IdxDuration,:) ...
    + EventStruct(IdxNoop,:) .* EventStruct(IdxNoopMult,:);
TmpDuration = [Duration Duration];
DMAevents   = permute(find(EventStruct(IdxDmaId,:,1) ~= 0), [2 1]);
NbDMA       = length(DMAevents);
DMAloop     = [0; DMAevents; (DMAevents+length(Duration))];
Timeout     = zeros(1, length(DMAloop));
for k = 2 : length(DMAloop)
    Timeout(k-1) = sum(TmpDuration(DMAloop(k-1) + 1 : DMAloop(k)));
end
Timeout = max(Timeout(:));

% Trigger in enabled
WaitTrig = ~isempty(find(EventStruct(IdxWaitTrig,:) ~= 0, 1, 'first'));

% Rescale noop
EventStruct(IdxNoop,:) = 5 * EventStruct(IdxNoop,:);

% Loop the sequence
EventStruct(IdxJumpEventId,end) = obj.getParam('Loop');

% Update the EVENT field of the RemoteStruct
obj.RemoteStruct.event = cell2struct(num2cell(EventStruct), EventNames, 1);

% ============================================================================ %

% Build the GENERAL field of the RemoteStruct

% Set the timeout (ms)
if WaitTrig == 1
    obj.RemoteStruct.general.notificationTimeout = max( common.constants.NotificationTimeout, 1000);
    obj.RemoteStruct.general.notificationTrigInTimeout = common.constants.NotificationTrigInTimeout;
else
    obj.RemoteStruct.general.notificationTimeout = ...
        max(ceil(Timeout * 1.2 / 1e3), 1000);
end

% Repeat n-times the sequence
Repeat = obj.getParam('Repeat');
if ( (Repeat > 1) && (obj.getParam('Loop') == 0) )
    obj.RemoteStruct.general.dmaCounter       = NbDMA * Repeat;
    obj.RemoteStruct.event(end).jumpToEventId = 1;
else
    obj.RemoteStruct.general.dmaCounter       = 0;
end

% Authorize frame dropping
obj.RemoteStruct.general.hostBufferFullNotification = ...
    abs(obj.getParam('DropFrames') - 1);

% ============================================================================ %

% Build InfoStruct.event
IdxDmaId        = find(strcmp('dmaControlId', EventNames), 1, 'first');
IdxDuration     = find(strcmp('duration', EventNames), 1, 'first');
IdxTrigOut      = find(strcmp('genExtTrig', EventNames), 1, 'first');
IdxTrigOutDelay = find(strcmp('genExtTrigDelay', EventNames), 1, 'first');
IdxNumSamples   = find(strcmp('numSamples', EventNames), 1, 'first');
IdxRxId         = find(strcmp('rxId', EventNames), 1, 'first');
IdxSkipSamples  = find(strcmp('skipSamples', EventNames), 1, 'first');
IdxTxId         = find(strcmp('txId', EventNames), 1, 'first');
IdxTrigIn       = find(strcmp('waitExtTrig', EventNames), 1, 'first');
IdxModeId       = find(strcmp('modeId', EventNames), 1, 'first');

% Update the EVENT field for InfoStruct
EventStruct(IdxDmaId,:)    = EventStruct(IdxDmaId,:) > 0; % dma event
EventStruct(IdxDuration,:) = Duration;                    % total duration

% Update the EVENT field names for InfoStruct
EventNames{IdxDmaId}        = 'DMA';
EventNames{IdxTrigOut}      = 'TrigOutDuration';
EventNames{IdxTrigOutDelay} = 'TrigOutDelay';
EventNames{IdxTrigIn}       = 'TrigIn';

% Build the EVENT field of InfoStruct
Idx              = [IdxDmaId, IdxDuration, IdxTrigOut, IdxTrigOutDelay, ...
    IdxNumSamples, IdxRxId, IdxSkipSamples, IdxTxId, IdxTrigIn, IdxModeId];
InfoStruct.event = ...
    cell2struct(num2cell(EventStruct(Idx, :)), EventNames(Idx), 1);

% ============================================================================ %

% Build InfoStruct.tx
InfoStruct.tx = obj.RemoteStruct.tx;

for k = 1 : length(InfoStruct.tx)
    
    % Retrieve twId
    twId = InfoStruct.tx(k).twId;
    
    % Reshaped waveform
    InfoStruct.tx(k).waveform = ...
        reshape(obj.RemoteStruct.tw(twId).wf, [], system.hardware.NbTxChan);
    
    % Repeat factor of the waveform
    InfoStruct.tx(k).repeat = ...
        (unique(obj.RemoteStruct.tw(twId).repeat) + 1) ...
        .* (1 + 255 * unique(obj.RemoteStruct.tw(twId).repeat256));
    
end

if isfield( InfoStruct.tx, 'twId') && isfield( InfoStruct.tx, 'txClock180MHz' )
    InfoStruct.tx = rmfield(InfoStruct.tx, {'twId', 'txClock180MHz'});
end

% ============================================================================ %

% Build InfoStruct.rx
InfoStruct.rx = obj.RemoteStruct.rx;

if ~isempty( InfoStruct.rx )
    % Loop over all rx
    for k = 1 : length(InfoStruct.rx)
        % Estimate the rx frequency
        InfoStruct.rx(k).Bandwidth = 200 ./ 2^(InfoStruct.rx(k).QFilter-1);
    end

    InfoStruct.rx = rmfield(InfoStruct.rx, ...
        {'QFilter', 'VGALowGain', 'clipMode', 'fcId', 'harmonicFilter', ...
        'VGAInputFilter', 'ADFilter', 'ADRate', 'lvMuxBlock'});
end
% ============================================================================ %

% Build InfoStruct.mode
InfoStruct.mode = obj.RemoteStruct.mode;

% Loop over all mode
for k = 1 : length(InfoStruct.mode)
    
    % Retrieve the TGC waveform
    InfoStruct.mode(k).tgc = obj.RemoteStruct.tgc(k).wf;
    
    % Retrieve buffer parameters
    InfoStruct.mode(k).channelSize  = InfoStruct.mode(k).channelSize(1);
    InfoStruct.mode(k).nbHostBuffer = length(InfoStruct.mode(k).hostBufferIdx);
    
end

InfoStruct.mode = rmfield(InfoStruct.mode, ...
    {'hostBufferSize', 'hostBufferIdx'});

% ============================================================================ %

% Export InfoStruct
obj.InfoStruct = InfoStruct;

% ============================================================================ %
% ============================================================================ %

%% Check output arguments and build INFOSTRUCT structure

% Number of host buffer
NbHostTot = 0;
for k = 1 : length(obj.RemoteStruct.mode)
    NbHost = max(obj.RemoteStruct.mode(k).hostBufferIdx) + 1;
    if ( NbHostTot < NbHost )
        NbHostTot = NbHost;
    end
end

% Number of local buffer
NbLocalTot = 0;
for k = 1 : length(obj.RemoteStruct.dmaControl)
    NbLocal = obj.RemoteStruct.dmaControl(k).localBuffer + 1;
    if ( NbLocalTot < NbLocal )
        NbLocalTot = NbLocal;
    end
end

% Check DAB memory limit
sample_size_in_bytes = 2;

total_local_buffers_size = 0;
tmp_nb_local_buffers = max( [ obj.RemoteStruct.event.localBuffer ] ) ;

for tmp_buffer_id = 0:tmp_nb_local_buffers
    
    events_using_this_buffer = find( [ obj.RemoteStruct.event.localBuffer ] == tmp_buffer_id ) ;

    buffer_size = ceil( sum( [ obj.InfoStruct.event( events_using_this_buffer ).numSamples ] ) / 1024 ) * 1024 ...
        * 128*sample_size_in_bytes;

    total_local_buffers_size = total_local_buffers_size + buffer_size ;
end

if total_local_buffers_size > system.hardware.MaxLocalBuffersSize
     ErrMsg = [ 'The total local buffer size is too high (' num2str(total_local_buffers_size) '), the limit is ' num2str(system.hardware.MaxLocalBuffersSize) ];
     error(ErrMsg);
end

if isempty(fieldnames(obj.RemoteStruct))

    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
elseif NbHostTot > common.legHAL.RemoteMaxNbHostBuffers

    ErrMsg = ['The built sequence contains needs too many distinct memory ' ...
        'buffers (host buffers). You should use less ACMOs, or set the ' ...
        'number of host buffer to a smaller value for several ACMOs.'];
    error(ErrMsg);
    
elseif NbLocalTot * NbHostTot > system.hardware.SGLsize

    ErrMsg = ['The built sequence contains too many combinations of local ' ...
        'buffers and host buffers. Several ACMOs should not be repeated or ' ...
        'should use less host buffers ( NbLocalTot = ' num2str(NbLocalTot) ' and NbHostTot = ' num2str(NbHostTot) ' ).'];
    error(ErrMsg);
    
elseif length(obj.RemoteStruct.event) > system.hardware.MaxEvents

    ErrMsg = ['The built sequence contains too many events. It should be ' ...
        'reduced by using for instance the Repeat parameter to execute ' ...
        'several times the sequence.'];
    error(ErrMsg);
    
else
    
    varargout{1} = obj;
    
    % Dialog box for the number of getData...
    if nargout == 2
        varargout{2} = NbDMA;
    else
        if nargout == 3
            varargout{3} = TmpAcmo;
        end
    end

    if nargout == 1
        if NbDMA == 0
            uiwait(warndlg(['There are no data transfers in this sequence. ' ...
                'No call of function GETDATA is needed.'], ...
                'Build REMOTE sequence'));
        elseif NbDMA == 1
            uiwait(warndlg(['There is 1 data transfer in this sequence. ' ...
                'You should call once the function GETDATA.'], ...
                'Build REMOTE sequence'));
        else
            uiwait(warndlg(['There are ' num2str(NbDMA) ' data transfers ' ...
                'in this sequence. You should call ' num2str(NbDMA) ...
                ' times the function GETDATA.'], 'Build REMOTE sequence'));
        end
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
