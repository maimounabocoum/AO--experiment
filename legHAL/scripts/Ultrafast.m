% clear all

% SCRIPTS.ULTRAFAST (PUBLIC)
%   Build and run a sequence with an ultrafast imaging.
%
%   Note - This function is defined as a script of SCRIPTS package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/25

% Sequence = usse.usse; Sequence = Sequence.selectHardware ; Sequence = Sequence.selectProbe

%% Parameters definition

% System parameters
%% 
AixplorerIP    = 'local'; % IP address of the Aixplorer device

DataFormat = 'RF'; % RF: beamforming from Matlab, BF: beamforming in the Aixplorer

ImagingVoltage = 10;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Image parameters
clear ImgInfo
ImgInfo.Depth(1)           = 1; % initial depth [mm]
ImgInfo.Depth(2)           = 10;  % image depth [mm]
ImgInfo.NbColumnsPerPiezo  = 1;
ImgInfo.NbRowsPerLambda    = 1;

% ============================================================================ %

% Ultrafast acquisition parameters
clear UF

% fondamental
UF.TxPolarity     = [ 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
UF.TxElemsPattern = [ 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% puls inv (PI)
% UF.TxPolarity     = [ 0 1 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
% UF.TxElemsPattern = [ 0 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% checker board fondamental (PM)
% UF.TxPolarity     = [ 0 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
% UF.TxElemsPattern = [ 1 2 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% checker board + Pulse inversion (PMPI), only valid with RxBandwidth = 1
% UF.TxPolarity     = [ 0 1 1 ]; % [ 0 1 ] : : Standard polarity, 1:Inverted polarity
% UF.TxElemsPattern = [ 0 1 2 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements

UF.PulseInversion = length( unique( UF.TxPolarity ) ) - 1 ;

UF.TwFreq       = 15/(UF.PulseInversion+1) ; % emission frequency [MHz]
UF.NbHcycle     = 2;               % # of half cycles
UF.FlatAngles   = [0];               % flat angles [deg]
UF.DutyCycle    = 1;               % duty cycle [0, 1]
UF.TxCenter     = system.probe.Pitch * system.probe.NbElemts/2;            % emission center [mm]
UF.TxWidth      = system.probe.Pitch * system.probe.NbElemts;            % emission width [mm]
UF.ApodFct      = 'none';          % emission apodization function (none, hanning)
UF.RxCenter     = UF.TxCenter;     % reception center [mm]
UF.RxWidth      = UF.TxWidth/2;      % reception width [mm]
UF.RxBandwidth  = 2;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
UF.FIRBandwidth = 90;              % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
UF.NbFrames     = 2;               % # of acquired images
UF.PRF          = 10000;            % pulse frequency repetition [Hz], between 2 different flats images (0 for greatest possible)
UF.FrameRateUF  = 0;
UF.FrameRate    = 0;
UF.TGC          = 900 * ones(1,8); % TGC profile
UF.TrigIn       = 0 ;
UF.TrigOut      = 0 ;
UF.TrigAll      = 0 ;
UF.NbLocalBuffer= 2 ;
UF.NbHostBuffer = 2 ;

UF.Repeat_sequence      = 2 ; %
UF.Repeat       = 2 ; % Repeat of the whole acquisition + transfer

% ============================================================================ %
%% DO NOT CHANGE - Additional parameters

% Additional parameters for ultrafast acquisition
UF.RxFreq = (1+UF.PulseInversion) * 4 * UF.TwFreq; % sampling frequency [MHz]

% Estimate RxDelay for ultrafast acquisition
UF.RxDelay = .75 * ImgInfo.Depth(1) * 1e3 / common.constants.SoundSpeed ;

% Estimate RxDuration for ultrafast acquisition
transmitDistanceMax = ImgInfo.Depth(2)/cosd( max(abs(UF.FlatAngles)) ) + sind( max(abs(UF.FlatAngles)) ) * UF.RxWidth;
returnDistanceMax = ImgInfo.Depth(2) * sind( max(abs(UF.FlatAngles)) ) + UF.RxWidth ;
returnDistanceMax = sqrt( returnDistanceMax^2 + ImgInfo.Depth(2)^2 ) ;
UF.RxDuration = (transmitDistanceMax + returnDistanceMax) / common.constants.SoundSpeed *1e3 + 4/UF.RxFreq;

% ============================================================================ %
% Ultrafast image formation parameters
UF.BeamformingKneeAngle = 0.40;
UF.BeamformingMaxAngle  = 0.50;
UF.DynRangedB           = 70;
UF.Threshold            = 70;

% DO NOT CHANGE - Image info
clear UFBfInfo
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

UFBfInfo.TxPolarity = UF.TxPolarity;
UFBfInfo.TxElemsPattern = UF.TxElemsPattern;
UFBfInfo.NbFlatAnglesAccum = 1;

ImgInfo.TxAlongRx = 10; % Default: 10

% ROI selection for image formation
% UFBfInfo.FirstLine = 128;  % Range: [1-system.probe.NbElemts]
% UFBfInfo.LastLine  = 192; % Range: [1-system.probe.NbElemts];
% UFBfInfo.Depth(1)  = 5;  % initial depth [mm], must be > ImgInfo.Depth(1) and < ImgInfo.Depth(2)
% UFBfInfo.Depth(2)  = 35; % final depth [mm], must be > UFBfInfo(1).Depth(1) and < ImgInfo.Depth(2)

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE -  acquisition mode

try
    
    % Create the ultrafast acquisition mode and add the push elusev
    clear AcmoList
    UltrafastAcmoID = 1 ;
    Acmo = acmo.ultrafast( ...
        'TwFreq',       UF.TwFreq, ...
        'NbHcycle',     UF.NbHcycle, ...
        'FlatAngles',   UF.FlatAngles, ...
        'DutyCycle',    UF.DutyCycle, ...
        'TxCenter',     UF.TxCenter, ...
        'TxWidth',      UF.TxWidth, ...
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
        'FrameRateUF',  UF.FrameRateUF, ...
        'FrameRate',    UF.FrameRate, ...
        'ControlPts',   UF.TGC,...
        'TxPolarity',   UF.TxPolarity,...
        'TxElemsPattern', UF.TxElemsPattern,...
        'TrigIn',       UF.TrigIn,...
        'TrigOut',      UF.TrigOut,...
        'TrigAll',      UF.TrigAll,...
        'Repeat',       UF.Repeat, ...
        'NbLocalBuffer',UF.NbLocalBuffer, ...
        'NbHostBuffer' ,UF.NbHostBuffer );

      AcmoList{UltrafastAcmoID} = Acmo ;
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
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

    Sequence = usse.usse( 'TPC',TPC, 'acmo',AcmoList, 'Popup',0, 'DataFormat',DataFormat,'Repeat',UF.Repeat_sequence );

    % Sequence = Sequence.selectProbe();
    [Sequence NbAcqRx] = Sequence.buildRemote();

catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return

end

% A = Sequence.getParam('acmo');
% Sequence.plot_diagram; xlim( [ 0 2/A{1}.getParam('FrameRate')*1e6 ] ); ylim( [ -1 2 ] ); hold on;
% plot( repmat( 1/A{1}.getParam('PRF')*1e6, 1, 2), [ -1e3 1e3 ], 'g' )
% plot( repmat( 1/A{1}.getParam('FrameRateUF')*1e6, 1, 2), [ -1e3 1e3 ], 'k' )
% plot( repmat( 1/A{1}.getParam('FrameRate')*1e6, 1, 2), [ -1e3 1e3 ], 'r' )

% return

%% Beamform selected buffers
clear BFStruct
NThreads = 4;

for k = 1:NbAcqRx
    if strcmp( Sequence.getParam('DataFormat'), 'BF' )
        BFStruct{k} = processing.lutFlats( Sequence, UltrafastAcmoID, UFBfInfo, NThreads, 'lutinfo_output',1 );
    else
        BFStruct{k} = processing.lutFlats( Sequence, UltrafastAcmoID, UFBfInfo, NThreads );
    end
end

if system.probe.Radius > 0
    ImgInfo.XOrigin = 0;

    if isfield( UFBfInfo, 'FirstLine' )
        ImgInfo.FirstLinePos = max( UFBfInfo.FirstLine, (UF.RxCenter-UF.RxWidth/2) / system.probe.Pitch ) ;
    else
        ImgInfo.FirstLinePos = (UF.RxCenter-UF.RxWidth/2) / system.probe.Pitch;
    end

    Nx = 512 ;
	Nz = 512 ;
    Data = processing.lutScanConvertImageFlat( BFStruct, ImgInfo, Nx, Nz );
end

%%
if strcmp( Sequence.getParam('DataFormat'), 'BF' )
    Sequence = Sequence.buildLutParams( BFStruct );
end

% Do NOT CHANGE - Sequence execution
try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress',AixplorerIP, 'InitTGC',UF.TGC, 'InitRxFreq',UF.RxFreq, 'InitSequence',0 );

    % Load sequence
    Sequence = Sequence.loadSequence();

    % Execute sequence
    clear buf;
    Sequence = Sequence.startSequence( 'Wait',0 );

    tic
    % Retrieve data
    for k = 1 : NbAcqRx
        buf(k) = Sequence.getData( 'Realign',2, 'Timeout',4 );
    end
    toc

    % Stop sequence
    Sequence = Sequence.stopSequence( 'Wait', 1 );

catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end

% ============================================================================ %
%% Display
% DO NOT CHANGE - Compute additional parameters
% Display parameters
XOrigin = double(min(Sequence.InfoStruct.rx(1).Channels - 1)) ... % reception left position
    * system.probe.Pitch;
ZOrigin = ImgInfo.Depth(1);
DeltaX = system.probe.Pitch / ImgInfo.NbColumnsPerPiezo;
DeltaZ = common.constants.SoundSpeed / 1000 /(UF.RxFreq / 4.0) ...
    / ImgInfo.NbRowsPerLambda;
% Compute X scales
UFNbBeamformedCols = size( BFStruct{1}.IQ, 2 );
UFXAxis            = XOrigin + DeltaX * (0 : (UFNbBeamformedCols - 1));

% Compute Z scales
UFNbBeamformedRows = size( BFStruct{1}.IQ, 1 );
UFZAxis            = ZOrigin + DeltaZ * (0 : (UFNbBeamformedRows - 1));

% ============================================================================ %

if strcmp( Sequence.getParam('DataFormat'), 'BF' )
    IQSynthetic = reshape(typecast(buf(1).data,'single'), 2, buf(1).nsample, buf(1).nline);
    ImgData = squeeze( abs(complex(IQSynthetic(1,:,:),IQSynthetic(2,:,:))) );

    figure(234212)
    NFirings = 1;
    imagesc( UFXAxis, UFZAxis, 20*log10(abs(ImgData/NFirings)) );
    colormap( gray(256) );
    caxis( [70 140] );
    colorbar

    axis equal tight; drawnow;
    
    return
end

%% reconstruction
for k=1:NbAcqRx
    BFStruct{k}.Info.DebugMode = 0 ;
    BFStruct{k} = processing.reconFlat(BFStruct{k}, buf(k));
end


figure(172334);

for b=1:length(buf)

    for k=1:UF.NbFrames
        tic
        nbI = length(UF.FlatAngles)/UFBfInfo.NbFlatAnglesAccum ;
        img = abs(mean(BFStruct{b}.IQ(:,:,(1:nbI)+(k-1)*nbI),3));
        %img = abs(BFStruct{b}.IQ(:,:,k));

        if system.probe.Radius > 0
            Data = processing.ScanConvertImage( Data, img );
            img = Data.img ;
            X = Data.XAxis;
            Z = Data.ZAxis;
        else
            X = UFXAxis ;
            Z = UFZAxis ;
            img = 20*log10(img);
        end

        imagesc( X, Z, img, [UF.Threshold UF.DynRangedB + UF.Threshold] )
        colormap(gray); colorbar;
        axis equal; axis tight;
        t = toc ;
        drawnow ;
        pause( max(0,1/25-t) );

    end

end
