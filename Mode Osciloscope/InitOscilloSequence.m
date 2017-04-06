function [ SEQ ] = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%% Security check
if FreqSonde ==15 && Volt>25
    Volt=25;
    warning('Tension max dépassée ! Limite 25 V');
end

NoOp       = 400;             % µs minimum time between two ELUSEV (useless here than)

%% Paramètres de la séquence US
% tension etc...
ImgVoltage = Volt;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]
PushVoltage = 25;             % imaging voltage [V]
PushCurrent = 5;            % security limit for imaging current [A]

% ============================================================================ %

% Image info
ImgInfo.Depth(1)  = 2;   % initial depth [mm]
ImgInfo.Depth(2)  = 20;  % final depth [mm]

% ============================================================================ %

% Emission
CP.TwFreq     = FreqSonde;       % MHz 15
CP.NbHcycle   = NbHemicycle ;         %
CP.ApodFct    = 'none';    %
CP.DutyCycle  = 1;         %
CP.TxCenter   = 0;        % mm
CP.TxWidth    = Foc/2;        % mm


CP.PosZ = Foc; % mm
CP.PosX = X0; % mm
% ============================================================================ %

% Acquisition
CP.RxFreq       = 60; %4 * CP.TwFreq; % MHz
CP.RxCenter     = 0;          % mm
CP.RxWidth      = 32;          % mm - no synthetic acquisition
CP.RxBandwidth  = 2;          % 1 = 200%, 2 = 100%

% ============================================================================ %

% Sequence execution
NbLocalBuffer = 1; % # of local buffer
NbHostBuffer  = 1; % # of host buffer
NbRun         = 1; % # of sequence executions
RepeatElusev  = 1; % # of acmo repetition before dma

% ============================================================================ %

% DO NOT CHANGE - Estimate dedicated variables for UltraColor
NumSamples   = ceil(1.4 * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * CP.RxFreq / (common.constants.SoundSpeed * 2^(CP.RxBandwidth-1) * 128)) * 128;
SkipSamples  = floor(0.6 * ImgInfo.Depth(1) * CP.RxFreq * 1e3 ...
    / common.constants.SoundSpeed);

% DO NOT CHANGE - Estimate dedicated variables for Ultrafast
CP.RxDuration = NumSamples / CP.RxFreq * 2^(CP.RxBandwidth-1);
CP.RxDelay    = SkipSamples / CP.RxFreq;
% ======================================================================= %
%% Build the sequence
% =========================================================================

FOCUSED = elusev.focused( ...
    'TwFreq', CP.TwFreq, ...
    'NbHcycle', CP.NbHcycle, ...
    'Polarity', 1, ...
    'SteerAngle', 0, ...
    'Focus', CP.PosZ, ...    %en mm
    'Pause', NoOp, ...       % Debut de la pause entre chaque tir (µs) => seems completly usesless !!
    'PauseEnd',500, ... %CP.NbHcycle/(2*CP.TwFreq*0.002),... %200, ...       % Fin de la pause (µs)
    'DutyCycle', 1, ...
    'TxCenter', CP.PosX, ...
    'TxWidth', CP.TxWidth, ...
    'RxFreq', CP.RxFreq, ...
    'RxCenter', CP.RxCenter, ...
    'RxDuration', 8.5333, ...
    'RxDelay', 0, ...
    'RxBandwidth', 2, ...
    'FIRBandwidth', 0, ...
    'PulseInv', 0, ...
    'TrigOut', 50, ...%slogP.AcqTime , ...    %en µs
    'TrigAll', 1, ...
    'TrigIn', 0, ...
    'Repeat', NTrig, ...
    'ApodFct', 'none', ...
    0);

% Acousto ACMO
ACOUSTO = acmo.acmo( ...
    'Repeat', 1, ...
    'Duration', 0, ...
    'ControlPts', 900, ...
    'fastTGC', 0, ...
    'NbLocalBuffer', 0, ...
    'NbHostBuffer', 1, ...
    'RepeatElusev', 1, ...
    0);

ACOUSTO = ACOUSTO.setParam('elusev',FOCUSED,'Ordering',[1]);

clear 'FOCUSED'

% ============================================================================ %

% Create sequence
TPC = remote.tpc( ...
    'imgVoltage', ImgVoltage, ...
    'imgCurrent', ImgCurrent, ...
    'pushVoltage', PushVoltage, ...
    'pushCurrent', PushCurrent, ...
    0);
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACOUSTO, ...
    'Repeat', NbRun, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

clear 'ACOUSTO'
clear 'TPC'
% ============================================================================ %
% Build the REMOTE structure
[SEQ NbAcq] = SEQ.buildRemote();
%% Acquisition AO
SEQ = SEQ.initializeRemote('IPaddress', AixplorerIP);
%SEQ.Server


end

