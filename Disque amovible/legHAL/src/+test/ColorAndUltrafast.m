% TEST.COLORANDULTRAFAST (PUBLIC)
%   Build and run a sequence with ultrafast color Doppler and ultrafast
%   acquisitions
%
%   Note - This function is defined as a script of TEST package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/03

%% Clear everything

clear all;
close all;
clc;
clear classes;

% ============================================================================ %
% ============================================================================ %

%% Sequence parameters

% System parameters
IPaddress = '192.168.1.166'; % IP address of Aixplorer
ImgVoltage = 20;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]

% ============================================================================ %

% Image info
ImgInfo.LinePitch = .5;  % dx / PiezoPitch
ImgInfo.PitchPix  = .5;  % dz / lambda
ImgInfo.Depth(1)  = 1;   % initial depth [mm]
ImgInfo.Depth(2)  = 30;  % final depth [mm]
ImgInfo.RxApod(1) = 0.5; % RxApodOne
ImgInfo.RxApod(2) = 0.7; % RxApodZero

% ============================================================================ %

% General acquisition parameters
TwFreq       = 7.5;        % MHz
ApodFct      = 'hanning';     %
RxFreq       = 4 * TwFreq; % MHz
RxBandwidth  = 2;          % 1 = 200%, 2 = 100%

% ============================================================================ %

% Ultrafast dedicated parameters
UFAngleMax  = 10; % [�]
UFNbHCycle  = 2;
UFDutyCycle = 1;
UFTxCenter  = 30; % mm
UFTxWidth   = 60; % mm
UFRxCenter  = 30; % reception center [mm]
UFRxWidth   = 60; % reception width [mm]
UFNbColorFr = 4;  % # acquired color frames per ultrafast frame

% ============================================================================ %

% Ultrafast Color dedicated parameters
UCFlatAngles   = -10:10:10; % [deg]
UCNbHcycle     = 6;
UCDutyCycle    = 1;
UCTxCenter     = 30;        % mm
UCTxWidth      = 60;        % mm
UCRxCenter     = 30;        % reception center [mm]
UCEnsLength    = 10;        % # of repeated block
UCAngleRepFreq = 0;         % Hz
UCPRF          = 3200;      % Hz
UCFrameRate    = 0;         % Hz

% ============================================================================ %

% Sequence execution
NbLocalBuffer = 2; % # of local buffer
NbHostBuffer  = 2; % # of host buffer
NbRun         = 1; % # of sequence executions
RepeatElusev  = 1; % # of acmo repetition before dma

% ============================================================================ %

% DO NOT CHANGE
% Estimate dedicated variables for UltraColor
NumSamples   = ceil(1.4 * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
     * RxFreq / (common.constants.SoundSpeed * 2^(RxBandwidth-1) * 128)) * 128;
SkipSamples  = floor(0.6 * ImgInfo.Depth(1) * RxFreq * 1e3 ...
    / common.constants.SoundSpeed);

% DO NOT CHANGE
% Estimate dedicated variables for Ultrafast
RxDuration = NumSamples / RxFreq * 2^(RxBandwidth-1);
RxDelay    = SkipSamples / RxFreq;

% DO NOT CHANGE
% Determine the type of ultrafast acquisition (Synthetic or not)
NbElemts  = system.probe.NbElemts;
ElemtXpos = ((1 : NbElemts) - 0.5) * system.probe.Pitch; % element positions
MinRx     = double(max(floor(UFRxCenter - UFRxWidth / 2), ElemtXpos(1)));
MinRx     = find(MinRx <= ElemtXpos, 1, 'first');
MaxRx     = double(min(ceil(UFRxCenter + UFRxWidth / 2), ElemtXpos(end)));
MaxRx     = find(MaxRx >= ElemtXpos, 1, 'last');
if ( isempty(MinRx) )
    ErrMsg = ['No first element belonging to the probe could be identified ' ...
        'for reception.'];
    error(ErrMsg);
elseif ( isempty(MaxRx) )
    ErrMsg = ['No last element belonging to the probe could be identified ' ...
        'for reception.'];
    error(ErrMsg);
