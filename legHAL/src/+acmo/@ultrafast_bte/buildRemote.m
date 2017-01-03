
function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% Check syntax

if (nargout ~= 1) && (nargout ~= 2)
    
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
NbHcycle     = single(obj.getParam('NbHcycle'));
PRF          = obj.getParam('PRF');
FrameRate    = obj.getParam('FrameRate');
FrameRateUF  = obj.getParam('FrameRateUF');
DutyCycle    = obj.getParam('DutyCycle');
TxCenter     = obj.getParam('TxCenter');
TxWidth      = obj.getParam('TxWidth');
ApodFct      = obj.getParam('ApodFct');
RxFreq       = obj.getParam('RxFreq');
RxCenter     = obj.getParam('RxCenter');
RxWidth      = obj.getParam('RxWidth');
RxBandwidth  = single(obj.getParam('RxBandwidth'));
FIRBandwidth = obj.getParam('FIRBandwidth');
RxDuration   = obj.getParam('RxDuration');
RxDelay      = obj.getParam('RxDelay');
RepeatFlat   = obj.getParam('RepeatFlat');
TrigIn       = obj.getParam('TrigIn');
TrigOut      = obj.getParam('TrigOut');
TrigOutDelay = obj.getParam('TrigOutDelay');
TrigAll      = obj.getParam('TrigAll');
TxElemsPattern = obj.getParam('TxElemsPattern');
TxPolarity   = obj.getParam('TxPolarity');
BTE_steering = obj.getParam('BTE_steering');

% ============================================================================ %

% A single transmit frequency is authorized
if length(TwFreq) ~= 1
    % Build the prompt of the help dialog box
    ErrMsg = 'There should be only one transmission frequency...';
    error(ErrMsg);
end

% ============================================================================ %

% A single sampling frequency is authorized
if length(RxFreq) ~= 1
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

