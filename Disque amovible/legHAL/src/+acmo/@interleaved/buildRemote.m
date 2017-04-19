% ACMO.INTERLEAVED.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ACMO.INTERLEAVED instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ACMO.INTERLEAVED
%   instance OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ACMO.INTERLEAVED. It cannot be used without all methods of the remoteclass
%   ACMO.INTERLEAVED and all methods of its superclass ACMO.ACMO developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/03

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% Check syntax

if ( (nargout ~= 1) && (nargout ~= 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve parameters and control their value

% Retrieve parameters
ACMO            = obj.getParam('ACMO');
NbEvents        = single(obj.getParam('NbEvents'));
TimeIntegration = obj.getParam('TimeIntegration');

% ============================================================================ %

% Control the ACMOs
if ( length(ACMO) == 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The INTERLEAVED ACMO is not designed to be used with only ' ...
        'one ACMO. You should add at least another ACMO.'];
    error(ErrMsg);
    
end

for k = 1 : length(ACMO)
    
    % The REPEAT factor of each acmo should be equal to 1
    if ( ACMO{k}.getParam('Repeat') ~= 1 )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The REPEAT parameter of ACMO ' upper(ACMO{k}.Name) ' is ' ...
            'set to ' num2str(ACMO{k}.getParam('Repeat')) '. It should be ' ...
            'set to 1.'];
        error(ErrMsg);
        
    end
    
    % The NBHOSTBUFFER factor of each acmo should be equal to 1
    if ( ACMO{k}.getParam('NbHostBuffer') ~= 1 )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The NBHOSTBUFFER parameter of ACMO ' upper(ACMO{k}.Name) ...
            ' is set to ' num2str(ACMO{k}.getParam('NbHostBuffer')) '. It ' ...
            'should be set to 1.'];
        error(ErrMsg);
        
    end
    
end

% ============================================================================ %

% Control NBEVENTS
if ( length(NbEvents) == 1 )
    
    NbEvents = repmat(NbEvents, [1 length(ACMO)]);
    
elseif ( ~isvector(NbEvents) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The NBEVENTS parameter should be a ' num2str(length(ACMO)) ...
        '-elements long vector, or at least a single value'];
    error(ErrMsg);
    
elseif ( length(NbEvents) ~= length(ACMO) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The NBEVENTS parameter should be a ' num2str(length(ACMO)) ...
        '-elements long vector, or at least a single value'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Build the remote structure for each ACMO and update indexes

% Initialize variables
Struct.tw          = []; Ids.tw          = [];
Struct.tx          = []; Ids.tx          = [];
Struct.fc          = []; Ids.fc          = [];
Struct.rx          = []; Ids.rx          = [];
Struct.mode        = []; Ids.mode        = [];
Struct.tgc         = []; Ids.tgc         = [];
Struct.dmaControl  = []; Ids.dmaControl  = [];
Struct.event       = [];

% ============================================================================ %

% Loop over all ACMOs
for k = 1 : length(ACMO)
    
    % Build the remote structure
    TmpStruct(k) = ACMO{k}.buildRemote(varargin{1:end});
    
    % Update the TW field
    Ids.tw    = [Ids.tw length(Struct.tw)];
    Struct.tw = [Struct.tw; TmpStruct(k).tw];
    
    % Update the TX field
    Ids.tx = [Ids.tx length(Struct.tx)];
    for m = 1 : length(TmpStruct(k).tx)
        TmpStruct(k).tx(m).twId = TmpStruct(k).tx(m).twId + Ids.tx(k);
    end
    Struct.tx = [Struct.tx; TmpStruct(k).tx];
    
    % Update the FC field
    Ids.fc    = [Ids.fc length(Struct.fc)];
    Struct.fc = [Struct.fc; TmpStruct(k).fc];
    
    % Update the RX field
    Ids.rx    = [Ids.rx length(Struct.rx)];
    for m = 1 : length(TmpStruct(k).rx)
        TmpStruct(k).rx(m).fcId = TmpStruct(k).rx(m).fcId + Ids.fc(k);
    end
    Struct.rx = [Struct.rx; TmpStruct(k).rx];
    
    % Update the MODE field
    Ids.mode    = [Ids.mode length(Struct.mode)];
    for m = 1 : length(TmpStruct(k).mode)
        TmpStruct(k).mode(m).ModeRx(3,:) = ...
            TmpStruct(k).mode(m).ModeRx(3,:) + Ids.rx(k);
        TmpStruct(k).mode(m).ModeRx(4,:) = ...
            TmpStruct(k).mode(m).ModeRx(4,:) + Ids.tx(k);
    end
    Struct.mode = [Struct.mode TmpStruct(k).mode];
    
    % Update the TGC field
    Ids.tgc = [Ids.tgc length(Struct.tgc)];
    for m = 1 : length(TmpStruct(k).tgc)
        TmpStruct(k).tgc(m).modeId = TmpStruct(k).tgc(m).modeId + Ids.mode(k);
    end
    Struct.tgc = [Struct.tgc TmpStruct(k).tgc];
    
    % Update dmaControl
    Ids.dmaControl = [Ids.dmaControl length(Struct.dmaControl)];
    for m = 1 : length(TmpStruct(k).dmaControl)
        TmpStruct(k).dmaControl(m).localBuffer = ...
            TmpStruct(k).dmaControl(m).localBuffer + Ids.dmaControl(k);
    end
    Struct.dmaControl = [Struct.dmaControl TmpStruct(k).dmaControl];
    
    % Update event
    for m = 1 : length(TmpStruct(k).event)
        TmpStruct(k).event(m).modeId      = ...
            TmpStruct(k).event(m).modeId + Ids.mode(k);
        TmpStruct(k).event(m).tgcId       = ...
            TmpStruct(k).event(m).tgcId + Ids.tgc(k);
        TmpStruct(k).event(m).localBuffer = ...
            TmpStruct(k).event(m).localBuffer + Ids.dmaControl(k);
        if ( TmpStruct(k).event(m).txId ~= 0 )
            TmpStruct(k).event(m).txId = TmpStruct(k).event(m).txId + Ids.tx(k);
        end
        if ( TmpStruct(k).event(m).rxId ~= 0 )
            TmpStruct(k).event(m).rxId = TmpStruct(k).event(m).rxId + Ids.rx(k);
        end
        if ( TmpStruct(k).event(m).dmaControlId ~= 0 )
            TmpStruct(k).event(m).dmaControlId = ...
                TmpStruct(k).event(m).dmaControlId + Ids.dmaControl(k);
        end
    end
    Struct.event = [Struct.event; TmpStruct(k).event];
    
end

% ============================================================================ %
% ============================================================================ %

%% Order the interleaved events

% Check the NBEVENTS validity for each ACMOs
for k = 1 : length(TmpStruct)
    if ( round(length(TmpStruct(k).event) / NbEvents(k)) ...
            ~= length(TmpStruct(k).event) / NbEvents(k) )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The ACMO ' ACMO{k}.Name ' contains ' ...
            num2str(length(TmpStruct(k).event)) ' events, and they cannot ' ...
            'be grouped by ' num2str(NbEvents(k)) ' events.'];
        error(ErrMsg);
        
    end
