% SCRIPTS.ELASTO (PUBLIC)
%   Build and run a sequence with a push elusev and ultrafast imaging.
%
%   Note - This function is defined as a script of SCRIPTS package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/25

%% Parameters definition

NThreads = 2;

% System parameters
AixplorerIP    = '127.0.0.1'; % IP address of the Aixplorer device
AixplorerIP = '192.168.3.228'; % IP address of Aixplorer
ImagingVoltage = 50;             % imaging voltage [V]
ImagingCurrent = 2;              % security current limit [A]
PushVoltage    = 50;             % push voltage [V]
PushCurrent    = 10;              % security limit for push current [A]

% ============================================================================ %

% Image parameters
ImgInfo.LinePitch = 1 ;
ImgInfo.PitchPix = 1 ;
ImgInfo.RxApod = [0.4 0.6];
ImgInfo.Depth(1)           = 1; % initial depth [mm]
ImgInfo.Depth(2)           = 40;  % image depth [mm]
ImgInfo.CorrectFactorDepth = 0.4; % depth correction to estimate the acquisition duration
ImgInfo.NbColumnsPerPiezo  = 1;
ImgInfo.NbRowsPerLambda    = 1;

% ============================================================================ %

% Push parameters
PushInfo.TxFreq       = 4 ; %2.8125;           % push emission frequency [MHz]
PushInfo.DutyCycle    = 1;           % duty cycle [0, 1]
PushInfo.ApodFct      = 'hanning';        % apodization function
PushInfo.RatioFD      = 2;           % ratio F/D
PushInfo.PushDuration = 150;           % push duration [us]
PushInfo.Duration     = 165;           % event duration [us]
PushInfo.TxCenter     = system.probe.Pitch * system.probe.NbElemts/2;            % x-position of emission center [mm]
PushInfo.PosX         = system.probe.Pitch * system.probe.NbElemts/2;            % x-position of the focal point [mm]
PushInfo.PosZ         = [30 35 40 45]; % z-position of the focal point [mm]

% ============================================================================ %

% Ultrafast acquisition parameters
UF.TxFreq       = 9;            % emission frequency [MHz]
UF.NbHcycle     = 6;               % # of half cycles
UF.FlatAngles   = [-4 -2 0 2 4];               % flat angles [deg]
UF.DutyCycle    = 1;               % duty cycle [0, 1]
UF.TXCenter     = system.probe.Pitch * system.probe.NbElemts/2;            % emission center [mm]
UF.TXWidth      = system.probe.Pitch * system.probe.NbElemts;            % emission width [mm]
UF.ApodFct      = 'hanning';          % emission apodization function (none, hanning)
UF.RxCenter     = UF.TXCenter ;            % reception center [mm]
UF.RxWidth      = UF.TXWidth;            % reception width [mm]
UF.RxBandwidth  = 2;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
UF.FIRBandwidth = 60;              % FIR receiving bandwidth [%] - center frequency = UFTxFreq
UF.NbFrames     = 60;             % # of acquired images
UF.PRF          = 2000;           % pulse frequency repetition [Hz] (0 for greatest possible)
UF.TGC          = 800 * ones(1,8); % TGC profile

% ============================================================================ %

% Ultrafast image formation
UF.BeamformingKneeAngle = 0.30;
UF.BeamformingMaxAngle  = 0.40;
UF.DynRangedB           = 55;
UF.Threshold            = 100;

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Additional parameters

% Additional parameters for ultrafast acquisition
UF.RxFreq = 4 * UF.TxFreq; % sampling frequency [MHz]

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

%% DO NOT CHANGE - Create acquisition mode

try
    
    % Create the push elusev
    Push = elusev.push( ...
        'TwFreq',       PushInfo.TxFreq, ...
        'DutyCycle',    PushInfo.DutyCycle, ...
        'ApodFct',      PushInfo.ApodFct, ...
        'RatioFD',      PushInfo.RatioFD, ...
        'PushDuration', PushInfo.PushDuration, ...
        'Duration',     PushInfo.Duration, ...
        'TxCenter',     PushInfo.TxCenter, ...
        'PosX',         PushInfo.PosX, ...
        'PosZ',         PushInfo.PosZ);
    
    % Create the ultrafast acquisition mode and add the push elusev
    Acmo = acmo.ultrafast( ...
        'TwFreq',       UF.TxFreq, ...
        'NbHcycle',     UF.NbHcycle, ...
        'FlatAngles',   UF.FlatAngles, ...
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
        'RepeatFlat',   UF.NbFrames, ...
        'PRF',          UF.PRF, ...
        'ControlPts',   UF.TGC, ...
        'elusev',       Push);
    
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
        'imgCurrent', ImagingCurrent, ...
        'pushVoltage', PushVoltage, ...
        'pushCurrent', PushCurrent);
    
    % Create  and build the sequence
    Sequence           = usse.usse( 'TPC', TPC, 'acmo', Acmo, 'Popup',0 );
    [Sequence NbAcqRx] = Sequence.buildRemote();
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

