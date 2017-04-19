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
AixplorerIP    = '192.168.1.37'; % IP address of the Aixplorer device

ImagingVoltage = 40;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Image parameters
clear ImgInfo
ImgInfo.Depth(1)           = 35; % initial depth [mm]
ImgInfo.Depth(2)           = 50;  % image depth [mm]
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

UF.TwFreq       = 9/(UF.PulseInversion+1) ; % emission frequency [MHz]
UF.NbHcycle     = 2;               % # of half cycles
UF.FlatAngles   = [-3 0 3];               % flat angles [deg]
UF.DutyCycle    = 1;               % duty cycle [0, 1]
UF.TxCenter     = system.probe.Pitch * system.probe.NbElemts/2;            % emission center [mm]
UF.TxWidth      = system.probe.Pitch * system.probe.NbElemts;            % emission width [mm]
UF.ApodFct      = 'none';          % emission apodization function (none, hanning)
UF.RxCenter     = system.probe.Pitch * (system.probe.NbElemts-128)/2;     % reception center [mm]
UF.RxWidth      = system.probe.Pitch * system.probe.NbElemts;      % reception width [mm]
UF.RxBandwidth  = 2;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
UF.FIRBandwidth = 90;              % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
UF.NbFrames     = 40;               % # of acquired images
UF.PRF          = 0;            % pulse frequency repetition [Hz] (0 for greatest possible)
UF.FrameRateUF  = 2500;
UF.FrameRate    = 0;
UF.TGC          = 960 * ones(1,8); % TGC profile
UF.TrigIn       = 0 ;
UF.TrigOut      = 0 ;
UF.TrigAll      = 0 ;
UF.Repeat       = 1 ; % Repeat of the whole acquisition + transfer
UF.NbLocalBuffer= 2 ;
UF.NbHostBuffer = 4 ;
UF.Repeat_sequence = 1;

% ============================================================================ %
%% DO NOT CHANGE - Additional parameters

% Additional parameters for ultrafast acquisition
UF.RxFreq = (1+UF.PulseInversion) * 4 * UF.TwFreq; % sampling frequency [MHz]

% Estimate RxDelay for ultrafast acquisition
UF.RxDelay = .75 * ImgInfo.Depth(1) * 1e3 / common.constants.SoundSpeed ;

% Estimate RxDuration for ultrafast acquisition
transmitDistanceMax = ImgInfo.Depth(2)/cosd(max(abs(UF.FlatAngles))) + sind(max(abs(UF.FlatAngles)))*UF.RxWidth;
returnDistanceMax = ImgInfo.Depth(2)*sind(max(abs(UF.FlatAngles))) + UF.RxWidth ;
returnDistanceMax = sqrt(returnDistanceMax^2 + ImgInfo.Depth(2)^2)
UF.RxDuration = (transmitDistanceMax + returnDistanceMax) / common.constants.SoundSpeed *1e3 + 4/UF.RxFreq;

% bfo
UF.NbFrames_tot = UF.NbFrames*UF.Repeat; %*UF.Repeat_sequence;
fire_tot = UF.NbFrames_tot*length(UF.FlatAngles)
fire_buff = UF.NbFrames*length(UF.FlatAngles)
time_emission = UF.NbFrames_tot/UF.PRF

% ============================================================================ %
% Ultrafast image formation parameters
UF.BeamformingKneeAngle = 0.40;
UF.BeamformingMaxAngle  = 0.50;
UF.DynRangedB           = 60;
UF.Threshold            = 90;

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

% ROI selection for image formation
% UFBfInfo.FirstLine = 1;  % Range: [1-system.probe.NbElemts]
% UFBfInfo.LastLine  = 64; % Range: [1-system.probe.NbElemts];
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
    Sequence = usse.usse('TPC', TPC, 'acmo', AcmoList, 'Repeat',UF.Repeat_sequence, 'Popup',0 );
   % Sequence = Sequence.selectProbe();
    [Sequence NbAcqRx] = Sequence.buildRemote();
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end

SeqAcmo = Sequence.getParam('acmo');
Sequence.plot_diagram; ylim( [ -1 2 ] ); hold on;
% xlim( [ 0 2/SeqAcmo{1}.getParam('PRF')*1e6 ] );
xlim( [ 0 2/SeqAcmo{1}.getParam('FrameRateUF')*1e6 ] );
% xlim( [ 0 2/SeqAcmo{1}.getParam('FrameRate')*1e6 ] );
plot( repmat( 1/SeqAcmo{1}.getParam('PRF')*1e6, 1, 2), [ -1e3 1e3 ], 'g' )
plot( repmat( 1/SeqAcmo{1}.getParam('FrameRateUF')*1e6, 1, 2), [ -1e3 1e3 ], 'k' )
plot( repmat( 1/SeqAcmo{1}.getParam('FrameRate')*1e6, 1, 2), [ -1e3 1e3 ], 'r' )

