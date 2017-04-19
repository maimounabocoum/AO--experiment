% TEST.ULTRACOLOR (PUBLIC)
%   Build and run a sequence with ultrafast color Doppler acquisitions
%
%   Note - This function is defined as a script of TEST package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/16

%% Clear everything

clear all;
close all;
clc;

% ============================================================================ %
% ============================================================================ %

%% Sequence parameters

% System parameters
IPaddress = '192.168.1.166'; % IP address of Aixplorer
ImgVoltage = 40;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]

% ============================================================================ %

% Image info
ImgInfo.LinePitch = .5;  % dx / PiezoPitch
ImgInfo.PitchPix  = .5;  % dz / lambda
ImgInfo.Depth(1)  = 1;   % initial depth [mm]
ImgInfo.Depth(2)  = 40;  % final depth [mm]
ImgInfo.RxApod(1) = 0.5; % RxApodOne
ImgInfo.RxApod(2) = 0.7; % RxApodZero

% ============================================================================ %

% Emission
TwFreq     = 7.5;       % MHz
NbHcycle   = 4;         %
ApodFct    = 'none';    %
DutyCycle  = 1;         %
TxCenter   = 30;        % mm
TxWidth    = 60;        % mm
FlatAngles = 0;  % deg

% ============================================================================ %

% Acquisition
RxFreq       = 4 * TwFreq; % MHz
RxCenter     = 1;          % mm
RxWidth      = 1;          % mm - no synthetic acquisition
RxBandwidth  = 2;          % 1 = 200%, 2 = 100%
EnsLength    = 2;          % # of repeated block
AngleRepFreq = 0;      % Hz
PRF          = 3000;       % Hz
FrameRate    = 0;        % Hz

% ============================================================================ %

% Sequence execution
NbLocalBuffer = 3; % # of local buffer
NbHostBuffer  = 1; % # of host buffer
NbRun         = 1; % # of sequence executions
RepeatElusev  = 1; % # of acmo repetition before dma

% ============================================================================ %

% DO NOT CHANGE - Estimate dedicated variables for UltraColor
NumSamples   = ceil(1.4 * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
     * RxFreq / (common.constants.SoundSpeed * 2^(RxBandwidth-1) * 128)) * 128;
SkipSamples  = floor(0.6 * ImgInfo.Depth(1) * RxFreq * 1e3 ...
    / common.constants.SoundSpeed);

% DO NOT CHANGE - Estimate dedicated variables for Ultrafast
RxDuration = NumSamples / RxFreq * 2^(RxBandwidth-1);
RxDelay    = SkipSamples / RxFreq;

% ============================================================================ %
% ============================================================================ %

%% Build the sequence

try
    clc
% ============================================================================ %

% UltraColor ACMO
ACMO{1} = acmo.ultracolor( ...
    'TwFreq', TwFreq, ... 
    'NbHcycle', NbHcycle, ...
    'ApodFct', ApodFct, ...
    'DutyCycle', DutyCycle, ...
    'TxCenter', TxCenter, ...
    'TxWidth', TxWidth, ...
    'FlatAngles', FlatAngles, ...
    'RxFreq', RxFreq, ...
    'RxCenter', RxCenter, ...
    'RxWidth', RxWidth, ...
    'NumSamples', NumSamples, ...
    'SkipSamples', SkipSamples, ...
    'RxBandwidth', RxBandwidth, ...
    'FIRBandwidth', 100, ...
    'EnsLength', EnsLength, ...
    'AngleRepFreq', AngleRepFreq, ...
    'PRF', PRF, ...
    'FrameRate', FrameRate, ...
    'TrigIn', 0, ...
    'TrigOut', 0, ...
    'TrigOutDelay', 0, ...
    'TrigAll', 0, ...
    'ControlPts', 900, ...
    'Repeat', NbLocalBuffer * 2, ...
    'NbLocalBuffer', NbLocalBuffer, ...
    'NbHostBuffer', NbHostBuffer, ...
    'RepeatElusev', RepeatElusev, ...
    0);

% ============================================================================ %

% Create sequence
TPC = remote.tpc( ...
    'imgvoltage', ImgVoltage, ...
    'imgcurrent', ImgCurrent, ...
    0);
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'ACMO', ACMO, ...
    'Repeat', NbRun, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

% ============================================================================ %

% Build the REMOTE structure
[SEQ NbAcq] = SEQ.buildRemote();

