% SCRIPTS.PATWUF (PUBLIC)
%   Build and run a sequence with PAT and ultrafast acquisitions
%
%   Note - This function is defined as a script of SCRIPTS package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/16

%% Parameters definition

% System parameters
NThreads = 1 ;
AixplorerIP    = '192.168.1.37'; % IP address of the Aixplorer device
ImagingVoltage = 50;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Image parameters
clear ImgInfo
ImgInfo.Depth(1)           = 2.5; % initial depth [mm]
ImgInfo.Depth(2)           = 60;  % image depth [mm]
ImgInfo.CorrectFactorDepth = 0.4; % depth correction to estimate the acquisition duration
ImgInfo.NbColumnsPerPiezo  = 1;
ImgInfo.NbRawsPerLambda    = 1;

% ============================================================================ %

% PAT acquisition parameters
clear PAT
PAT.NbFrames      = 2;               % # of PAT images
PAT.RxFreq        = 20;              % sampling frequency [MHz]
PAT.RxCenter      = 25.6;            % receiving center [mm]
PAT.FIRBandwidth  = 90;              % FIR receiving bandwidth [%] - center frequency = PAT.RxFreq / 4
PAT.TGC           = 900 * ones(1,8); % TGC profile
PAT.SyntAcq       = 0;               % synthetic reception
PAT.TrigIn        = 0;               % enable trigger in
PAT.TrigOut       = 0;               % duration of trigger out [us] - 0 corresponds to no trigger out
PAT.TrigOutDelay  = 0;               % delay between the trigger out and the acquisition [us]
PAT.PRF           = 100;             % Pulse Repetition Frequency [Hz]
                                     % make sure PAT.PRF > laser firing repetition frequency
PAT.PeakDelay     = -1.3;            % Delay added on RF to beamform image [us] (to take into account delay between laser firing and ultrasound acquisition)

% ============================================================================ %

% Ultrafast acquisition parameters
clear UF
UF.TxFreq       = 7.5;             % emission frequency [MHz]
UF.NbHcycle     = 2;               % # of half cycles
UF.FlatAngles   = -20:1:20;        % flat angles [deg]
UF.DutyCycle    = 1;               % duty cycle [0, 1]
UF.TXCenter     = 25.6;            % emission center [mm]
UF.TXWidth      = 51.2;            % emission width [mm]
UF.ApodFct      = 'none';          % emission apodization function (none, hanning)
UF.RxCenter     = 25.6;            % reception center [mm]
UF.RxWidth      = 51.2;            % reception width [mm]
UF.FIRBandwidth = 90;              % FIR receiving bandwidth [%] - center frequency = UFTxFreq
UF.TGC          = 900 * ones(1,8); % TGC profile

% ============================================================================ %

% PAT image formation
PAT.BeamformingKneeAngle = 0.20;
PAT.BeamformingMaxAngle  = 0.30;
PAT.DynRangedB           = 25;
PAT.Threshold            = 82;

% ============================================================================ %

% Ultrafast image formation
UF.BeamformingKneeAngle = 0.20;
UF.BeamformingMaxAngle  = 0.30;
UF.DynRangedB           = 55;
UF.Threshold            = 100;

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Additional parameters

ImgInfo.Depth(1) = max( ImgInfo.Depth(1), .5 - PAT.PeakDelay*common.constants.SoundSpeed*1e-3 );

% Additional parameter for PAT acquisition
PAT.RxDelay     = 0; % acquisition delay [us] - it starts immediatly
PAT.RxBandwidth = 1; % sampling mode (200%)

% Estimate RxDuration for PAT acquisition
PAT.RxDuration = ceil((1 + ImgInfo.CorrectFactorDepth) * ImgInfo.Depth(2) ...
    * 1e3 * (PAT.RxFreq / 2^(PAT.RxBandwidth - 1)) ...
    / (common.constants.SoundSpeed * 128)) * 128 ...
    / (PAT.RxFreq / 2^(PAT.RxBandwidth - 1));

% ============================================================================ %

% Additional parameters for ultrafast acquisition
UF.RxFreq      = 4 * UF.TxFreq; % sampling frequency [MHz]
UF.RxBandwidth = 1;             % sampling mode (200%)
UF.PRF         = 0;             % 0 = greatest possible PRF

% Estimate RxDelay for ultrafast acquisition
UF.RxDelay = floor((1 - ImgInfo.CorrectFactorDepth) * ImgInfo.Depth(1) * 1e3 ...
    * UF.RxFreq / common.constants.SoundSpeed) / UF.RxFreq;

% Estimate RxDuration for ultrafast acquisition
UF.RxDuration = ceil((1 + ImgInfo.CorrectFactorDepth) ...
    * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * (UF.RxFreq / 2^(UF.RxBandwidth - 1)) ...
    / (common.constants.SoundSpeed * 128)) * 128 ...
    / (UF.RxFreq / 2^(UF.RxBandwidth - 1));

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Create acquisition modes

