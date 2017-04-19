clear all ; clear classes ;

% general parameters
modeRF = 0 ;
debugMode =0 ; % 0 = real acquisition, 1 = fake RF data
NThreads = 2;
IPaddress = '192.168.1.78'; % IP address of Aixplorer
FrameRate    = 2;         % Hz
repetition = 1 ; % repeat sequence [1 inf]

% Voltage parameters
ImgVoltage = 50;             % imaging voltage 0V]
ImgCurrent = 0.1;            % security limit for imaging current [A]
PushVoltage = 10;             % imaging voltage [V]
PushCurrent = 5;            % security limit for imaging current [A]

% Emission parameters
TwFreq          = 2.8125;       % transmit frequency [MHz]
NbHcycle        = 2;         % nb tx half cycle
ApodFct         = 'none';    % Apod function on the transmit aperture
TxFDRatio       = 1;         % F/D ratio (transmit)
DutyCycle       = 1;         % tx Duty cycle [0-1]
% ============================================================================ %

% Receive parameters
RxBandwidth  = 2;          % 1 = 200%, 2 = 100%
RxFilterBandwidth = 90 ;
TGC = [400 500 600 700 800 900];

% Image info
ImgInfo.Focus = 80 ;       % focal depth [mm]
ImgInfo.SteeringAngleStart   = -40; % steering angle [not implemented yet]
ImgInfo.txPitch =1 ; % [deg]
ImgInfo.nbTx = 80 ; % txpitch [elements]
ImgInfo.RxLinesPerTx = 1;  % number of received line per tx (beamborming)
ImgInfo.PitchPix  = 0.5;  % dz / lambda
ImgInfo.Depth(1)  = 20;   % initial depth [mm]
ImgInfo.Depth(2)  = 180;  % final depth [mm]
ImgInfo.RxApod(1) = 0.4; % RxApodOne
ImgInfo.RxApod(2) = 0.6; % RxApodZero
ImgInfo.xApex =   system.probe.Pitch*system.probe.NbElemts/2 ;
ImgInfo.zApex =   8 ;

%% converting ImgInfo parameters into acmo parameters

RxFreq       = 4 * TwFreq; % MHz
NumSamples   = ceil(1.4 * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * RxFreq / (common.constants.SoundSpeed * 2^(RxBandwidth-1) * 128)) * 128;
SkipSamples  = floor(0. * ImgInfo.Depth(1) * RxFreq * 1e3 ...
    / common.constants.SoundSpeed);

RxDuration = NumSamples / RxFreq * 2^(RxBandwidth-1);
RxDelay    = SkipSamples / RxFreq;

%% built sequence

Acmo = acmo.bfocPhased(...
    'TwFreq',TwFreq, ...
    'NbHcycle',NbHcycle, ...
    'SteerAngleStart',ImgInfo.SteeringAngleStart, ...
    'Focus',ImgInfo.Focus, ...
    'PRF',FrameRate, ...
    'DutyCycle',1, ...
    'xApex',ImgInfo.xApex, ...
    'zApex',ImgInfo.zApex, ...
    'nbFocLines',ImgInfo.nbTx,...
    'TxLinePitch',ImgInfo.txPitch,...
    'ApodFct','none', ...
    'RxFreq',RxFreq, ...
    'RxDuration',RxDuration, ...
    'RxDelay',RxDelay, ...
    'RxBandwidth',RxBandwidth, ...
    'FIRBandwidth',RxFilterBandwidth, ...
    'PulseInv',0, ...
    'ControlPts',   TGC, ...
    0);

TPC = remote.tpc( ...
    'imgVoltage', ImgVoltage, ...
    'imgCurrent', ImgCurrent, ...
    'pushVoltage', PushVoltage, ...
    'pushCurrent', PushCurrent, ...
    0);

% add a bfoc acmo and built the sequence
bfocId = 1;
BfocSeq = usse.usse('acmo',Acmo,'TPC',TPC);
BfocSeq = BfocSeq.setParam('Repeat',repetition,'DropFrames',0);
tic
[BfocSeq NbAcq] = BfocSeq.buildRemote;
toc
% built beamforming luts

