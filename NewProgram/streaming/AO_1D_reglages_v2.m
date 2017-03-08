%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : Clement 10/06/2015

%% LegHal for Aixplorer

addpath('D:\legHAL')
addPathLegHAL;

%% Gage folders

addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
addpath('AcqGage\');

%% Parameters

Nloop = 100;
% US Parameters
Volt        = 50; % V
FreqSonde   = 6;  % MHz
NbHemicycle = 10;
X0          = 15; % mm
Foc         = 35; % mm
NTrig       = 1000;
Prof        = 70; % mm

%Acquisition parameters
Range = 1; % V
SampleRate = 10; % MHz

% Save
Sauvegarde =0;
Date = datestr(now,'yyyy-mm-dd');
path = 'D:\Data\Clement\In Vivo\Bras JB';
Name = 'Poignet JB';

%% Security check
if FreqSonde ==15 && Volt>25
    Volt=25;
    warning('Tension max dépassée ! Limite 25 V');
end


%% Set Aixplorer parameters
AixplorerIP    = '192.168.0.20'; % IP address of the Aixplorer device

NoOp       = 500;             % µs minimum time between two US pulses

%% Paramètres de la séquence US
% tension etc...
ImgVoltage = Volt;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]
PushVoltage = 25;             % imaging voltage [V]
PushCurrent = 5;            % security limit for imaging current [A]

% ============================================================================ %

% Image info
ImgInfo.LinePitch = 1;  % dx / PiezoPitch
ImgInfo.PitchPix  = 0.5;  % dz / lambda
ImgInfo.Depth(1)  = 2;   % initial depth [mm]
ImgInfo.Depth(2)  = 20;  % final depth [mm]
ImgInfo.RxApod(1) = 0.4; % RxApodOne
ImgInfo.RxApod(2) = 0.6; % RxApodZero

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
    'Pause', NoOp, ...       % Debut de la pause entre chaque tir (µs)
    'PauseEnd', CP.NbHcycle/(2*CP.TwFreq*0.002),... %200, ...       % Fin de la pause (µs)
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
    'TrigAll', 0, ...
    'Repeat', NTrig+1, ...
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


%% Initialize Gage Acquisition card
[ret,handle] = InitGage_1D_reglages(NTrig,Prof,SampleRate,Range);

[ret, acqInfo] = CsMl_QueryAcquisition(handle);
CsMl_ErrorHandler(ret, 1, handle);
[ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
CsMl_ErrorHandler(ret, 1, handle);

CsMl_ResetTimeStamp(handle);


% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = 0;
transfer.Length         = acqInfo.SegmentSize;

MaskedMode              = bitand(acqInfo.Mode, 15); % Check acq. mode
ChannelsPerBoard        = sysinfo.ChannelCount / sysinfo.BoardCount; % get number of channels
ChannelSkip             = ChannelsPerBoard / MaskedMode; % number of channels that are skipped during

%% Acquisition AO
SEQ = SEQ.initializeRemote('IPaddress', AixplorerIP);
SEQ = SEQ.loadSequence();

%% Acquire data
for k = 1:Nloop
    ret = CsMl_Capture(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
    SEQ = SEQ.startSequence();
    
    status = CsMl_QueryStatus(handle);
    while status ~= 0
        status = CsMl_QueryStatus(handle);
    end
    
    SEQ = SEQ.stopSequence('Wait', 0);
    
    % Transfer data to Matlab
    raw = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    data = zeros(acqInfo.Depth,1);
    Z = linspace(0,Prof,acqInfo.Depth);
    
    transfer.Channel = 1;
    for ii = 1:acqInfo.SegmentCount
        transfer.Segment = ii; % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(handle, transfer); % transfer
        % actual contains the actual length of the acquisition that may be
        % different from the requested one.
        CsMl_ErrorHandler(ret, 1, handle);
        
        data = data +(1/NTrig)*datatmp';
        raw(:,ii) = datatmp';
        
    end
    
    figure (42)
    plot(Z,data)
    xlabel ('Depth (mm)')
    ylabel ('Signal (V)')
    drawnow
%     data_end(:,k)=data;
    fullDate = datestr(now,'yyyy-mm-dd_MM_ss');

     if(Sauvegarde == 1)
        mkdir([path '\' Date]);
        save([path '\' Date '\' Name '-' fullDate '.mat'],'Z','data','raw', 'Volt','FreqSonde',...
                    'NbHemicycle', 'X0', 'Foc', 'NTrig', 'Prof', 'Range', 'SampleRate');
    end
end


SEQ = SEQ.quitRemote();