% return
% 
% %% Beamform selected buffers
% clear BFStruct
% NThreads = 4;
% 
% for k=1:NbAcqRx
%     BFStruct{k} = processing.lutFlats( Sequence, UltrafastAcmoID, UFBfInfo, NThreads );
% end
% 
% if system.probe.Radius > 0
%     ImgInfo.XOrigin = 0;
% 
%     if isfield( UFBfInfo, 'FirstLine' )
%         ImgInfo.FirstLinePos = max( UFBfInfo.FirstLine,  (UF.RxCenter-UF.RxWidth/2) / system.probe.Pitch ) ;
%     else
%         ImgInfo.FirstLinePos = (UF.RxCenter-UF.RxWidth/2) / system.probe.Pitch;
%     end
% 
%     Nx = 512 ;
% 	Nz = 512 ;
%     Data = processing.lutScanConvertImageFlat( BFStruct, ImgInfo, Nx, Nz );
% end

%% Do NOT CHANGE - Sequence execution
try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress',AixplorerIP, 'InitTGC',UF.TGC, 'InitRxFreq',UF.RxFreq );

    % Load sequence
    Sequence = Sequence.loadSequence();

    % Execute sequence
    clear buf;
    Sequence = Sequence.startSequence('Wait', 0);

    tic
    % Retrieve data
    for k = 1 : NbAcqRx
        buf{k} = Sequence.getData('Realign',0);
    end
    toc

    % Stop sequence
    Sequence = Sequence.stopSequence('Wait', 1);

catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end



%%
clear BFStruct
NThreads = 12;
disp('beamforming');
tic
% sommation coherente
for k=1:NbAcqRx*UF.Repeat_sequence
    
    BFStruct{k} = processing.lutSynthetic(Sequence,1,UFBfInfo);
    BFStruct{k}.Info.DebugMode = 0 ;
    BFStruct{k} = processing.reconSynthFlat(BFStruct{k}, buf{k},NThreads);
    buf{k} = 0;
end


%%

% for k=1:NbAcqRx
%     BFStruct{k}.Info.DebugMode = 0 ;
%     BFStruct{k} = processing.reconFlat(BFStruct{k}, buf(k));
% end


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
UFNbBeamformedCols = size(BFStruct{1}.IQ, 2);
UFXAxis            = XOrigin + DeltaX * (0 : (UFNbBeamformedCols - 1));

% Compute Z scales
UFNbBeamformedRows = size(BFStruct{1}.IQ, 1);
UFZAxis            = ZOrigin + DeltaZ * (0 : (UFNbBeamformedRows - 1));
% ============================================================================ %

% 
% figure %(1);
% 
% for b=1:length(buf)
%     
%     for k=1:UF.NbFrames
%         tic
%         nbI = length(UF.FlatAngles)/UFBfInfo.NbFlatAnglesAccum ;
%         img = abs(mean(BFStruct{b}.IQ(:,:,(1:nbI)+(k-1)*nbI),3));
%         %img = abs(BFStruct{b}.IQ(:,:,k));
%         
%         if system.probe.Radius > 0
%             Data = processing.ScanConvertImage( Data, img );
%             img = Data.img ;
%             X = Data.XAxis;
%             Z = Data.ZAxis;
%         else
%             X = UFXAxis ;
%             Z = UFZAxis ;
%             img = 20*log10(img);            
%         end
%         
%         imagesc( X, Z, img, [UF.Threshold UF.DynRangedB + UF.Threshold] )
%         colormap(gray); colorbar;
%         axis equal; axis tight;
%         t = toc ;
%         drawnow ;
%         pause(max(0,1/25-t));
% 
%     end
%     
% end



%%
IQF = zeros(size(BFStruct{1}.IQ,1),size(BFStruct{1}.IQ,2),UF.NbFrames_tot,'single');

for j = 1:UF.Repeat %*UF.Repeat_sequence;
    
    IQF(:,:,[1:UF.NbFrames] + (j-1)*UF.NbFrames ) = BFStruct{j}.IQ(:,:,1:UF.NbFrames);
end

par.Nim = UF.NbFrames_tot;
par.fech = UF.PRF;

%% 
% figure;
% colormap gray
% for i = 1:10:UF.NbFrames_tot
%     a = abs(IQF(:,:,i));
%     imagesc(20*log10(a/max(a(:))))
%     caxis([-50 0])
%     title(i);
%     pause(0.05)
% end
%         
% return

%%
[B,A] = butter(3,200/UF.FrameRateUF*2,'high');
IQF2 = filter(B,A,IQF,[],3);
close all;

figure(823253);
for k = 1:size(IQF2,3)
%     k
    imagesc(abs(IQF2(:,:,k)));
    title(k);
    caxis( [ 0 4e5 ] )
    drawnow
    pause(.01)
end

%%

% figure( 124516 )
% plot(squeeze(abs(IQF(60,60,:))))
% 
% disp( [ 'Imaging included ' num2str(UF.NbFrames) ' Frames of ' num2str(length(UF.FlatAngles)) ' flats angles and last ' num2str( 1/(SeqAcmo{1}.getParam('FrameRateUF'))*UF.NbFrames) ) ' s' ] )

disp( [ 'Imaging included ' num2str(UF.NbFrames) ' Frames of ' num2str(length(UF.FlatAngles)) ' flats angles and last ' num2str( 1/(SeqAcmo{1}.getParam('FrameRateUF'))*UF.NbFrames) ) ' s' ] )
