% ACMO.ACMO.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ACMO.ACMO instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ACMO.ACMO instance OBJ
%   and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass ACMO.ACMO. It
%   cannot be used without all methods of the remoteclass ACMO.ACMO and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

function varargout = buildRemote(obj, varargin)

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check syntax
if nargout ~= 1 && nargout ~= 2

    % Build the prompt of the help dialog box
    ErrMsg = ['The syntaxes of the ' upper(class(obj)) ' buildRemote ' ...
        'method are:\n' ...
        '1. STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT ' ...
        'containing all mandatory remote fields for the ACMO.ACMO ' ...
        'instance,\n' ...
        '2. [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ACMO.ACMO ' ...
        'instance OBJ and the remote structure STRUCT.'];
    error(ErrMsg);

end

% ============================================================================ %
% ============================================================================ %

%% Export ELUSEV.ELUSEV objects (tx/tw/rx/fc/event)

% Initialize REMOTE structure
Struct.tx         = [];
Struct.tw         = [];
Struct.rx         = [];
Struct.fc         = [];
EventDurMax       = 0;

% Export ELUSEV.ELUSEV objects
ParName      = 'elusev';
Idx = find( strcmp( obj.Pars(:,1), ParName ) );

TmpElusev     = obj.Pars{Idx, 3};
if ~isempty(TmpElusev)

    for k = 1 : length(TmpElusev)
        [TmpElusev{k} Tmp] = TmpElusev{k}.buildRemote(varargin{1:end});
        Repeat  = TmpElusev{k}.getParam('Repeat');
        ModeTmp = [];

        % Updating indexes
        if isfield(Struct, 'tx')
            Id0.tx = length(Struct.tx);
        else
            Id0.tx = 0;
        end
        if isfield(Struct, 'tw')
            Id0.tw = length(Struct.tw);
        else
            Id0.tw = 0;
        end
        if isfield(Struct, 'rx')
            Id0.rx = length(Struct.rx);
        else
            Id0.rx = 0;
        end
        if isfield(Struct, 'fc')
            Id0.fc = length(Struct.fc);
        else
            Id0.fc = 0;
        end

        % Update twId
        if isfield(Tmp, 'tw')
            if (Id0.tw ~= 0) && isfield(Tmp, 'tx')
                for m = 1 : length(Tmp.tx)
                    Tmp.tx(m).twId = Tmp.tx(m).twId + Id0.tw;
                end
            end
            
            Struct.tw = [Struct.tw; Tmp.tw];
        end

        % Update txId
        if isfield(Tmp, 'tx')
            if (Id0.tx ~= 0) && isfield(Tmp, 'event')
                for m = 1 : length(Tmp.event)
                    Tmp.event(m).txId = Tmp.event(m).txId + Id0.tx;
                end
            end

            Struct.tx = [Struct.tx; Tmp.tx];
        end

        % Update fcId
        if isfield(Tmp, 'fc')
            if (Id0.fc ~= 0) && isfield(Tmp, 'rx')
                for m = 1 : length(Tmp.rx)
                    Tmp.rx(m).fcId = Tmp.rx(m).fcId + Id0.fc;
                end
            end

            Struct.fc = [Struct.fc; Tmp.fc];
        end

        % Update rxId
        if isfield(Tmp, 'rx')
            if isfield(Tmp, 'event')
                for m = 1 : length(Tmp.event)
                    % Update index
                    if Id0.rx ~= 0
                        Tmp.event(m).rxId = Tmp.event(m).rxId + Id0.rx;
                    end

                    % Update EventDurMax and ModeRx for the elusev
                    if Tmp.event(m).rxId ~= 0
                        EventDurMax       = max(EventDurMax, Tmp.event(m).duration);
                        
                        ModeTmp(1, end+1) = Tmp.event(m).numSamples;
                        ModeTmp(2, end)   = Tmp.event(m).skipSamples;
                        ModeTmp(3, end)   = Tmp.event(m).rxId;
                        ModeTmp(4, end)   = Tmp.event(m).txId;
                    end
                end
            end

            Struct.rx = [Struct.rx; Tmp.rx];
        end

        % Update events
        if isfield(Tmp, 'event')
            EluStruct(k).event  = repmat(Tmp.event, [Repeat 1]);
            EluStruct(k).ModeRx = repmat(ModeTmp, [1 Repeat]);
            EluStruct(k).Desc   = obj.Pars{Idx, 3}{k}.Desc;
            EluStruct(k).Type   = obj.Pars{Idx, 3}{k}.Type;
        end
        
    end
    
    obj.Pars{Idx, 3} = TmpElusev;
    
end

% ============================================================================ %
% ============================================================================ %

%% Organize events

% Initialize variables
Ordering     = obj.getParam('Ordering');
Struct.event = [];
ModeRx       = [];

% Organize events regarding the ORDERING parameter
if (length(Ordering) == 1) && (Ordering == 0) % chronological order
    
    for k = 1 : length(EluStruct)
        Struct.event = [Struct.event; EluStruct(k).event];
        ModeRx       = [ModeRx EluStruct(k).ModeRx];
    end

    % Ordering values does not correspond to an ELUSEV