if 0
    A = Sequence.getParam('acmo');
    Sequence.plot_diagram; xlim( [ 0 PushInfo.Duration * length(PushInfo.PosZ) + 2/A{1}.getParam('FrameRate')*1e6 ] ); ylim( [ -1 2 ] ); hold on;
    plot( repmat( 1/A{1}.getParam('PRF')*1e6, 1, 2), [ -1e3 1e3 ], 'g' )
    plot( repmat( 1/A{1}.getParam('FrameRateUF')*1e6, 1, 2), [ -1e3 1e3 ], 'k' )
    plot( repmat( 1/A{1}.getParam('FrameRate')*1e6, 1, 2), [ -1e3 1e3 ], 'r' )
end

% ============================================================================ %
% ============================================================================ %

%% Do NOT CHANGE - Sequence execution

try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP);

    % Load sequence
    Sequence = Sequence.loadSequence();

    % Execute sequence
    clear buffer;
    Sequence = Sequence.startSequence('Wait', 0);

    % Retrieve data
    buffer = Sequence.getData('Realign',0, 'Timeout',30);

    % Stop sequence
    Sequence = Sequence.stopSequence('Wait', 1);
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end

% ============================================================================ %
% ============================================================================ %

%% UF image formation

% Display parameters
XOrigin = double(min(Sequence.InfoStruct.rx(1).Channels - 1)) ... % reception left position
    * system.probe.Pitch;
ZOrigin = ImgInfo.Depth(1);

% ============================================================================ %

% DO NOT CHANGE - Compute additional parameters
DeltaX = system.probe.Pitch / ImgInfo.NbColumnsPerPiezo;
DeltaZ = common.constants.SoundSpeed / 1000 /(UF.RxFreq / 4.0) ...
    / ImgInfo.NbRowsPerLambda;

% DO NOT CHANGE - Image info
UFBfInfo.LinePitch = 1 / ImgInfo.NbColumnsPerPiezo;                       % dx / PiezoPitch
UFBfInfo.PitchPix  = 1 / ImgInfo.NbRowsPerLambda;                         % dz / lambda
UFBfInfo.Depth(1)  = ImgInfo.Depth(1);                                    % initial depth [mm]
UFBfInfo.Depth(2)  = ImgInfo.Depth(2);                                    % final depth [mm]
UFBfInfo.RxApod(1) = UF.BeamformingKneeAngle * 4 * system.probe.Pitch ... % RxApodOne
    * 1000 / common.constants.SoundSpeed * UF.RxFreq * 0.25;
UFBfInfo.RxApod(2) = UF.BeamformingMaxAngle * 4 * system.probe.Pitch ...  % RxApodZero
    * 1000 / common.constants.SoundSpeed * UF.RxFreq * 0.25;

UFBfInfo.RxApod(1) = min(2,UFBfInfo.RxApod(1));
UFBfInfo.RxApod(2) = min(2,UFBfInfo.RxApod(2));

% ============================================================================ %

% Beamform selected buffers
BFStruct = processing.lutSynthetic(Sequence,1,UFBfInfo);
BFStruct.Info.DebugMode = 2 ;
BFStruct = processing.reconSynthFlat(BFStruct, buffer,NThreads);

for k = 1:((BFStruct.Info.NImages)-1)
    correl = BFStruct.IQ(:,:,k).*conj(BFStruct.IQ(:,:,k+1));
    correl = filter2(ones(3,3)/9,correl);
    velocity(:,:,k) = -angle(correl);
end

% ============================================================================ %

% Compute X scales
UFNbBeamformedCols = size(BFStruct.IQ, 2);
UFXAxis            = XOrigin + DeltaX * (0 : (UFNbBeamformedCols - 1));

% Compute Z scales
UFNbBeamformedRows = size(BFStruct.IQ, 1);
UFZAxis            = ZOrigin + DeltaZ * (0 : (UFNbBeamformedRows - 1));

% Display b-mode images
% figure(1);
% for k = 1 : (size(BFStruct.IQ, 3)-1)
%     imagesc(UFXAxis, UFZAxis, 20 * log10(abs(BFStruct.IQ(:,:,k))), ...
%         [UF.Threshold UF.DynRangedB + UF.Threshold]);
%     colormap(gray); colorbar;
%     axis equal; axis tight;
%     pause(.1);
% end
if system.probe.Radius > 0
    [XAxis,ZAxis,velocityScan] = processing.ScanconvertVelocity(Sequence,1,PushInfo,ImgInfo,UF,velocity);
end

return

%% plot
for k = 1:((BFStruct.Info.NImages)-1)
    figure( 124516 )
    imagesc( velocity(:,:,k) )
    pause(0.1)
end