if abs(RxFreq - obj.getParam('RxFreq')) > 1e-3
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
if (Value / RxDuration) > 1e-2
    WarnMsg = ['RxDuration was changed from ' ...
        num2str(obj.getParam('RxDuration')) ' us to ' ...
        num2str(RxDuration) ' us.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('RxDuration', RxDuration);

% ============================================================================ %

% Control the RxDelay
SkipSamples = min( floor(RxFreq * RxDelay / 2^(RxBandwidth-1)), 4096 );
RxDelay     = SkipSamples / RxFreq * 2^(RxBandwidth-1);
if abs(RxDelay - obj.getParam('RxDelay')) > 1e-2
    WarnMsg = ['RxDelay was changed from ' num2str(obj.getParam('RxDelay')) ...
        ' us to ' num2str(RxDelay) ' us.'];
    obj.WarningMessage( WarnMsg )
end
obj = obj.setParam('RxDelay', RxDelay);

% Reception duration of event
EventRxDur = ceil(RxDuration + RxDelay);

% ============================================================================ %
% ============================================================================ %

%% Build the flat elusev

% Sets the RX channels positions
ElemtXpos = ((1 : system.probe.NbElemts) - 0.5) * system.probe.Pitch;

% 1st RX channel
MinRx = max(RxCenter - RxWidth / 2, ElemtXpos(1));
MinRx = find(MinRx <= ElemtXpos, 1, 'first');

% Last RX channel
MaxRx = min(RxCenter + RxWidth / 2, ElemtXpos(end));
MaxRx = find(MaxRx >= ElemtXpos, 1, 'last');

SyntAcq = (MaxRx - MinRx + 1) > system.hardware.NbRxChan ;

Nb_Tx_Per_Line = max( [ length(TxElemsPattern) length(TxPolarity) ] );

% Estimate Event duration
if SyntAcq
    EventDurAllFlats = size(BTE_steering,1) * Nb_Tx_Per_Line * (EventRxDur+system.hardware.MinNoop) * 2;
else
    EventDurAllFlats = size(BTE_steering,1) * Nb_Tx_Per_Line * (EventRxDur+system.hardware.MinNoop);
end

% automatic greatest PRF
if PRF == 0
    Pause = system.hardware.MinNoop;
    PRF = 1e6 / ( EventDurAllFlats / size(BTE_steering,1) + Pause ) ;

    WarnMsg = ['Automatic PRF was set to ' num2str(PRF) ...
        ' Hz.'];
    obj.WarningMessage( WarnMsg )
    
    obj = obj.setParam('PRF', PRF);
% custom PRF
else
    Pause = round( 1e6 / PRF - EventDurAllFlats / size(BTE_steering,1) );
end

% Warning dialog
if Pause < system.hardware.MinNoop
    Pause = system.hardware.MinNoop;
    PRF = 1e6 / ( EventDurAllFlats / size(BTE_steering,1) + Pause ) ;
    WarnMsg = ['PRF was changed from ' num2str(obj.getParam('PRF')) ...
        ' Hz to ' num2str(PRF) ' Hz.'];
    obj.WarningMessage( WarnMsg )
    obj = obj.setParam('PRF', PRF);

elseif Pause > system.hardware.MaxNoop
    Pause = system.hardware.MaxNoop - system.hardware.MinNoop;
    PRF = 1e6 / ( EventDurAllFlats / size(BTE_steering,1) + Pause ) ;
    WarnMsg = ['PRF was changed from ' num2str(obj.getParam('PRF')) ...
        ' Hz to ' num2str(PRF) ' Hz.'];
    obj.WarningMessage( WarnMsg )
    obj = obj.setParam('PRF', PRF);

end

if FrameRateUF == 0
    PauseFrUF = max( system.hardware.MinNoop, Pause - system.hardware.MinNoop );
    FrameRateUF = PRF / size(BTE_steering,1);
    obj = obj.setParam('FrameRateUF', FrameRateUF);
    WarnMsg = ['Automatic FrameRateUF was set to ' num2str(FrameRateUF) ...
        ' Hz.'];
    obj.WarningMessage( WarnMsg )

else
    if FrameRateUF > PRF / size(BTE_steering,1)
        FrameRateUF = PRF / size(BTE_steering,1);
        WarnMsg = ['FrameRateUF must be <= PRF / size(BTE_steering,1), so it was changed from ' num2str(obj.getParam('FrameRateUF')) ...
            ' Hz to ' num2str(FrameRateUF) ' Hz.'];
        obj.WarningMessage( WarnMsg )
%         obj = obj.setParam('FrameRateUF', FrameRateUF);
    end
    PauseFrUF = Pause + 1e6/FrameRateUF - size(BTE_steering,1)*1e6/PRF ; % pause after each group of flat angles
    if PauseFrUF < system.hardware.MinNoop
        PauseFrUF = system.hardware.MinNoop;
        
        FrameRateUF = 1e6 / ( ( 1e6/PRF ) + PauseFrUF );
        WarnMsg = ['FrameRateUF was changed from ' num2str(obj.getParam('FrameRateUF')) ...
            ' Hz to ' num2str(FrameRateUF) ' Hz.'];
        obj.WarningMessage( WarnMsg )
        obj = obj.setParam('FrameRateUF', FrameRateUF);

    elseif PauseFrUF > system.hardware.MaxNoop
        PauseFrUF = system.hardware.MaxNoop;

        FrameRateUF = 1e6 / ( ( 1e6/PRF ) + PauseFrUF );
        WarnMsg = ['FrameRateUF was changed from ' num2str(obj.getParam('FrameRateUF')) ...
            ' Hz to ' num2str(FrameRateUF) ' Hz.'];
        obj.WarningMessage( WarnMsg )
        obj = obj.setParam('FrameRateUF', FrameRateUF);

    end
end

% ============================================================================ %

% Add the flat events
FLAT = elusev.flat_bte( ...
    'TwFreq', TwFreq, ...
    'NbHcycle', NbHcycle, ...
    'BTE_steering', BTE_steering, ...
    'Pause', Pause, ...
    'PauseEnd', PauseFrUF, ...
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
    'Repeat', RepeatFlat, ...
    'TrigIn', TrigIn, ...
    'TrigOut', TrigOut, ...
    'TrigOutDelay', TrigOutDelay, ...
    'TrigAll', TrigAll, ...
    'TxPolarity',   TxPolarity, ...
    'TxElemsPattern', TxElemsPattern, ...
    0 );
obj = obj.setParam('elusev', FLAT);

% add pause if Framerate is too low
% might now work well when FrameRate is changed in acmo.acmo
if FrameRate > 0 && FrameRate < 1e6/system.hardware.MaxNoop
    T_FLAT = single(RepeatFlat)/FrameRateUF;
    PauseFr = 1/FrameRate - T_FLAT;
    PAUSE = elusev.pause( 'Pause',PauseFr );
    obj = obj.setParam('elusev', PAUSE);
end

% ============================================================================ %

%% Export the associated remote structure

% Build the associated structure
[ obj Struct ] = buildRemote@acmo.acmo(obj, varargin{1:end});

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
