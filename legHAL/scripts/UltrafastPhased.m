% SCRIPTS.ULTRAFASTPHASED (PUBLIC)
%   Build and run a sequence with an ULTRAFASTPHASED imaging.
%
%   Note - This function is defined as a script of SCRIPTS package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/25

%% Parameters definition

% System parameters
debugMode = 0;
AixplorerIP    = '192.168.1.160';% IP address of the Aixplorer device
ImagingVoltage = 40;            % imaging voltage [V]
ImagingCurrent = 1;             % security current limit [A]

% ============================================================================ %

repetition = 1000 ;

% Image parameters
ImgInfo.Depth(1)           = 5;% initial depth [mm]
ImgInfo.Depth(2)           = 60; % image depth [mm]
ImgInfo.CorrectFactorDepth = 0.3;% depth correction to estimate the acquisition duration
ImgInfo.NbColumnsPerPiezo  = 1;
ImgInfo.NbRowsPerLambda    = 1;
ImgInfo.zApex = 16 ;

% =======================================================================²==== %

% ULTRAFASTPHASED acquisition parameters²
UF.PulseInversion = 0;% 1 or 0
UF.TxFreq       = 5.6250/(UF.PulseInversion+1);% emission frequency [MHz]
UF.NbHcycle     = 2;              % # of half cycles
UF.xApex        = [-3 0 3] + system.probe.NbElemts*system.probe.Pitch/2;
UF.zApex        = [ 1 0 1] + ImgInfo.zApex;
UF.DutyCycle    = 1;              % duty cycle [0, 1]
UF.ApodFct      = 'none';         % emission apodization function (none, hanning)
UF.RxBandwidth  = 2;              % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
UF.FIRBandwidth = 90;             % FIR receiving bandwidth [%] - center frequency = UFTxFreq
UF.NbFrames     = 1;              % # of acquired images
UF.PRF          = 3000;           % pulse frequency repetition [Hz] (0 for greatest possible)
UF.FrameRate    = 20;             % pulse frequency repetition [Hz] (0 for greatest possible)
UF.TGC          = [500 600 700 800 900 960];%900 * ones(1,8);% TGC profile
UF.TrigIn       = 0;
% ============================================================================ %

% ULTRAFASTPHASED image formation
UF.BeamformingKneeAngle = 0.40;
UF.BeamformingMaxAngle  = 0.50;
UF.DynRangedB           = 40;
UF.Threshold            = 70;

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Additional parameters

% Additional parameters for ULTRAFASTPHASED acquisition
UF.RxFreq = (1+UF.PulseInversion) * 4 * UF.TxFreq;% sampling frequency [MHz]

% Estimate RxDelay for ULTRAFASTPHASED acquisition
UF.RxDelay = floor((1 - ImgInfo.CorrectFactorDepth) * ImgInfo.Depth(1) * 1e3 ...
    * UF.RxFreq / common.constants.SoundSpeed) / UF.RxFreq;

% Estimate RxDuration for ULTRAFASTPHASED acquisition
UF.RxDuration = ceil((1 + ImgInfo.CorrectFactorDepth) ...
    * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * (UF.RxFreq / 2^(UF.RxBandwidth - 1)) ...
    / (common.constants.SoundSpeed * 128)) * 128 ...
    / (UF.RxFreq / 2^(UF.RxBandwidth - 1));

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE -  acquisition mode

try
    
    % Create the ULTRAFASTPHASED acquisition mode and add the push elusev
    Acmo = acmo.ultraphased( ...
        'TwFreq',       UF.TxFreq, ...
        'NbHcycle',     UF.NbHcycle, ...
        'xApex',        UF.xApex, ...
        'zApex',        UF.zApex, ...
        'DutyCycle',    UF.DutyCycle, ...
        'TxCenter',     system.probe.NbElemts*system.probe.Pitch/2, ...
        'TxWidth',      system.probe.NbElemts*system.probe.Pitch, ...
        'ApodFct',      UF.ApodFct, ...
        'RxFreq',       UF.RxFreq, ...
        'RxDuration',   UF.RxDuration, ...
        'RxDelay',      UF.RxDelay, ...
        'RxCenter',     system.probe.NbElemts*system.probe.Pitch/2, ...
        'RxWidth',      system.probe.NbElemts*system.probe.Pitch, ...
        'RxBandwidth',  UF.RxBandwidth, ...
        'FIRBandwidth', UF.FIRBandwidth, ...
        'RepeatFlat',   UF.NbFrames, ...
        'PRF',          UF.PRF, ...
        'FrameRate',    UF.FrameRate, ...
        'ControlPts',   UF.TGC,...
        'PulseInv',     UF.PulseInversion,...
        'TrigIn',       UF.TrigIn,...
        'NbHostBuffer', 2);
    
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
    Sequence           = usse.usse('TPC', TPC, 'acmo', Acmo);
    Sequence = Sequence.setParam('Repeat',repetition,'DropFrames',0);
    [Sequence NbAcqRx] = Sequence.buildRemote();
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% BEAMFORMING
% ============================================================================ %


bfStruct.fNumber = 2 ; % fnumber
bfStruct.linePitch = 0.5*pi/180;
bfStruct.thetaOrigin = -30*pi/180;
bfStruct.nbRecon = 120;
bfStruct.nbLinesPerRecon = 1;