else
    SyntAcq = ((MaxRx - MinRx + 1) > system.hardware.NbRxChan);
end

% DO NOT CHANGE
% Estimate the ultrafast flat angles
NbAngles     = UCEnsLength * UFNbColorFr / (1 + SyntAcq);
UFFlatAngles = -UFAngleMax : (2 * UFAngleMax) / (NbAngles - 1) : UFAngleMax;

% ============================================================================ %
% ============================================================================ %

%% Build the sequence

% try
clc

% ============================================================================ %

% UltraColor ACMO
ACMO{1} = acmo.ultracolor( ...
    'TwFreq', TwFreq, ...
    'NbHcycle', UCNbHcycle, ...
    'ApodFct', ApodFct, ...
    'DutyCycle', UCDutyCycle, ...
    'TxCenter', UCTxCenter, ...
    'TxWidth', UCTxWidth, ...
    'FlatAngles', UCFlatAngles, ...
    'RxFreq', RxFreq, ...
    'RxCenter', UCRxCenter, ...
    'RxWidth', 1, ...
    'NumSamples', NumSamples, ...
    'SkipSamples', SkipSamples, ...
    'RxBandwidth', RxBandwidth, ...
    'FIRBandwidth', 100, ...
    'EnsLength', UCEnsLength * UFNbColorFr, ...
    'AngleRepFreq', UCAngleRepFreq, ...
    'PRF', UCPRF, ...
    'FrameRate', UCFrameRate, ...
    'TrigIn', 0, ...
    'TrigOut', 0, ...
    'TrigOutDelay', 0, ...
    'TrigAll', 0, ...
    'ControlPts', 900, ...
    'RepeatElusev', RepeatElusev);

% ============================================================================ %

% Create ULTRAFAST acquisition
ACMO{2} = acmo.ultrafast( ...
    'TwFreq', TwFreq, ...
    'NbHcycle', UFNbHCycle, ...
    'FlatAngles', UFFlatAngles, ...
    'PRF', 0, ...
    'DutyCycle', UFDutyCycle, ...
    'TxCenter', UFTxCenter, ...
    'TxWidth', UFTxWidth, ...
    'ApodFct', ApodFct, ...
    'RxFreq', RxFreq, ...
    'RxDuration', RxDuration, ...
    'RxDelay', RxDelay, ...
    'RxCenter', UFRxCenter, ...
    'RxWidth', UFRxWidth, ...
    'RxBandwidth', RxBandwidth, ...
    'FIRBandwidth', 100, ...
    'RepeatFlat', 1, ...
    'ControlPts', 900, ...
    'TrigIn', 0, ...
    'TrigOut', 0, ...
    'TrigOutDelay', 0, ...
    'TrigAll', 0, ...
    'PulseInv', 0);

% ============================================================================ %

% Create the interleaved acmos
INTERLEAVED = acmo.interleaved( ...
    'ACMO', ACMO, ...
    'NbEvents', [length(UCFlatAngles) 1], ...
    'TimeIntegration', 1, ...
    'Repeat', NbLocalBuffer, ...
    'NbHostBuffer', NbHostBuffer);

% ============================================================================ %

% Create sequence
TPC = remote.tpc( ...
    'imgvoltage', ImgVoltage, ...
    'imgcurrent', ImgCurrent, ...
    0);
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'ACMO', INTERLEAVED, ...
    'Repeat', NbRun, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

% ============================================================================ %

% Build the REMOTE structure
% profile on;
[SEQ NbAcq] = SEQ.buildRemote();
% profile off; profile viewer;
disp('done...');

% Il faut mexer le setApodisation

% ============================================================================ %

% catch exception
%     errordlg(exception.message, exception.identifier);
% end

% ============================================================================ %

% Optimization
%  - Utilisation uniquement de PARS et plus de PARS & OBJS.
%  - Automatiquement écrire en minuscule les paramètres.
%  - déporter le isParam et localisation du paramètre -> amélioration de la
%    vitesse d'exécution.
%  remoteobj / 73 / 1.41 for 1141 call