end

% ============================================================================ %

% Check if the interleaving is complete
NbGroups = length(TmpStruct(1).event) / NbEvents(1);
for k = 2 : length(TmpStruct)
    
    if ( NbGroups ~= length(TmpStruct(k).event) / NbEvents(k) )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The ACMO ' ACMO{k}.Name ' is divided into ' ...
            num2str(length(TmpStruct(k).event) / NbEvents(k)) ' groups ' ...
            'while the ACMO ' ACMO{1}.Name ' is divided into ' ...
            num2str(NbGroups) ' groups. It should be the same number of ' ...
            'groups.'];
        error(ErrMsg);
        
    end
    
end

% ============================================================================ %

% Determine the index ordering
EventIds = zeros(2, length(Struct.event));
EventId0 = cumsum(NbEvents); EventId0 = [0 EventId0(1:end-1)];
for k = 1 : length(NbEvents)
    for m = 1 : NbEvents(k)
        
        % Determine indexes
        IdMode  = ((1:NbGroups) - 1) * sum(NbEvents) + m + EventId0(k);
        IdEvent = ((1:NbGroups) - 1) * NbEvents(k) + m;
        
        % Populate the EventIds
        EventIds(1, IdMode) = k;
        EventIds(2, IdMode) = IdEvent;
    end
end

% ============================================================================ %

% Order events
for k = 1 : size(EventIds, 2)
    Struct.event(k) = TmpStruct(EventIds(1, k)).event(EventIds(2, k));
end

% ============================================================================ %

% Evaluate the timing interleaving
if ( TimeIntegration )
    
    % Estimate group durations and pause available
    Duration = zeros(length(NbEvents), NbGroups);
    Pause    = zeros(length(NbEvents), NbGroups);
    for k = 1 : length(NbEvents)
        Idx = find(EventIds(1, :) == k);
        Idx = reshape(Idx, NbEvents(k), []);
        for m = 1 : NbGroups
            Pause(k, m) = Struct.event(Idx(end, m)).noop;
            for n = 1 : NbEvents(k)
                Duration(k, m) = Duration(k, m) ...
                    + Struct.event(Idx(n, m)).duration ...
                    + Struct.event(Idx(n, m)).noop;
            end
        end
    end
    
    % Control if timing can be preserved
    Duration = cumsum(Duration(end:-1:2, :), 1);
    NewPause = Pause(1:end-1, 1:end) - Duration(end:-1:1, :);
    if ( ~isempty(find(NewPause(:) < system.hardware.MinNoop, 1, 'first')) )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The timing between events cannot be preserved while ' ...
            'interleaving ACMOs.'];
        error(ErrMsg);
        
    end
    
    % Change pause between ACMOs
    Idx = find(diff(EventIds(1, :)) > 0);
    for k = 1 : (length(NbEvents) - 1)
        NewIdx = find(EventIds(1, Idx) == k);
        for m = 1 : length(NewIdx)
            Struct.event(Idx(NewIdx(m))).noop = int32(NewPause(m));
        end
    end
    
end

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

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