% ============================================================================ %

catch exception
    errordlg(exception.message, exception.identifier);
end

% ============================================================================ %
% ============================================================================ %

%% Sequence execution

try
    
% ============================================================================ %

% Initialize & load sequence remote
SEQ = SEQ.initializeRemote('IPaddress', IPaddress);
SEQ = SEQ.loadSequence();

% Start sequence
clear buffer;
SEQ = SEQ.startSequence();

% Retrieve data
for m = 1 : NbRun
    for n = 1 : NbAcq
        
        buffer(n, m) = SEQ.getData('Realign', 0);
        
    end
end

% Stop sequence
SEQ = SEQ.stopSequence('Wait', 1);

% ============================================================================ %

%% Beamforming

% Loop over all buffers
for m = 1 : NbRun
    for n = 1 : NbAcq
        
%         Img{n + (m-1) * NbAcq} = ...
%             BFscript.BeamFormingFlat(SEQ, buffer(n, m), ImgInfo);
        Img{n + (m-1) * NbAcq} = ...
            BeamFormingFlat_MultiN(SEQ, buffer(n, m), ImgInfo, 12);
        
    end
end

% ============================================================================ %

% Build continuous image set
IQ = single(zeros(size(Img{1}, 1), size(Img{1}, 2), length(Img) * size(Img{1}, 3)));
for k = 1 : length(Img)
    
    IQ(:,:, (1:size(Img{k}, 3)) + (k-1) * size(Img{1}, 3)) = single(Img{k});
    
end

% ============================================================================ %

catch exception
    errordlg(exception.message, exception.identifier);
end

% ============================================================================ %
% ============================================================================ %

%% Processing color

% Display variables
R0RefValue      = 3e9; % 692407872 - gel value
R0CompressiondB = 20;

% Color mask variables
WallFiltrType          = 1;    % 1 = Butterworth, 2 = Bessel, 3 = polynomial, 4 = identity
WallFiltrOrder         = 3;    % filter order
WallFiltrCutOff        = 0.23; % reduced frequency cutoff (relative to the PRF)
WallFiltrStopBandAtten = 30;   %

% Generate wall filter
WallFiltr = processing.GenerateWallFilter(WallFiltrType, WallFiltrOrder, ...
    WallFiltrCutOff, WallFiltrStopBandAtten, 30);

% Process Doppler acquisitions
[WFIQ R0 R1] = processing.ColorProcessing(IQ, WallFiltr, R0RefValue, ...
    R0CompressiondB);

%% Matlab processing (need more memory)

% Apply filter
Size  = size(Img);
WfImg = WallFiltr * reshape(permute(Img, [3 1 2]), EnsLength, []);

% Build the R0 map
R0        = sum(abs(WfImg).^2) ./ EnsLength;
R0        = min(max(10 * log10(R0 / R0RefValue), 0), R0CompressiondB);

% Build the R1 map
R1 = 1 / (EnsLength - 1) ...
    * sum(conj(WfImg(2:EnsLength, :)) .* WfImg(1:(EnsLength-1), :));
R1 = R1 .* (R0 > 0);

% Reshape images
WfImg = permute(reshape(WfImg, Size(3), Size(1), Size(2)), [2 3 1]);
R0    = permute(reshape(R0, Size(3) / EnsLength, Size(1), Size(2)), [2 3 1]);
R1    = permute(reshape(R1, Size(3) / EnsLength, Size(1), Size(2)), [2 3 1]);

%% Display images

% Initialize images
figure(1);
subplot(2,2,1);
ImgAxes1 = gca; set(ImgAxes1, 'Units', 'pixels', 'Color', 'black', ...
    'XColor', 'white', 'YColor', 'white', 'XAxisLocation', 'top', ...
    'YAxisLocation', 'right', 'YDir', 'reverse', 'Layer', 'top', ...
    'DataAspectRatioMode', 'manual', 'PlotBoxAspectRatioMode', 'manual', ...
    'CLimMode', 'manual', 'ALimMode', 'manual', 'DrawMode', 'fast', ...
    'SelectionHighlight', 'off', 'XLim', [0 size(IQ, 2)], ...
    'YLim', [0 size(IQ, 1)]);