if(debugMode)
    
else
    %   Initialize & load sequence remote
    BfocSeq = BfocSeq.initializeRemote('IPaddress', IPaddress);
    BfocSeq = BfocSeq.loadSequence();
    
    % Start sequence
    disp('start');
    BfocSeq = BfocSeq.startSequence();
    
    for k=1:repetition
        disp('buffer');
        
        if(modeRF)
            buffer=BfocSeq.getData('Realign', 1);
        else
            buffer=BfocSeq.getData('Realign', 0);
            
            % Stop sequence
            %%
           
            NbReconTot = ImgInfo.nbTx;
            SteeringAngle = (ImgInfo.SteeringAngleStart + ImgInfo.txPitch*(0:(NbReconTot-1)))*pi/180;
            xOrigin = (ImgInfo.xApex + ImgInfo.zApex*tan(SteeringAngle))/0.28;
            clear bfStruct
            bfStruct.fNumber = 1.5;
            bfStruct.speedOfSound = 1540;
            bfStruct.piezoPitch = system.probe.Pitch*1e-3;
            bfStruct.demodFreq = TwFreq*1e6;
            bfStruct.rOrigin = ( ImgInfo.zApex+ImgInfo.Depth(1))*1e-3;
            bfStruct.peakDelay = 0;
            bfStruct.firstFiringAngle = ImgInfo.SteeringAngleStart*pi/180;
            bfStruct.firingAnglePitch = ImgInfo.txPitch*pi/180;
            bfStruct.lambda = bfStruct.speedOfSound/bfStruct.demodFreq;
            bfStruct.pixelPitch = bfStruct.lambda/2;
            bfStruct.nbPiezos = system.probe.NbElemts;
            bfStruct.firstSample = BfocSeq.RemoteStruct.event(1).skipSamples;
            bfStruct.nbSamples = BfocSeq.RemoteStruct.event(1).numSamples;
            bfStruct.nbLinesPerRecon = 2;
            bfStruct.linePitch = bfStruct.firingAnglePitch/bfStruct.nbLinesPerRecon;
            bfStruct.thetaOrigin = bfStruct.nbLinesPerRecon*bfStruct.linePitch/2;
            bfStruct.nbPixelsPerLine = (ImgInfo.Depth(2) - ImgInfo.Depth(1))*1e-3/bfStruct.pixelPitch ;
            bfStruct.nbRecon = ImgInfo.nbTx;
            bfStruct.normMode=1;
            bfStruct.synthAcq = 0;
            bfStruct.frame_per_frame = 0;
            bfStruct.zApex = ImgInfo.zApex*1e-3;
            bfStruct.usegpu = 1 ;
            for t=1:NbReconTot
                delays = BfocSeq.InfoStruct.tx(t).Delays;
                bfStruct.timeOrigin(t)  = double(interp1((1:bfStruct.nbPiezos)+0.5,delays(1:bfStruct.nbPiezos),xOrigin(t),'cubic')*1e-6);
            end
            bfStruct.channelOffset = BfocSeq.InfoStruct.mode(1).channelSize/2;
            cd ../remote/beamformerCuda/phasedFocused
            tic
            IQ = beamformerPhasedFocused(bfStruct,buffer.data,buffer.alignedOffset);
            toc
            img = abs(complex(IQ(1:2:end,:),IQ(2:2:end,:)));
            cd ../../../src
            
            parameters.NR = size(img,1);
            parameters.NTheta = size(img,2);
            
            parameters.Nx = 512;
            parameters.Nz = 512;
            
            parameters.AngleOfFirstLine = ImgInfo.SteeringAngleStart/180*pi;
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
            tic
            processing.ScanConvertLin(LUT_coeff,LUT_X,LUT_Z,LUT_Vois1,LUT_Vois2,parameters.NbVois,lutsize,single(img'),OUT);
            toc
            figure;
            imagesc(XAxis,ZAxis,20*log10(abs(OUT)'));
            axis equal;
            axis tight;
            caxis([10 60]);
            colormap gray;
            drawnow;
            
        end
        
    end
    BfocSeq = BfocSeq.stopSequence('Wait', 0);
end