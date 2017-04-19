% ACMO.ULTRACOLOR.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ACMO.ULTRACOLOR instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ACMO.ULTRACOLOR
%   instance OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ACMO.ULTRACOLOR. It cannot be used without all methods of the remoteclass
%   ACMO.ULTRACOLOR and all methods of its superclass ACMO.ACMO developed by
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
TwFreq       = obj.getParam('TwFreq');
NbHcycle     = obj.getParam('NbHcycle');
ApodFct      = obj.getParam('ApodFct');
DutyCycle    = obj.getParam('DutyCycle');
TxCenter     = obj.getParam('TxCenter');
TxWidth      = obj.getParam('TxWidth');
FlatAngles   = obj.getParam('FlatAngles');
RxFreq       = obj.getParam('RxFreq');
RxCenter     = obj.getParam('RxCenter');
RxWidth      = obj.getParam('RxWidth');
NumSamples   = single(obj.getParam('NumSamples'));
SkipSamples  = single(obj.getParam('SkipSamples'));
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
EnsLength    = single(obj.getParam('EnsLength'));
AngleRepFreq = obj.getParam('AngleRepFreq');
PRF          = obj.getParam('PRF');
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

% Estimate RxDuration, the duration of the sampling
NewNumSamples = round(NumSamples / 128) * 128;
if ( abs(NewNumSamples - NumSamples) > NumSamples / 100 )
    WarnMsg = ['The number of acquired samples was changed from ' ...
        num2str(NumSamples) ' to ' num2str(NewNumSamples) '.'];
    obj.WarningMessage( WarnMsg )
end
obj        = obj.setParam('NumSamples', NewNumSamples);
RxDuration = NewNumSamples / (RxFreq / 2^(RxBandwidth-1));

% Estimate RxDelay, the duration of the skipped samples
RxDelay = SkipSamples / RxFreq;

% Sets the RX channels positions
ElemtXpos = ((1 : system.probe.NbElemts) - 0.5) * system.probe.Pitch;

% 1st RX channel
MinRx = max(RxCenter - RxWidth / 2, ElemtXpos(1));
MinRx = find(MinRx <= ElemtXpos, 1, 'first');

% Last RX channel
MaxRx = min(RxCenter + RxWidth / 2, ElemtXpos(end));
MaxRx = find(MaxRx >= ElemtXpos, 1, 'last');

% Reception duration of event (one flat angle)
EventRxDur = ceil(RxDuration + RxDelay);
if ( (MaxRx - MinRx + 1) > system.hardware.NbRxChan )
    EventRxDur = 2 * EventRxDur + system.hardware.MinNoop;
end

% ============================================================================ %
% ============================================================================ %

%% Build the flat elusev

% Estimate Pause duration
if ( AngleRepFreq == 0 ) % automatic greatest PRF
    Pause        = system.hardware.MinNoop;
    AngleRepFreq = 1e6 / (Pause + EventRxDur);
    obj = obj.setParam('AngleRepFreq', AngleRepFreq);
else % custom PRF
    Pause = round(1e6 / AngleRepFreq - EventRxDur);
end

if ( Pause < system.hardware.MinNoop )
    Pause = system.hardware.MinNoop;
    AngleRepFreq = 1e6 / (Pause + EventRxDur);
    WarnMsg = ['AngleRepFreq was changed from ' ...
        num2str(obj.getParam('AngleRepFreq')) ' Hz to ' ...
        num2str(AngleRepFreq) ' Hz.'];
    obj.WarningMessage( WarnMsg )
    obj = obj.setParam('AngleRepFreq', AngleRepFreq);
end

% ============================================================================ %

% Estimate PauseEnd duration
NAngles    = length(FlatAngles);
EventRxDur = EventRxDur * NAngles + Pause * (NAngles - 1);
PauseEnd   = round(1e6 / PRF - EventRxDur);

if ( PauseEnd < system.hardware.MinNoop )
    PauseEnd = system.hardware.MinNoop;
    PRF = 1e6 / (PauseEnd + EventRxDur);
    WarnMsg = ['PRF was changed from ' num2str(obj.getParam('PRF')) ...
        ' Hz to ' num2str(PRF) ' Hz.'];
    obj.WarningMessage( WarnMsg )
    obj = obj.setParam('PRF', PRF);
end

% ============================================================================ %

% Add the flat events
FLAT = elusev.flat( ...
    'TwFreq', TwFreq, ...
    'NbHcycle', NbHcycle, ...
    'Polarity', 1, ...
    'FlatAngles', FlatAngles, ...
    'Pause', Pause, ...
    'PauseEnd', PauseEnd, ...
    'DutyCycle', DutyCycle, ...
    'TxCenter', TxCenter, ...
    'TxWidth', TxWidth, ...
    'ApodFct', ApodFct, ...
    'RxFreq', RxFreq, ...
    'RxDuration', RxDuration, ...
    'RxDelay', RxDelay, ...
    'RxCenter', RxCenter, ...
    'RxWidth', RxWidth, ...
    'RxBandwidth', RxBandwidth, ...
    'FIRBandwidth', FIRBandwidth, ...
    'Repeat', EnsLength, ...
    'TrigIn', TrigIn, ...
    'TrigOut', TrigOut, ...
    'TrigOutDelay', TrigOutDelay, ...
    'TrigAll', TrigAll, ...
    'PulseInv', 0, ...
    0);
obj = obj.setParam('elusev', FLAT);

% ============================================================================ %

%% Export the associated remote structure

% Adapt FrameRate
if ( obj.getParam('FrameRate') == 0 )
    obj = obj.setParam('FrameRate', 1e6 / (EventRxDur + PauseEnd) / EnsLength);
end

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