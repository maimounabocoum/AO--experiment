% clear all ; clear classes ;

% Sequence = usse.usse; Sequence = Sequence.selectProbe

% general parameters
modeRF = 0 ;
NThreads = 1;

IPaddress = '192.168.1.16'; % IP address of Aixplorer

FrameRate  = 5;  % frequency of sequence repetition Hz
repetition = 1 ;   % repeat sequence [1 inf]

% Voltage parameters
ImgVoltage  = 20;             % imaging voltage 0V]
ImgCurrent  = 0.1;            % security limit for imaging current [A]
PushVoltage = 10;             % imaging voltage [V]
PushCurrent = 5;              % security limit for imaging current [A]

% Image info
ImgInfo.TxPolarity     = [ 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
ImgInfo.TxElemsPattern = [ 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
ImgInfo.SteeringAngle  = 0; % steering angle [not implemented yet]
ImgInfo.XOrigin        = 0 ; % xmin [mm]
ImgInfo.FirstLinePos   = 1 ; % position of the first line in elt [>=1]
ImgInfo.txPitch        = 10 ; % txpitch [elements] : entire value corresponding to constant spacing (min = 1)
ImgInfo.nbTx           = 10 ; % txpitch [elements] 128 number of element shooting from element 1
ImgInfo.RxLinesPerTx   = 2;  % number of received line per tx (beamforming)
ImgInfo.PitchPix       = 0.5;  % dz / lambda
ImgInfo.Depth(1)       = 0;   % initial depth [mm]
ImgInfo.Depth(2)       = 40;  % final depth [mm]
ImgInfo.RxApod(1)      = 0.4; % RxApodOne
ImgInfo.RxApod(2)      = 0.6; % RxApodZero

ImgInfo.pulseInversion = length( unique( ImgInfo.TxPolarity ) ) - 1 ;

% Emission parameters
TwFreq          = 6/(1+ImgInfo.pulseInversion);      % transmit frequency [MHz]
NbHcycle        = 8;         % nb tx half cycle
ApodFct         = 'none';    % Apod function on the transmit aperture
TxFDRatio       = 3.5;       % F/D ratio (transmit)
DutyCycle       = 1;         % tx Duty cycle [0-1]
Focus           = 25 ;       % focal depth [mm]

% ============================================================================ %

% Receive parameters
RxBandwidth  = 2;          % 1 = 200%, 2 = 100%
RxFilterBandwidth = 90 ;
TGC = [1 400 600 600 600 600];

%% converting ImgInfo parameters into acmo parameters

RxFreq       = 4 * TwFreq * (1+ImgInfo.pulseInversion); % MHz

NumSamples   = ceil(1.4 * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * RxFreq / (common.constants.SoundSpeed * 2^(RxBandwidth-1) * 128)) * 128;
SkipSamples  = floor(0. * ImgInfo.Depth(1) * RxFreq * 1e3 ...
    / common.constants.SoundSpeed);

RxDuration = NumSamples / RxFreq * 2^(RxBandwidth-1);
RxDelay    = SkipSamples / RxFreq;

%% built sequence

Acmo = acmo.bfoc( ...
    'TwFreq',       TwFreq, ...
    'NbHcycle',     NbHcycle, ...
    'SteerAngle',   ImgInfo.SteeringAngle, ...
    'Focus',        Focus, ...
    'PRF',          FrameRate, ...
    'DutyCycle',    1, ...
    'XOrigin',      ImgInfo.XOrigin, ...
    'FirstLinePos', ImgInfo.FirstLinePos,...
    'NbFocLines',   ImgInfo.nbTx,...
    'TxLinePitch',  ImgInfo.txPitch,...
    'FDRatio',      TxFDRatio, ...
    'ApodFct',      'none', ...
    'RxFreq',       RxFreq, ...
    'RxDuration',   RxDuration, ...
    'RxDelay',      RxDelay, ...
    'RxBandwidth',  RxBandwidth, ...
    'FIRBandwidth', RxFilterBandwidth, ...
    'PulseInv',     ImgInfo.pulseInversion, ...
    'TxPolarity',   ImgInfo.TxPolarity, ...
    'TxElemsPattern', ImgInfo.TxElemsPattern, ...
    'ControlPts',   TGC, ...
    'TrigOut',      50, ... 
    'TrigAll',      1, ...%
    0);

TPC = remote.tpc( ...
    'imgVoltage',   ImgVoltage, ...
    'imgCurrent',   ImgCurrent, ...
    'pushVoltage',  PushVoltage, ...
    'pushCurrent',  PushCurrent, ...
    0);

% add a bfoc acmo and built the sequence
Sequence = usse.usse( 'acmo',Acmo, 'TPC',TPC, 'Popup',0 );
Sequence = Sequence.setParam( 'Repeat',repetition, 'DropFrames', 0 );

[Sequence NbAcq] = Sequence.buildRemote;

%% built beamforming luts if needed
if ~modeRF
    disp('LUT computation');
    BFStruct = processing.lutBfoc( Sequence, 1 , ImgInfo, NThreads );
    if system.probe.Radius > 0
        Data = processing.lutScanConvertImage( BFStruct, ImgInfo, 1024, 1024 ); % TODO: remove hardcoded size
    end
end

% clear buffer if necessary
clear buffer;

BFStruct.Info.DebugMode = 2 ;

%   Initialize & load sequence remote
Sequence = Sequence.initializeRemote( 'IPaddress',IPaddress, 'InitSequence',1 );
Sequence = Sequence.loadSequence();

% Start sequence
disp('start');
Sequence = Sequence.startSequence();

for k=1:repetition
    disp('Getting buffer');

    if modeRF
        buf = Sequence.getData('Realign', 1);
    else
        buf = Sequence.getData('Realign', 2, 'Timeout',120 );

        % Stop sequence
        disp('reconstruction');

        BFStruct = processing.reconBFoc( BFStruct, buf );

        if system.probe.Radius > 0
            Data = processing.ScanConvertImage( Data, BFStruct.IQ );
            img = Data.img ;
            X = Data.XAxis;
            Z = Data.ZAxis;
        else
            X = ImgInfo.XOrigin  + ( 0:(ImgInfo.nbTx * ImgInfo.RxLinesPerTx - 1) ) * ( system.probe.Pitch * ImgInfo.txPitch / ImgInfo.RxLinesPerTx ) ;
            Z = ImgInfo.Depth(1) + ( 0:(BFStruct.Lut(1).NPixLine - 1 ) ) * 1e-3 * common.constants.SoundSpeed / (RxFreq/4) * ImgInfo.PitchPix ;
            img = 20*log10( abs( BFStruct.IQ ) );
        end

        figure(1);
        imagesc(X,Z,img(:,:,1));

        axis equal ;
        axis tight ;
        caxis ([70 140]);

        colormap gray ;
        drawnow ;
        
    end

end
Sequence = Sequence.stopSequence('Wait', 0);

return

if modeRF && ImgInfo.pulseInversion
    ch = size( buffer.data, 2) / 2;
    win_sample = 1:1000;
    acq_offset = 128;

    display_range = [-1 1]*800;

    figure; imagesc( squeeze( buffer.data(:,:,acq_offset) ) ); caxis( display_range )

    A = squeeze( buffer.data(win_sample,ch,acq_offset+1) ); 
    B = squeeze( buffer.data(win_sample,ch,acq_offset+2) );
    C = A+B;

    figure
    plot( [ A B C ] ); ylim( display_range )

    figure; spectrogram(double(A), 128,[],[], RxFreq ); caxis auto; the_caxis = caxis;
    figure; spectrogram(double(C), 128,[],[], RxFreq ); caxis( the_caxis )
end

