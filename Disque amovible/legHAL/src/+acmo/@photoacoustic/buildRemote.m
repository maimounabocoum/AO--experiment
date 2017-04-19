% ACMO.PHOTOACOUSTIC.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ACMO.PHOTOACOUSTIC instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ACMO.PHOTOACOUSTIC
%   instance OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ACMO.PHOTOACOUSTIC. It cannot be used without all methods of the remoteclass
%   ACMO.PHOTOACOUSTIC and all methods of its superclass ACMO.ACMO developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/28

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
    ErrMsg = ['The syntaxes of the ' upper(class(obj)) ' buildRemote ' ...
        'method are:\n' ...
        '1. STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT ' ...
        'containing all mandatory remote fields for the ACMO.PHOTOACOUSTIC ' ...
        'instance,\n' ...
        '2. [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ' ...
        'ACMO.PHOTOACOUSTIC instance OBJ and the remote structure STRUCT.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve parameters and control their value

% Retrieve parameters
NbFrames     = obj.getParam('NbFrames');
PRF          = obj.getParam('PRF');
RxFreq       = obj.getParam('RxFreq');
RxCenter     = obj.getParam('RxCenter');
SyntAcq      = obj.getParam('SyntAcq');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
TrigIn       = obj.getParam('TrigIn');
TrigOut      = obj.getParam('TrigOut');
TrigOutDelay = obj.getParam('TrigOutDelay');

% ============================================================================ %

% A single sampling frequency is authorized
if ( length(RxFreq) ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'There should be only one sampling frequency...';
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
        num2str(obj.getParam('RxDuration')) ' us to ' num2str(RxDuration) ...
        ' us.'];
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

% ============================================================================ %

% Control the synthetic acquisition
if ( SyntAcq )
    if ( system.probe.NbElemts <= system.hardware.NbRxChan )
        SyntAcq = 0;
    end
end

% ============================================================================ %

% Reception duration of event
EventRxDur = ceil(RxDuration + RxDelay);

% Noop duration
NoopDur = max(1e6 / PRF - EventRxDur - TrigOutDelay, system.hardware.MinNoop);

% ============================================================================ %
% ============================================================================ %

%% Create ELUSEV instance to add the passive acquisition

Elusev = elusev.elusev( ...
    'photoacoustic', ...
    'generic photoacoustic elusev', ...
    'TrigIn', TrigIn, ...
    'TrigOut', TrigOut, ...
    'TrigOutDelay', TrigOutDelay, ...
    'TrigAll', 1, ...
    'Repeat', NbFrames, ...
    obj.Debug);

% ============================================================================ %

% Blanck waveform
BlankTw = remote.tw_arbitrary( ...
    'TxElemts', 1:system.probe.NbElemts, ...
    'DutyCycle', 0, ...
    obj.Debug);
Elusev = Elusev.setParam('tw', BlankTw);

% Blank transmit
BlankTx = remote.tx_arbitrary( ...
    'twId', 1, ...
    'Delays', zeros(1, system.probe.NbElemts), ...
    obj.Debug);
Elusev = Elusev.setParam('tx', BlankTx);

% ============================================================================ %

% Filter coefficients
FC = remote.fc( ...
    'Bandwidth', FIRBandwidth, ...
    obj.Debug);
Elusev = Elusev.setParam('fc', FC);

% Receive
if ( SyntAcq ) % receive on left element
    RxElemt = 1;
else % receive on chosen element
    RxElemt = min(max(1, round(RxCenter / system.probe.Pitch)), ...
        system.probe.NbElemts);
end
Receive = remote.rx( ...
    'fcId', 1, ...
    'RxFreq', RxFreq, ...
    'QFilter', RxBandwidth, ...
    'RxElemts', RxElemt, ...
    obj.Debug);
Elusev  = Elusev.setParam('rx', Receive);

% Build the second elusev if SyntAcq == 1
if ( SyntAcq )

    Elusev  = Elusev.setParam('fc', FC);
    Receive = Receive.setParam('fcId', 2, 'RxElemts', system.probe.NbElemts);
    Elusev  = Elusev.setParam('rx', Receive);

end

% ============================================================================ %

% Receiving event
Event = remote.event( ...
    'txId', 1, ...
    'rxId', 1, ...
    'noop', NoopDur, ...
    'numSamples', NumSamples, ...
    'skipSamples', SkipSamples, ...
    'duration', EventRxDur, ...
    obj.Debug);
Elusev = Elusev.setParam('event', Event);

% Build the second elusev if SyntAcq == 1
if ( SyntAcq )
    
    Event  = Event.setParam('rxId', 2);
    Elusev = Elusev.setParam('event', Event);
    
end

% ============================================================================ %

% Add the ELUSEV object to the ACMO.PHOTOACOUSTIC
obj = obj.setParam('elusev', Elusev);

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

% Build the associated structure
Struct = buildRemote@acmo.acmo(obj, varargin{1:end});

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