Img1 = image('Parent', ImgAxes1, 'CDataMapping', 'direct', 'EraseMode', 'none');
subplot(2,2,2);
ImgAxes2 = gca; set(ImgAxes2, 'Units', 'pixels', 'Color', 'black', ...
    'XColor', 'white', 'YColor', 'white', 'XAxisLocation', 'top', ...
    'YAxisLocation', 'right', 'YDir', 'reverse', 'Layer', 'top', ...
    'DataAspectRatioMode', 'manual', 'PlotBoxAspectRatioMode', 'manual', ...
    'CLimMode', 'manual', 'ALimMode', 'manual', 'DrawMode', 'fast', ...
    'SelectionHighlight', 'off', 'XLim', [0 size(WFIQ, 2)], ...
    'YLim', [0 size(WFIQ, 1)]);
Img2 = image('Parent', ImgAxes2, 'CDataMapping', 'direct', 'EraseMode', 'none');
subplot(2,2,3);
ImgAxes3 = gca; set(ImgAxes3, 'Units', 'pixels', 'Color', 'black', ...
    'XColor', 'white', 'YColor', 'white', 'XAxisLocation', 'top', ...
    'YAxisLocation', 'right', 'YDir', 'reverse', 'Layer', 'top', ...
    'DataAspectRatioMode', 'manual', 'PlotBoxAspectRatioMode', 'manual', ...
    'CLimMode', 'manual', 'ALimMode', 'manual', 'DrawMode', 'fast', ...
    'SelectionHighlight', 'off', 'XLim', [0 size(R0, 2)], ...
    'YLim', [0 size(R0, 1)]);
Img3 = image('Parent', ImgAxes3, 'CDataMapping', 'direct', 'EraseMode', 'none');
subplot(2,2,4);
ImgAxes4 = gca; set(ImgAxes4, 'Units', 'pixels', 'Color', 'black', ...
    'XColor', 'white', 'YColor', 'white', 'XAxisLocation', 'top', ...
    'YAxisLocation', 'right', 'YDir', 'reverse', 'Layer', 'top', ...
    'DataAspectRatioMode', 'manual', 'PlotBoxAspectRatioMode', 'manual', ...
    'CLimMode', 'manual', 'ALimMode', 'manual', 'DrawMode', 'fast', ...
    'SelectionHighlight', 'off', 'XLim', [0 size(R1, 2)], ...
    'YLim', [0 size(R1, 1)]);
Img4 = image('Parent', ImgAxes4, 'CDataMapping', 'direct', 'EraseMode', 'none');
DispImg = zeros([size(WFIQ(:,:,1)), 3], 'uint8');
set(Img1, 'CData', DispImg);
set(Img2, 'CData', DispImg);
set(Img3, 'CData', DispImg);
set(Img4, 'CData', DispImg);
TmpImg  = 20 * log10(abs(IQ));
TmpWFIQ = 20 * log10(abs(WFIQ));
CBarGray  = processing.BuildColorMap('gray');
CBarPower = processing.BuildColorMap('hot');
CBarColor = processing.BuildColorMap('ColorDoppler');

%% Display loop
for k = 1 : size(WFIQ, 3)
    
    [DispImg(:,:,1) DispImg(:,:,2) DispImg(:,:,3)] = processing.matrgb( ...
        TmpImg(:,:,k), CBarGray, single([140 200]));
    set(Img1, 'CData', DispImg);
    set(ImgAxes1, 'Layer', 'top');

    [DispImg(:,:,1) DispImg(:,:,2) DispImg(:,:,3)] = processing.matrgb( ...
        TmpWFIQ(:,:,k), CBarGray, single([75 125]));
    set(Img2, 'CData', DispImg);
    set(ImgAxes2, 'Layer', 'top');

    if ( mod(k, EnsLength) == 0 )
        Idx = k / EnsLength;
        
        [DispImg(:,:,1) DispImg(:,:,2) DispImg(:,:,3)] = ...
            processing.matrgb(R0(:,:,Idx), CBarPower, single([0 R0CompressiondB]));
        set(Img3, 'CData', DispImg);
        set(ImgAxes3, 'Layer', 'top');
        
        [DispImg(:,:,1) DispImg(:,:,2) DispImg(:,:,3)] = ...
            processing.matrgb(angle(R1(:,:,Idx)), CBarColor, single([-pi pi]));
        set(Img4, 'CData', DispImg);
        set(ImgAxes4, 'Layer', 'top');
    end
    
    pause(.1);
    
end
