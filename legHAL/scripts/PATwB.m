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
NbAcqTotal = 1;
    
% System parameters
NThreads = 1 ;
AixplorerIP    = '192.168.1.198'; % IP address of the Aixplorer device
ImagingVoltage = 50;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Image parameters
clear ImgInfo
ImgInfo.Depth(1)           = 0.5; % initial depth [mm]
ImgInfo.Depth(2)           = 30;  % image depth [mm]
ImgInfo.CorrectFactorDepth = 0.4; % depth correction to estimate the acquisition duration
ImgInfo.NbColumnsPerPiezo  = 1;
ImgInfo.NbRawsPerLambda    = 1;
BImgInfo.NbRawsPerLambda    = 1;

% ============================================================================ %

% PAT acquisition parameters
clear PAT
PAT.NbFrames      = 16;              % # of PAT images
PAT.RxFreq        = 20;              % sampling frequency [MHz]
PAT.RxCenter      = 19.2;            % receiving center [mm]
PAT.FIRBandwidth  = 90;              % FIR receiving bandwidth [%] - center frequency = PAT.RxFreq / 4
PAT.TGC           = 900 * ones(1,8); % TGC profile
PAT.SyntAcq       = 0;               % synthetic reception
PAT.TrigIn        = 1;               % enable trigger in
PAT.TrigOut       = 0;               % duration of trigger out [us] - 0 corresponds to no trigger out
PAT.TrigOutDelay  = 0;               % delay between the trigger out and the acquisition [us]
PAT.PRF           = 10;             % Pulse Repetition Frequency [Hz]
                                     % make sure PAT.PRF > laser firing repetition frequency
PAT.PeakDelay     = -1.3;            % Delay added on RF to beamform image [us] (to take into account delay between laser firing and ultrasound acquisition)

% ============================================================================ %

% Ultrafast acquisition parameters
clear B
B.TxFreq        = 5;             % emission frequency [MHz]
B.NbHcycle      = 2;               % # of half cycles
B.SteerAngle    = 0;               % O degree
B.Focus         = 20;              % Focus depth [mm]
B.DutyCycle     = 1;               % Duty Cycle 0 - 1
B.XOrigin       = 0;
B.FirstLinePos  = 1;
B.TxLinePitch   = 4;
B.NbFocLines    = system.probe.NbElemts/B.TxLinePitch;
B.ApodFct       = 'none';
B.FIRBandwidth  = 80;
B.TXPolarity    = 0;
B.TGC           = 900 * ones(1,8); % TGC profile
B.txPitch       = B.TxLinePitch;

B.RxBandwidth = 2;
B.TxElemsPattern = 0;
B.FDRatio = 4;

% ============================================================================ %

% PAT image formation
PAT.BeamformingKneeAngle = 0.20;
PAT.BeamformingMaxAngle  = 0.30;
PAT.DynRangedB           = 25;
PAT.Threshold            = 120;

% ============================================================================ %

% B image formation
B.BeamformingKneeAngle = 0.20;
B.BeamformingMaxAngle  = 0.30;
B.DynRangedB           = 55;
B.Threshold            = 100;

ImgInfo.Depth(1) = max( ImgInfo.Depth(1), .5 - PAT.PeakDelay*common.constants.SoundSpeed*1e-3 );

