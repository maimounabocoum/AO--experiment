% USSE.LTE.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   OBJ = OBJ.BUILDREMOTE() returns the updated USSE.LTE instance OBJ.
%
%   [OBJ NBDMA] = OBJ.BUILDREMOTE() returns the updated USSE.LTE instance OBJ
%   and the number of independent acquisitions.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check function syntax
if ( nargin ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function does not ' ...
        'need any input argument.'];
    error(ErrMsg);
    
elseif ( (nargout ~= 1) && (nargout ~= 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 (or ' ...
        '2) output argument(s):\n' ...
        '    1. a variable to receive the updated ' upper(class(obj)) ...
        ' instance.\n' ...
        '    2. a variable to receive the number of independent acquisitions'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Build the remote structure
if ( nargout == 2 )
    
    [obj varargout{2}] = buildRemote@usse.usse(obj, varargin{1:end});
    
else
    
    obj = buildRemote@usse.usse(obj, varargin{1:end});
    
end

% ============================================================================ %
% ============================================================================ %

%% Mode changes

% Estimate the number of mode with rx events and firing duty cycle
ModeRx = zeros(1, length(obj.RemoteStruct.mode));
Duty   = zeros(2, length(obj.RemoteStruct.event));
for k = 1 : length(obj.RemoteStruct.event)
    
    if ( obj.RemoteStruct.event(k).rxId ~= 0 )
        ModeRx(obj.RemoteStruct.event(k).modeId) = ...
            obj.RemoteStruct.event(k).modeId;
    end
    
    % Retrieve frequency for duty cycle estimation
    ModeId          = obj.RemoteStruct.event(k).modeId;
    [VarName Idx]   = obj.isParam('acmo');
    tmp             = obj.(VarName{1}){Idx{1}, 3}{ModeId};
    [VarName Idx]   = tmp.isParam('elusev');
    tmp             = tmp.(VarName{1}){Idx{1}, 3}{1};
    TwFreq          = tmp.getParam('TwFreq');
    
    % Add the duration for event and duty cycle
    Duty(1, k) = obj.RemoteStruct.event(k).duration;
    if ( TwFreq > 2 )
        DutyFactor = (0.75 - 0.25/2 * TwFreq);
    else
        DutyFactor = 0.5;
    end
    Duty(2, k) = double(obj.RemoteStruct.event(k).duration) ...
        * (1 - DutyFactor) / DutyFactor;
    
end

% ============================================================================ %

% Extract only receiving modes
ModeRx0 = find(sort(ModeRx) > 0);
if ( isempty(ModeRx0) )
    ModeRx0 = 1;
end
Idx         = find(ModeRx == 0);
ModeRx(Idx) = ModeRx0(1);

% Control the number of modes
if ( length(unique(ModeRx)) > 20 )
    % Build the prompt of the help dialog box
    ErrMsg = ['The built sequence contains too many different types of ' ...
        'events. There should be less elementary ultrasound events.'];
    error(ErrMsg);
end

% ============================================================================ %

% Change the mode ids if non receiving modes
if ( ~isempty(Idx) > 0 )
    
    % Update modeId and tgcId in events
    for k = 1 : length(obj.RemoteStruct.event)
        NewModeId = ...
            find(ModeRx(obj.RemoteStruct.event(k).modeId) == unique(ModeRx));
        obj.RemoteStruct.event(k).modeId = NewModeId;
        obj.RemoteStruct.event(k).tgcId  = NewModeId;
    end
    
    % Update modeId in tgc
    for k = 1 : length(obj.RemoteStruct.tgc)
        NewModeId = ...
            find(ModeRx(obj.RemoteStruct.tgc(k).modeId) == unique(ModeRx));
        obj.RemoteStruct.tgc(k).modeId = NewModeId;
    end
    
    % Update mode and tgc
    obj.RemoteStruct.mode = obj.RemoteStruct.mode(unique(ModeRx));
    obj.RemoteStruct.tgc  = obj.RemoteStruct.tgc(unique(ModeRx));
end

% ============================================================================ %
% ============================================================================ %

%% Add firing duty cycle

% Add the firing duty cycle to the sequence
obj.RemoteStruct.tw(end+1) = struct( ...
    'repeat', zeros(1, system.hardware.NbTxChan), ...
    'repeat256', zeros(1, system.hardware.NbTxChan), ...
    'data', 0, ...
    'extendBL', 0, ...
    'legacy', 0, ...
    'maxWfPoints', 1, ...
    'nbWfPoints', ones(1, system.hardware.NbTxChan), ...
    'wf', zeros(1, system.hardware.NbTxChan));
obj.RemoteStruct.tx(end+1) = struct( ...
    'txClock180MHz', 0, ...
    'twId', length(obj.RemoteStruct.tw), ...
    'Delays', zeros(1, system.hardware.NbTxChan, 'single'), ...
    'tof2Focus', 0);

% Loop of the sequence
Loop = obj.RemoteStruct.event(end).jumpToEventId;
obj.RemoteStruct.event(end).jumpToEventId = 0;

% Add the duty cycle
Idx = find(diff(mod(cumsum(Duty(1,:)), 1e7)) < 0);
if ( isempty(Idx) ) % Total duration smaller than 10 seconds
    
    % Build the duty cycle event
    Dur = sum(Duty(1, :));
    if ( Dur > 5000 )
        Dur = ceil(Dur / 5000) * 5000;
    end
    
    DutyEvent = struct( ...
        'txId', length(obj.RemoteStruct.tx), ...
        'rxId', 0, ...
        'hvmuxId', 0, ...
        'tpcTxe', 0, ...
        'localBuffer', 0, ...
        'dmaControlId', 0, ...
        'noop', 25, ...
        'softIrq', -1, ...
        'return', 0, ...
        'goSubEventId', 0, ...
        'waitExtTrig', 0, ...
        'genExtTrig', 0, ...
        'genExtTrigDelay', 0, ...
        'duration', Dur, ...
        'numSamples', 0, ...
        'skipSamples', 0, ...
        'tgcId', 1, ...
        'modeId', 1, ...
        'pauseForEndDma', 0, ...
        'jumpToEventId', 0, ...
        'incrementLocalBufAddr', 1, ...
        'periodExtend', Dur > 5000, ...
        'noopMultiplier', 1);
    
    % Add the DutyCycle event
    obj.RemoteStruct.event = [obj.RemoteStruct.event; DutyEvent];
    
else % Total duration greater than 10 seconds
    
    % Build the intermediate duty cycle
    Idx = [0 Idx length(Duty)];
    for k = 2 : length(Idx)
        Dur(k-1) = sum(Duty(1, Idx(k-1)+1:Idx(k)));
    end
    Idx = Idx(2:end-1);
    
    % Add intermediate duty cycle
    for k = 1 : length(Idx)
        
        % Build the duty cycle event
        if ( Dur(k) > 5000 )
            Dur(k) = ceil(Dur(k) / 5000) * 5000;
        end
        
        DutyEvent = struct( ...
            'txId', length(obj.RemoteStruct.tx), ...
            'rxId', 0, ...
            'hvmuxId', 0, ...
            'tpcTxe', 0, ...
            'localBuffer', 0, ...
            'dmaControlId', 0, ...
            'noop', 25, ...
            'softIrq', -1, ...
            'return', 0, ...
            'goSubEventId', 0, ...
            'waitExtTrig', 0, ...
            'genExtTrig', 0, ...
            'genExtTrigDelay', 0, ...
            'duration', Dur(k), ...
            'numSamples', 0, ...
            'skipSamples', 0, ...
            'tgcId', 1, ...
            'modeId', 1, ...
            'pauseForEndDma', 0, ...
            'jumpToEventId', 0, ...
            'incrementLocalBufAddr', 1, ...
            'periodExtend', Dur(k) > 5000, ...
            'noopMultiplier', 1);
        
        % Add the DutyCycle event
        Tmp = length(obj.RemoteStruct.event);
        obj.RemoteStruct.event = [obj.RemoteStruct.event(1:Idx(k)); ...
            DutyEvent; obj.RemoteStruct.event(Idx(k)+1:end)];
        Idx = Idx + (length(obj.RemoteStruct.event) - Tmp);
        
    end
    
    % Add the final duty cycle event
    if ( length(Idx) < length(Dur) )
        
        % Build the duty cycle event
        if ( Dur(end) > 5000 )
            Dur(end) = ceil(Dur(end) / 5000) * 5000;
        end
        
        DutyEvent = struct( ...
            'txId', length(obj.RemoteStruct.tx), ...
            'rxId', 0, ...
            'hvmuxId', 0, ...
            'tpcTxe', 0, ...
            'localBuffer', 0, ...
            'dmaControlId', 0, ...
            'noop', 25, ...
            'softIrq', -1, ...
            'return', 0, ...
            'goSubEventId', 0, ...
            'waitExtTrig', 0, ...
            'genExtTrig', 0, ...
            'genExtTrigDelay', 0, ...
            'duration', Dur(end), ...
            'numSamples', 0, ...
            'skipSamples', 0, ...
            'tgcId', 1, ...
            'modeId', 1, ...
            'pauseForEndDma', 0, ...
            'jumpToEventId', 0, ...
            'incrementLocalBufAddr', 1, ...
            'periodExtend', Dur(end) > 5000, ...
            'noopMultiplier', 1);
        
        % Add the DutyCycle event
        obj.RemoteStruct.event = [obj.RemoteStruct.event(1:end); DutyEvent];
        
    end
    
end

% Loop the sequence
obj.RemoteStruct.event(end).jumpToEventId = Loop;

% ============================================================================ %
% ============================================================================ %

%% Final steps of the remote structure

% Initialize InfoStruct.event
InfoStruct.event = obj.RemoteStruct.event;
InfoStruct.event = rmfield(InfoStruct.event, ...
    {'dmaControlId', 'goSubEventId', 'hvmuxId', 'localBuffer', 'noop', ...
    'return', 'softIrq', 'tpcTxe', 'pauseForEndDma', 'jumpToEventId', ...
    'incrementLocalBufAddr', 'periodExtend', 'noopMultiplier'});

% Estimate the timeout duration
Timeout    = 0;
TmpDurTot  = 0;
NbDMA      = 0;
WaitTrig   = 0;
for k = 1 : 2
    for m = 1 : length(obj.RemoteStruct.event)
        
        % Check if trigger in
        if ( obj.RemoteStruct.event(m).waitExtTrig == 1 )
            WaitTrig = 1;
        end
        
        % Estimate event duration
        TmpDur = obj.RemoteStruct.event(m).duration ...
            + obj.RemoteStruct.event(m).noop ...
            * obj.RemoteStruct.event(m).noopMultiplier;
        
        % Add duration to timeout
        TmpDurTot = TmpDurTot + TmpDur;
        if ( obj.RemoteStruct.event(m).dmaControlId ~= 0 )
            Timeout = max(Timeout, TmpDurTot);
            TmpDur  = 0;
            if ( k == 1 )
                NbDMA = NbDMA + 1;
            end
        end
        
        % Update event duration and noop
        if ( k == 2 )
            InfoStruct.event(m).duration = TmpDur;
            
            obj.RemoteStruct.event(m).noop = obj.RemoteStruct.event(m).noop * 5;
        end
        
    end
end
Timeout = max(Timeout, TmpDurTot);

% Set the timeout
if ( WaitTrig == 1 )
    obj.RemoteStruct.general.notificationTimeout = 120000;
else
    obj.RemoteStruct.general.notificationTimeout = ...
        max(ceil(Timeout * 1.2 / 1e3), 1000);
end
    
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

InfoStruct.tx = rmfield(InfoStruct.tx, {'twId', 'txClock180MHz'});

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

% Output arguments
if ( isempty(fieldnames(obj.RemoteStruct)) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
elseif ( length(obj.RemoteStruct.mode) > 20 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The built sequence contains too many different types of ' ...
        'events. There should be less elementary ultrasound events.'];
    error(ErrMsg);
    
else
    
    % Build the info structure
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