try
    % Do not modify, this is used to ensure TrigIn Timeout functionnality
    E_Pause = elusev.pause( 'Pause', 5e-6 );
    E_Pause = E_Pause.setParam( 'SoftIrq', 1 );
    
    % Add the PAT acquisition mode
    clear AcmoList
    PATModeId = 1;
    AcmoList{PATModeId} = acmo.photoacoustic( ...
        'NbFrames',     PAT.NbFrames, ...
        'PRF',          PAT.PRF, ...
        'RxFreq',       PAT.RxFreq, ...
        'RxCenter',     PAT.RxCenter, ...
        'SyntAcq',      PAT.SyntAcq, ...
        'RxDuration',   PAT.RxDuration, ...
        'RxDelay',      PAT.RxDelay, ...
        'RxBandwidth',  PAT.RxBandwidth, ...
        'FIRBandwidth', PAT.FIRBandwidth, ...
        'TrigIn',       PAT.TrigIn, ...
        'TrigOut',      PAT.TrigOut, ...
        'TrigOutDelay', PAT.TrigOutDelay, ...
        'ControlPts',   PAT.TGC, ...
        'elusev',       E_Pause);

    % Add the ultrafast acquisition mode
    UFModeId = 2;
    AcmoList{UFModeId} = acmo.ultrafast( ...
        'TwFreq',       UF.TxFreq, ...
        'NbHcycle',     UF.NbHcycle, ...
        'FlatAngles',   UF.FlatAngles, ...
        'PRF',          UF.PRF, ...
        'DutyCycle',    UF.DutyCycle, ...
        'TxCenter',     UF.TXCenter, ...
        'TxWidth',      UF.TXWidth, ...
        'ApodFct',      UF.ApodFct, ...
        'RxFreq',       UF.RxFreq, ...
        'RxDuration',   UF.RxDuration, ...
        'RxDelay',      UF.RxDelay, ...
        'RxCenter',     UF.RxCenter, ...
        'RxWidth',      UF.RxWidth, ...
        'RxBandwidth',  UF.RxBandwidth, ...
        'FIRBandwidth', UF.FIRBandwidth, ...
        'ControlPts',   UF.TGC);
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end


% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Create and build the ultrasound sequence

try
    
    % Create the TPC object
    TPC = remote.tpc( ...
        'imgVoltage', ImagingVoltage, ...
        'imgCurrent', ImagingCurrent);
    
    % Create  and build the sequence
    Sequence           = usse.usse('TPC', TPC, 'acmo', AcmoList, 'Popup',0 );
%     Sequence           = Sequence.selectProbe(); % comment if the probe did not change
    [Sequence NbAcqRx] = Sequence.buildRemote();
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end

% ============================================================================ %
% ============================================================================ %

%% Do NOT CHANGE - Sequence execution

try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP, 'InitTGC',PAT.TGC, 'InitRxFreq',PAT.RxFreq );

    % Load sequence
    Sequence = Sequence.loadSequence();
    
    % Execute sequence
    clear buffer;
    idx_clock_sequence = tic;
    Sequence = Sequence.startSequence('Wait', 0);
    
    % Retrieve data
    idx_clock_datatransfer = tic;
    for k = 1 : NbAcqRx
        buffer(k) = Sequence.getData('Realign',0, 'timeout',10, 'data_timeout','data timeout happened');
    end
    datatransfertime = toc(idx_clock_datatransfer);
    disp(['Data transfer duration: ' num2str(datatransfertime) 's.']);
    
    % Stop sequence
    Sequence = Sequence.stopSequence('Wait', 1);
    
    % Data Size to transfer 2 Bytes per sample
    UploadedDataSizeMB = (numel(buffer.data) * 2) / (1024 * 1024);
    disp(['Uploaded data size: ' num2str(UploadedDataSizeMB) 'MB.']);
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% ============================================================================ %

% PAT image formation

% Display parameters
XOrigin = 0.0;
ZOrigin = ImgInfo.Depth(1);

% ============================================================================ %

% DO NOT CHANGE - Compute additional parameters
DeltaX = system.probe.Pitch / ImgInfo.NbColumnsPerPiezo;
DeltaZ = common.constants.SoundSpeed / 1000 /(PAT.RxFreq / 4.0) ...
    / ImgInfo.NbRawsPerLambda;

% DO NOT CHANGE - Image info
clear PATBfInfo
PATBfInfo.LinePitch = DeltaX / system.probe.Pitch;                          % dx / PiezoPitch
PATBfInfo.PitchPix  = DeltaZ * 1000 / common.constants.SoundSpeed ...       % dz / lambda
    * PAT.RxFreq * 0.25;
PATBfInfo.Depth(1)  = ImgInfo.Depth(1);                                     % initial depth [mm]
PATBfInfo.Depth(2)  = ImgInfo.Depth(2);                                     % final depth [mm]
PATBfInfo.RxApod(1) = PAT.BeamformingKneeAngle * 4 * system.probe.Pitch ... % RxApodOne
    * 1000 / common.constants.SoundSpeed * PAT.RxFreq * 0.25;