% Image info
% fondamental
BImgInfo.TxPolarity     = [ 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
BImgInfo.TxElemsPattern = [ 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% puls inv (PI)
% ImgInfo.TxPolarity     = [ 0 1 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
% ImgInfo.TxElemsPattern = [ 0 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% checker board fondamental (PM)
% ImgInfo.TxPolarity     = [ 0 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
% ImgInfo.TxElemsPattern = [ 1 2 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% checker board + Pulse inversion (PMPÏ), only valid with RxBandwidth = 1
% ImgInfo.TxPolarity     = [ 0 1 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
% ImgInfo.TxElemsPattern = [ 1 0 2 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
% ImgInfo.TxPolarity     = [ 0 0 1 1 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
% ImgInfo.TxElemsPattern = [ 1 2 1 2 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements

BImgInfo.pulseInversion = length( unique( BImgInfo.TxPolarity ) ) - 1 ;
B.RxFreq         = 4*B.TxFreq * (1+BImgInfo.pulseInversion);

BImgInfo.SteeringAngle  = B.SteerAngle ;
BImgInfo.XOrigin        = B.XOrigin ;
BImgInfo.FirstLinePos   = B.FirstLinePos ; % position of the first line in elt [>=1]
BImgInfo.txPitch        = B.txPitch ; % txpitch [elements]
BImgInfo.nbTx           = B.NbFocLines; % txpitch [elements]
BImgInfo.RxLinesPerTx   = B.TxLinePitch;  % number of received line per tx (beamforming)
BImgInfo.PitchPix       = BImgInfo.NbRawsPerLambda;  % dz / lambda
BImgInfo.Depth(1)       = ImgInfo.Depth(1);   % initial depth [mm]
BImgInfo.Depth(2)       = ImgInfo.Depth(2);  % final depth [mm]
BImgInfo.RxApod(1)      = B.BeamformingKneeAngle * 4 * system.probe.Pitch ... % RxApodOne
    * 1000 / common.constants.SoundSpeed * B.RxFreq * 0.25;
BImgInfo.RxApod(2)      = B.BeamformingMaxAngle * 4 * system.probe.Pitch ... % RxApodOne
    * 1000 / common.constants.SoundSpeed * B.RxFreq * 0.25;

BImgInfo.CorrectFactorDepth = 1.4;

B.NumSamples   = ceil((1+BImgInfo.CorrectFactorDepth) * (2 * BImgInfo.Depth(2) - BImgInfo.Depth(1)) * 1e3 ...
    * B.RxFreq / (common.constants.SoundSpeed * 2^(B.RxBandwidth-1) * 128)) * 128;
B.SkipSamples  = floor(0. * BImgInfo.Depth(1) * B.RxFreq * 1e3 ...
    / common.constants.SoundSpeed);
B.RxDuration = B.NumSamples / B.RxFreq * 2^(B.RxBandwidth-1);

B.RxDelay    = B.SkipSamples / B.RxFreq;

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Additional parameters

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
B.RxFreq      = 4 * B.TxFreq; % sampling frequency [MHz]
B.RxBandwidth = 1;             % sampling mode (200%)
B.PRF         = 0;             % 0 = greatest possible PRF

% Estimate RxDelay for ultrafast acquisition
B.RxDelay = floor((1 - ImgInfo.CorrectFactorDepth) * ImgInfo.Depth(1) * 1e3 ...
    * B.RxFreq / common.constants.SoundSpeed) / B.RxFreq;

% Estimate RxDuration for ultrafast acquisition
B.RxDuration = ceil((1 + ImgInfo.CorrectFactorDepth) ...
    * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * (B.RxFreq / 2^(B.RxBandwidth - 1)) ...
    / (common.constants.SoundSpeed * 128)) * 128 ...
    / (B.RxFreq / 2^(B.RxBandwidth - 1));

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Create acquisition modes

try
    % Do not modify, this is used to ensure TrigIn Timeout functionnality
    E_Pause = elusev.pause( 'Pause', 5e-6 );
    E_Pause = E_Pause.setParam( 'SoftIrq', 1 );

    % Add the PAT acquisition mode
    clear AcmoList
    PATModeId = 2;
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
    BModeId = 1;
    AcmoList{BModeId} = acmo.bfoc(...
        'TwFreq',       B.TxFreq, ...
        'NbHcycle',     B.NbHcycle, ...
        'SteerAngle',   B.SteerAngle, ...
        'Focus',        B.Focus, ...
        'PRF',          0, ...
        'DutyCycle',    B.DutyCycle, ...
        'XOrigin',      B.XOrigin, ...
        'FirstLinePos', B.FirstLinePos,...
        'NbFocLines',   B.NbFocLines,...
        'TxLinePitch',  B.TxLinePitch,...
        'FDRatio',      B.FDRatio, ...
        'ApodFct',      B.ApodFct, ...
        'RxFreq',       B.RxFreq, ...
        'RxDuration',   B.RxDuration, ...
        'RxDelay',      B.RxDelay, ...
        'RxBandwidth',  B.RxBandwidth, ...
        'FIRBandwidth', B.FIRBandwidth, ...
        'PulseInv',     BImgInfo.pulseInversion, ...
        'TxPolarity',   BImgInfo.TxPolarity, ...
        'TxElemsPattern',B.TxElemsPattern, ...
        'ControlPts',   B.TGC, ...
        0);
    
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
    OrderingVector = repmat([ BModeId PATModeId ], 1, NbAcqTotal); % sequence order
    Sequence           = usse.usse( 'TPC',TPC, 'acmo',AcmoList, 'Ordering',OrderingVector, 'Popup',0 );
    %Sequence           = Sequence.selectProbe(); % comment if the probe did not change
    [Sequence NbAcqRx] = Sequence.buildRemote();

catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end

% return

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
        RF_buffer(k) = Sequence.getData('Realign',0);
    end

    % Stop sequence
    Sequence = Sequence.stopSequence('Wait', 1);
    datatransfertime = toc(idx_clock_datatransfer);
    disp(['Data transfer duration: ' num2str(datatransfertime) 's.']);

    % Data Size to transfer 2 Bytes per sample
    UploadedDataSizeMB = NbAcqTotal*(2*numel(RF_buffer(1).data)+numel(RF_buffer(2).data) * 2) / (1024 * 1024);
    disp(['Uploaded data size: ' num2str(UploadedDataSizeMB) 'MB.']);
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% ============================================================================ %

%% PAT image formation

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

%% Beamform selected buffers

idx_clock_PATBeamforming = tic;

clear BFStructPAT
clear IQPATMatrix
idxPATAcq = 0;

for idxRx = 1:NbAcqRx
    if OrderingVector(idxRx) == PATModeId
        idxPATAcq = idxPATAcq + 1
        idx_clock_PATBeamforming = tic;
        BFStructPAT = processing.lutPAT(Sequence,PATModeId,PATBfInfo,NThreads);
        BFStructPAT.Info.DebugMode = 0 ;
        BFStructPAT = processing.reconPat(BFStructPAT, RF_buffer(idxRx));
        PATBeamformingtime       = toc(idx_clock_PATBeamforming);
        disp(['idxPATAcq: ',num2str(idxPATAcq), '. PAT beamforming duration: ' num2str(PATBeamformingtime) 's.']);
        %IQPATMatrix(:,:,idxPATAcq) = mean(BFStructPAT.IQ(:,:,:),3);% we compute the mean over PAT.NbFrames
        idxAcq   =   idxPATAcq;
        IQPATMatrix(:,:,:,idxAcq) = BFStructPAT.IQ(:,:,:);
    end
end;




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

%% B image formation

%% Beamform selected buffers
idx_clock_BModeBeamforming = tic;
clear BFStruct
clear IQBMatrix
idxAcq = 0;
NThreads = 1;
for idxRx = 1:NbAcqRx
    if OrderingVector(idxRx) == BModeId
        idxAcq = idxAcq + 1;
        BFStruct = processing.lutBfoc( Sequence, BModeId, BImgInfo, NThreads );
        BFStruct.Info.DebugMode = 0 ;
        BFStruct = processing.reconBFoc( BFStruct, RF_buffer(idxRx) );
        IQBMatrix(:,:,idxAcq ) = BFStruct.IQ;
        BModeBeamformingtime = toc(idx_clock_BModeBeamforming);
        disp(['BMode beamforming duration: ' num2str(BModeBeamformingtime) 's.']);
    end
end

%%
% ============================================================================ %
% Compute X and Z scales
X = BImgInfo.XOrigin  + ( 0:(BImgInfo.nbTx * BImgInfo.RxLinesPerTx - 1) ) * ( system.probe.Pitch * BImgInfo.txPitch / BImgInfo.RxLinesPerTx ) ;
Z = BImgInfo.Depth(1) + ( 0:(BFStruct.Lut(1).NPixLine - 1 ) ) * 1e-3 * common.constants.SoundSpeed / (B.RxFreq/4) * BImgInfo.PitchPix ;

% ============================================================================ %


%Time Sequence of images
FigurePAT = 3;
FigureB = 4;


% Read Frame 1 in all Acquisitions

for idxAcq = 1:NbAcqTotal
    % Display k-th acq of PAT
    figure(FigurePAT);
    imagesc(PATXAxis, PATZAxis, 20 * log10(abs(IQPATMatrix(:,:,1,idxAcq))),[PAT.Threshold PAT.DynRangedB + PAT.Threshold]);
    title(['PAT Image, Acq Number = ',num2str(idxAcq)]);
    colormap(hot);
    % Display k-th acq of PAT
    figure(FigureB);
    imagesc(X, Z, 20 * log10(abs(IQBMatrix(:,:,idxAcq))),[B.Threshold B.Threshold + B.DynRangedB]);
    colormap(gray);
    title(['B Image, Acq Number = ',num2str(idxAcq)]);
    pause(1);
end;

% Read Frames in a given Acquisition
% idxAcq = 1;
% for idxFr = 1:PAT.NbFrames
%     % Display k-th acq of PAT
%     figure(FigurePAT);
%     imagesc(PATXAxis, PATZAxis, 20 * log10(abs(IQPATMatrix(:,:,idxFr,idxAcq))),[PAT.Threshold PAT.DynRangedB + PAT.Threshold]);
%     title(['PAT Image, Acq Number = ',num2str(idxAcq), '; Frame Number = ',num2str(idxFr)]);
%     colormap(hot);
%     % Display k-th acq of PAT
%     figure(FigureB);
%     imagesc(X, Z, 20 * log10(abs(IQBMatrix(:,:,idxAcq))),[B.Threshold B.Threshold + B.DynRangedB]);
%     colormap(gray);
%     title(['B Image, Acq Number = ',num2str(idxAcq)]);
%     pause(1);
% end;





TimeElapsed = toc(idx_clock_sequence)
