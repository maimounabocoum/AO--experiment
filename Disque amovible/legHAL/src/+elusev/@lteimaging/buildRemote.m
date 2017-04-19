% ELUSEV.LTEIMAGING.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.LTEIMAGING instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.LTEIMAGING
%   instance OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ELUSEV.LTEIMAGING. It cannot be used without all methods of the remoteclass
%   ELUSEV.LTEIMAGING and all methods of its superclass ELUSEV.ELUSEV developed
%   by SuperSonic Imagine and without a system with a REMOTE server running.
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
TwFreq       = obj.getParam('TwFreq');
NbHcycle     = single(obj.getParam('NbHcycle'));
TxElemts     = single(obj.getParam('TxElemts'));
Delays       = obj.getParam('Delays');
Pause        = obj.getParam('Pause');
DutyCycle    = obj.getParam('DutyCycle');
ApodFct      = obj.getParam('ApodFct');
RxFreq       = obj.getParam('RxFreq');
RxElemts     = obj.getParam('RxElemts');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
FIRBandwidth = obj.getParam('FIRBandwidth');

% ============================================================================ %

% Control the TX delays
if ( length(Delays) == 1 )
    Delays = zeros(1, system.hardware.NbTxChan);
elseif ( length(Delays) ~= length(TxElemts) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The DELAYS dimension is defined for ' num2str(length(Delays)) ...
        ' elements while it should be defined for each emitting elements, ' ...
        'i.e. for ' num2str(length(TxElemts)) ' elements.'];
    error(ErrMsg);
    
elseif ( length(Delays) < system.hardware.NbTxChan )
    Tmp              = Delays;
    Delays           = zeros(1, system.hardware.NbTxChan);
    Delays(TxElemts) = Tmp;
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
        ' ms to ' num2str(RxDelay) ' ms.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('RxDelay', RxDelay);

% Reception duration of event
EventRxDur = ceil(RxDuration + RxDelay);

% ============================================================================ %
% ============================================================================ %

%% Build the reception

% FC object
FC  = remote.fc( ...
    'Bandwidth', FIRBandwidth, ...
    obj.Debug);
obj = obj.setParam('FC', FC);

% RX object
RX  = remote.rx( ...
    'fcId', Id0.fc, ...
    'RxFreq', RxFreq, ...
    'QFilter', 1, ...
    'RxElemts', RxElemts, ...
    'HifuRx', 1, ...
    obj.Debug);
obj = obj.setParam('RX', RX);

% ============================================================================ %

%% Build the emission

% TW object
TW  = remote.tw_pulse( ...
    'ApodFct', ApodFct, ...
    'TxElemts', TxElemts, ...
    'DutyCycle', DutyCycle, ...
    'TwFreq', TwFreq, ...
    obj.Debug);
if ( rem(NbHcycle, 2) )
    TW = TW.setParam( ...
        'NbHcycle', 1, ...
        'repeat', NbHcycle - 1);
else
    TW = TW.setParam( ...
        'NbHcycle', 2, ...
        'repeat', NbHcycle / 2 - 1);
end
obj = obj.setParam('TW', TW);

% TX object
TX  = remote.tx_arbitrary( ...
    'twId', Id0.tw, ...
    'Delays', Delays, ...
    obj.Debug);
obj = obj.setParam('TX', TX);

% Transmit duration of event
EventTxDur = ceil(TwFreq * NbHcycle / 2 + max(TX.getParam('Delays')));

% ============================================================================ %

%% Build the events

EVENT = remote.event( ...
            'txId', Id0.tx , ...
            'rxId', Id0.rx, ...
            'noop', Pause, ...
            'duration', max(EventTxDur, EventRxDur), ...
            'numSamples', NumSamples, ...
            'skipSamples', SkipSamples, ...
            obj.Debug);
obj = obj.setParam('event', EVENT);

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