PATBfInfo.RxApod(2) = PAT.BeamformingMaxAngle * 4 * system.probe.Pitch ...  % RxApodZero
    * 1000 / common.constants.SoundSpeed * PAT.RxFreq * 0.25;
PATBfInfo.PeakDelay = PAT.PeakDelay;

% ============================================================================ %

% Beamform selected buffers

idx_clock_PATBeamforming = tic;
clear BFStructPAT
BFStructPAT = processing.lutPAT(Sequence,PATModeId,PATBfInfo,NThreads);
BFStructPAT.Info.DebugMode = 0 ;
BFStructPAT = processing.reconPat(BFStructPAT, buffer(PATModeId));
PATBeamformingtime       = toc(idx_clock_PATBeamforming);
disp(['PAT beamforming duration: ' num2str(PATBeamformingtime) 's.']);
%
% ============================================================================ %

% Compute X scales
PATNbBeamformedCols = size(BFStructPAT.IQ, 2);
PATXAxis            = XOrigin + DeltaX * (0 : (PATNbBeamformedCols - 1));

% Compute Z scales
PATNbBeamformedRows = size(BFStructPAT.IQ, 1);
PATZAxis            = ZOrigin + DeltaZ * (0 : (PATNbBeamformedRows - 1));

% Display
figure(1);

% Compute Mean IQ Matrix
% Coherent averaging on PATNbFrames, this lowers the noise level by 10 * log(NbFrames)
MeanPATMatrixBeamformedIQ = mean(BFStructPAT.IQ, 3);
PAT.ThresholdAveraged      = PAT.Threshold - 10 * log10(PAT.NbFrames);
imagesc(PATXAxis, PATZAxis, 20 * log10(abs(MeanPATMatrixBeamformedIQ)), ...
    [PAT.ThresholdAveraged PAT.DynRangedB + PAT.ThresholdAveraged]);
colormap(gray);
colorbar;
axis equal;
axis tight;
title('PAT Image');

% ============================================================================ %
% ============================================================================ %

% UF image formation

% Display parameters
XOrigin = 0.0;
ZOrigin = ImgInfo.Depth(1);

% ============================================================================ %

% DO NOT CHANGE - Image info
clear UFBfInfo
UFBfInfo.LinePitch = DeltaX / system.probe.Pitch;                         % dx / PiezoPitch
UFBfInfo.PitchPix  = DeltaZ * 1000 / common.constants.SoundSpeed ...      % dz / lambda
    * UF.RxFreq * 0.25;
UFBfInfo.Depth(1)  = ImgInfo.Depth(1);                                    % initial depth [mm]
UFBfInfo.Depth(2)  = ImgInfo.Depth(2);                                    % final depth [mm]
UFBfInfo.RxApod(1) = UF.BeamformingKneeAngle * 4 * system.probe.Pitch ... % RxApodOne
    * 1000 / common.constants.SoundSpeed * UF.RxFreq * 0.25;
UFBfInfo.RxApod(2) = UF.BeamformingMaxAngle * 4 * system.probe.Pitch ...  % RxApodZero
    * 1000 / common.constants.SoundSpeed * UF.RxFreq * 0.25;
UFBfInfo.RxApod = max( min( UFBfInfo.RxApod, 2 ), 0 );

% ============================================================================ %

% Beamform selected buffers
idx_clock_UltrafastBeamforming = tic;
clear BFStructUF
BFStructUF = processing.lutFlats(Sequence,UFModeId,UFBfInfo,NThreads);
BFStructUF.Info.DebugMode = 0 ;
BFStructUF = processing.reconFlat(BFStructUF, buffer(UFModeId));
UFMatrixBeamformedIQ = mean(BFStructUF.IQ,3);
UFBeamformingtime = toc(idx_clock_UltrafastBeamforming);
disp(['Ultrafast beamforming duration: ' num2str(UFBeamformingtime) 's.']);

%
% ============================================================================ %
UFThreshold = 100;
UFDynRangedB = 60 ;
% Compute X scales
UFNbBeamformedCols = size(UFMatrixBeamformedIQ, 2);
UFXAxis            = XOrigin + DeltaX * (0 : (UFNbBeamformedCols - 1));

% Compute Z scales
UFNbBeamformedRows = size(UFMatrixBeamformedIQ, 1);
UFZAxis            = ZOrigin + DeltaZ * (0 : (UFNbBeamformedRows - 1));

% Display
figure(2);
hold off;
imagesc(UFXAxis, UFZAxis, 20 * log10(abs(UFMatrixBeamformedIQ)), ...
    [UF.Threshold UF.DynRangedB + UF.Threshold]);
colormap(gray);
colorbar;
axis equal;
axis tight;
title('Ultrafast Image');

% ============================================================================ %
% ============================================================================ %

TimeElapsed = toc(idx_clock_sequence)