bfStruct.speedOfSound = common.constants.SoundSpeed;
bfStruct.piezoPitch = system.probe.Pitch*1e-3;
bfStruct.demodFreq = UF.TxFreq*1e6;
bfStruct.rOrigin = (ImgInfo.zApex+ImgInfo.Depth(1))*1e-3;
bfStruct.peakDelay = 0;
bfStruct.nbSources = length(UF.xApex);

bfStruct.lambda = bfStruct.speedOfSound/bfStruct.demodFreq;
bfStruct.pixelPitch = bfStruct.lambda/2;
bfStruct.nbPiezos = system.probe.NbElemts;
bfStruct.firstSample = Sequence.InfoStruct.event(1).skipSamples;
bfStruct.nbSamples = Sequence.InfoStruct.event(1).numSamples;
bfStruct.nbPixelsPerLine = (ImgInfo.Depth(2)-ImgInfo.Depth(1))/bfStruct.pixelPitch*1e-3;
bfStruct.normMode=2;
bfStruct.synthAcq = 0;
bfStruct.frame_per_frame = 0;
bfStruct.zApex = ImgInfo.zApex*1e-3;
bfStruct.idxTransmitToBeamform = 0;
bfStruct.usegpu = 1 ;
bfStruct.idxFrame = 0 ;

for k=1:bfStruct.nbSources
    bfStruct.xzSource(2*k-1) = (UF.xApex(k)-system.probe.NbElemts*system.probe.Pitch/2)*1e-3;
    bfStruct.xzSource(2*k) = (-UF.zApex(k)+ImgInfo.zApex)*1e-3;
end
bfStruct.channelOffset = Sequence.InfoStruct.mode(1).channelSize/2;

parameters.NR = bfStruct.nbPixelsPerLine;
parameters.NTheta = bfStruct.nbRecon*bfStruct.nbLinesPerRecon;

parameters.Nx = 512;
parameters.Nz = 512;

parameters.AngleOfFirstLine = bfStruct.thetaOrigin;
parameters.AngleStep = bfStruct.linePitch;
parameters.FirstSampleAxialPosition = bfStruct.rOrigin;
parameters.RadialStep = bfStruct.pixelPitch;
parameters.OffSet = zeros(2,1, 'double');
parameters.SizeOfImg = zeros(2,1, 'double');
parameters.NbVois = 1;
parameters.SmoothDistance = 2;
parameters.SecondPass = 0;
parameters.OffSetX = 0;
parameters.OffSetZ = 0;
parameters.SizeOfImgX = 0;
parameters.SizeOfImgZ = 0;
parameters.ComputeOffSetAndSize = 1;
OUT = zeros(parameters.Nx,parameters.Nz,'single');


lutsize = zeros(1,'int32');

parameters_array = processing.SCV_Parser(parameters);
processing.ScanConversionTable(parameters_array,lutsize);

parameters.OffSetX = parameters_array(10);
parameters.OffSetZ = parameters_array(11);
parameters.SizeOfImgX = parameters_array(12);
parameters.SizeOfImgZ = parameters_array(13);


NbVoistot = (parameters.NbVois*2)^2;

parameters.SecondPass = 1;
LUT_coeff = zeros(lutsize*NbVoistot,1, 'single');
LUT_X = zeros(lutsize,1, 'int16');
LUT_Z = zeros(lutsize,1, 'int16');
LUT_Vois1 = zeros(lutsize*NbVoistot,1, 'int16');
LUT_Vois2 = zeros(lutsize*NbVoistot,1, 'int16');

processing.ScanConversionTable(processing.SCV_Parser(parameters),LUT_coeff,LUT_X,LUT_Z,LUT_Vois1,LUT_Vois2,lutsize);


XAxis = parameters.OffSetX + (0:(parameters.Nx-1))*parameters.SizeOfImgX/(parameters.Nx-1);
ZAxis = parameters.OffSetZ + (0:(parameters.Nz-1))*parameters.SizeOfImgZ/(parameters.Nz-1);

%%


figure(999);
h=imagesc(XAxis,ZAxis,20*log10(abs(OUT/bfStruct.nbSources)'));
axis equal;
axis tight;
caxis([10 60]);
colormap gray;
drawnow;

%% Do NOT CHANGE - Sequence execution

try
    Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP);
        
    % Load sequence
    Sequence = Sequence.loadSequence();
    
    % Execute sequence
    clear buff;
    Sequence = Sequence.startSequence('Wait', 0);
    zob = '0';
    for k=1:repetition
        % Initialize remote on systems
        
        buff=Sequence.getData('Realign', 0);
        
        tic
        IQ = beamformerPhasedSynthetic(bfStruct,buff.data,buff.alignedOffset);
        img = abs(complex(IQ(1:2:end,:),IQ(2:2:end,:)));
        
        
        processing.ScanConvertLin(LUT_coeff,LUT_X,LUT_Z,LUT_Vois1,LUT_Vois2,parameters.NbVois,lutsize,single(img'),OUT);
        set(h,'CData',20*log10(abs(OUT)'));
        drawnow;
        zob = get(gcf,'currentcharacter') ;
        toc
        if(zob ~= '0')
            break ;
        end
        
    end
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

Sequence = Sequence.stopSequence('Wait', 0);