elseif ~isempty(find(Ordering > length(EluStruct), 1))
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ORDERING parameter contains at a least a value ' ...
        'greater than the number of ELUSEV objects (' ...
        num2str(length(EluStruct)) '):\n'];
    for k = 1 : length(EluStruct)
        ErrMsg = [ErrMsg ...
            '    #' num2str(k) ' - ' EluStruct(k).Desc ' (' ...
            upper(EluStruct(k).Type) ')\n'];
    end
    error(ErrMsg(1:end-2));
    
    % Ordering values does not call at least on value
elseif length(unique(Ordering)) ~= length(EluStruct)
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ORDERING parameter does not use:\n'];
    for k = 1 : length(EluStruct)
        if isempty(find(Ordering == k, 1))
            ErrMsg = [ErrMsg ...
                '    #' num2str(k) ' - ' EluStruct(k).Desc ' (' ...
                upper(EluStruct(k).Type) ')\n'];
        end
    end
    error(ErrMsg(1:end-2));
    
    % Build the customed ordering
else
    
    for k = 1 : length(Ordering)
        Struct.event = [Struct.event; EluStruct(Ordering(k)).event];
        ModeRx       = [ModeRx EluStruct(Ordering(k)).ModeRx];
    end
    
end

% ============================================================================ %

% Update the last noop for the FrameRate
if obj.isParam('FrameRate')
    % Estimate the acmo duration
    EventDur = 0;
    for k = 1 : length(Struct.event)
        EventDur = EventDur + Struct.event(k).duration + Struct.event(k).noop;
    end
    EventDur = single(EventDur);
    
    FrameRate = single(obj.getParam('FrameRate'));
    
    FrameRate_Auto = 0;
    if FrameRate == 0
        PauseFr = 0;
        FrameRate = 1e6;
        FrameRate_Auto = 1;
    else
        PauseFr = 1e6 / FrameRate - EventDur;
    end

    if PauseFr < system.hardware.MinNoop
        if Struct.event(end).noop >= system.hardware.MinNoop
            PauseFr = 0;
        else
            WarnMsg = ['FrameRate accuracy not guaranted.'];
            obj.WarningMessage( WarnMsg )
            PauseFr = system.hardware.MinNoop;
        end
        FrameRate = 1e6 / (PauseFr + EventDur);
        if FrameRate_Auto
            WarnMsg = ['Automatic FrameRate was set to '  num2str(FrameRate) ' Hz.'];
        else
            WarnMsg = ['FrameRate was changed from ' ...
                num2str(obj.getParam('FrameRate'))  ' Hz to ' num2str(FrameRate) ...
                ' Hz.'];
        end

        obj.WarningMessage( WarnMsg )
        obj = obj.setParam('FrameRate', FrameRate);
    end

    if (PauseFr - round(PauseFr)) > PauseFr / 100
        FrameRate = 1e6 / (round(PauseFr) + EventDur);
        WarnMsg = ['FrameRate was changed from ' ...
            num2str(obj.getParam('FrameRate'))  ' Hz to ' num2str(FrameRate) ...
            ' Hz.'];
        obj.WarningMessage( WarnMsg )
        obj = obj.setParam('FrameRate', FrameRate);
    end

    Struct.event(end).noop = Struct.event(end).noop + int32(PauseFr);
end

% ============================================================================ %

% Repeat event several times before data transfer
RepeatElusev = obj.getParam('RepeatElusev');
if ( RepeatElusev > 1 )
    Struct.event = repmat(Struct.event, [RepeatElusev 1]);
    ModeRx       = repmat(ModeRx, [1 RepeatElusev]);
end

% ============================================================================ %
% ============================================================================ %

%% Export ACMO.ACMO objects (tgc/mode)

% Update the TGC object
EventDurMax = single(EventDurMax);
if ( EventDurMax == 0 )
    obj = obj.setParam('Duration', max(1, obj.getParam('Duration')));
else
    obj = obj.setParam( ...
        'Duration', max(EventDurMax, obj.getParam('Duration')));
end
TGC = remote.tgc( ...
    'Duration', min(obj.getParam('Duration'), 512 * 0.8), ...
    'ControlPts', obj.getParam('ControlPts'), ...
    'fastTGC', obj.getParam('fastTGC'), ...
    obj.Debug);
[tgc tgcFields] = TGC.buildRemote(varargin{1:end});
Struct.tgc      = cell2struct(tgc, tgcFields, 2);
obj             = obj.setParam('TGC', TGC);

% Update the MODE object
if ( isempty(ModeRx) )
    ModeRx = zeros(4,1);
end
Mode = remote.mode( ...
    'NbHostBuffer', obj.getParam('NbHostBuffer'), ...
    'ModeRx', ModeRx, obj.Debug);
[mode modeFields] = Mode.buildRemote(varargin{1:end});
Struct.mode       = cell2struct(mode, modeFields, 2);
obj               = obj.setParam('Mode', Mode);

% Update the DMACONTROL object
if ( EventDurMax == 0 )
    Struct.dmaControl = [];
else
    [dmaControl dmaControlFields] = ...
        obj.getParam('DmaControl').buildRemote(varargin{1:end});
    Struct.dmaControl = cell2struct(dmaControl, dmaControlFields, 2);
    
    Struct.event(end).dmaControlId   = int32(1);
    Struct.event(end).pauseForEndDma = int32(1);
end

% ============================================================================ %
% ============================================================================ %

%% Check output arguments

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