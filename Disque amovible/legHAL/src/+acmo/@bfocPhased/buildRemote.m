% ACMO.BFOCPHASED.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ACMO.BFOCPHASED instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ACMO.BFOCPHASED
%   instance OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ACMO.BFOCPHASED. It cannot be used without all methods of the remoteclass
%   ACMO.BFOCPHASED and all methods of its superclass ACMO.ACMO developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/01

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

Focus        = obj.getParam('Focus');
SteerAngleStart   = obj.getParam('SteerAngleStart');
xApex      = obj.getParam('xApex');
zApex      = obj.getParam('zApex');
nbFocLines   = single(obj.getParam('nbFocLines'));
TxLinePitch  = single(obj.getParam('TxLinePitch'));
TwFreq       = obj.getParam('TwFreq');
NbHcycle     = single(obj.getParam('NbHcycle'));
PRF          = obj.getParam('PRF');
DutyCycle    = obj.getParam('DutyCycle');
ApodFct      = obj.getParam('ApodFct');
RxFreq       = obj.getParam('RxFreq');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
PulseInv     = single(obj.getParam('PulseInv'));
TrigIn       = obj.getParam('TrigIn');
TrigOut      = obj.getParam('TrigOut');
TrigOutDelay = obj.getParam('TrigOutDelay');
TrigAll      = obj.getParam('TrigAll');

% ============================================================================ %

% A single transmit frequency is authorized
if ( length(TwFreq) ~= 1 )
    % Build the prompt of the help dialog box
    ErrMsg = 'There should be only one transmission frequency...';
    error(ErrMsg);
end

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

% ============================================================================ %
% ============================================================================ %

%% Build the focused elusev

% Sets the RX channels positions

% Estimate Pause duration

if ( PRF == 0 ) % automatic greatest PRF
    PauseEnd = system.hardware.MinNoop;
    PRF = 1e6 / (1 + PulseInv) ...
        / ((EventRxDur + system.hardware.MinNoop) * nbFocLines);
    obj = obj.setParam('PRF', PRF);
else % custom PRF
    PauseEnd = round((1e6 / PRF - EventRxDur*nbFocLines*(1 + PulseInv))) ;
end

% Warning dialog
if ( PauseEnd < system.hardware.MinNoop )
    PauseEnd = system.hardware.MinNoop;
    PRF = 1e6 / (1 + PulseInv) ...
        / ((EventRxDur + system.hardware.MinNoop) * nbFocLines);
    WarnMsg = ['PRF was changed from ' num2str(obj.getParam('PRF')) ...
        ' Hz to ' num2str(PRF) ' Hz.'];
    obj.WarningMessage( WarnMsg )
    obj = obj.setParam('PRF', PRF);
end

% built the position of acoustic line
SteerAngle   = (SteerAngleStart+(0:(nbFocLines-1))*TxLinePitch)*pi/180 ;
TxCenter     = xApex + zApex*tan(SteerAngle) ;
TxWidth      = system.probe.Pitch*system.probe.NbElemts ;
RxCenter     = system.probe.Pitch*system.probe.NbElemts/2 ;

% ============================================================================ %

% Add the flat events

FOCUSED = elusev.focused( ...
    'TwFreq', TwFreq, ...
    'NbHcycle', NbHcycle, ...
    'Polarity', 1, ...
    'SteerAngle', SteerAngle, ...
    'Pause', system.hardware.MinNoop, ...
    'PauseEnd', PauseEnd, ...
    'DutyCycle', DutyCycle, ...
    'TxCenter', TxCenter, ...
    'TxWidth', TxWidth, ...
    'ApodFct', ApodFct, ...
    'RxFreq', RxFreq, ...
    'Focus', Focus, ...
    'RxDuration', RxDuration, ...
    'RxDelay', RxDelay, ...
    'RxCenter', RxCenter, ...
    'RxBandwidth', RxBandwidth, ...
    'FIRBandwidth', FIRBandwidth, ...
    'TrigIn', TrigIn, ...
    'TrigOut', TrigOut, ...
    'TrigOutDelay', TrigOutDelay, ...
    'TrigAll', TrigAll, ...
    'PulseInv', PulseInv, ...
    0);

obj = obj.setParam('elusev', FOCUSED);

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