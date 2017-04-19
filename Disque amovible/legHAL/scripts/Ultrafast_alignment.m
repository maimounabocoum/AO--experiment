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
close all

% System parameters
AixplorerIP    = '192.168.3.182'; % IP address of the Aixplorer device

% Select probe
probe = 'SPA5_1'


ImagingVoltage = 15;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Image parameters
clear ImgInfo

ImgInfo.NbColumnsPerPiezo  = 1;
ImgInfo.NbRowsPerLambda    = 1;

if (strcmp(probe, 'SL15_4') == 1)
    ImgInfo.Depth(1)           = 2; % initial depth [mm]
    ImgInfo.Depth(2) = 30;  % image depth [mm]
elseif (strcmp(probe, 'SPA5_1') == 1)
    ImgInfo.Depth(1) = 70; % initial depth [mm]
    ImgInfo.Depth(2) = 100;  % image depth [mm]
else
    disp([probe ' probe not supported yet']);
end

% ============================================================================ %

% Ultrafast acquisition parameters
clear UF

UF.TxPolarity     = [ 1 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
UF.TxElemsPattern = [ 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements

SoundSpeed = 1480;
if (strcmp(probe, 'SL15_4') == 1)
    NPiezos   = 256;
    UF.TwFreq = 9; % emission frequency [MHz]
    piezoPitch = 0.2;
elseif (strcmp(probe, 'SPA5_1') == 1)
    NPiezos   = 96;
    UF.TwFreq = 9 ; % emission frequency [MHz]
    piezoPitch = 0.2;
else
    disp([probe ' probe not supported yet']);
end


UF.NbHcycle     = 1;               % # of half cycles
UF.FlatAngles   = 0;               % flat angles [deg]
UF.DutyCycle    = 1;               % duty cycle [0, 1]
UF.TxCenter     = piezoPitch*NPiezos/2;            % emission center [mm]
UF.TxWidth      = piezoPitch*NPiezos;            % emission width [mm]
UF.ApodFct      = 'none';          % emission apodization function (none, hanning)
UF.RxCenter     = UF.TxCenter;     % reception center [mm]
UF.RxWidth      = UF.TxWidth;      % reception width [mm]
UF.RxBandwidth  = 1;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
UF.FIRBandwidth = -1;              % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
UF.NbFrames     = 1;               % # of acquired images
UF.PRF          = 1000;            % pulse frequency repetition [Hz], between 2 different flats images (0 for greatest possible)
UF.FrameRateUF  = 40;
UF.FrameRate    = 3;
UF.TGC          = 300 * ones(1,8); % TGC profile
UF.TrigIn       = 0 ;
UF.TrigOut      = 0 ;
UF.TrigAll      = 0 ;
UF.Repeat       = 1 ; % Repeat of the whole acquisition + transfer
UF.NbLocalBuffer= 2 ;
UF.NbHostBuffer = 2 ;

% ============================================================================ %
%% DO NOT CHANGE - Additional parameters

% Additional parameters for ultrafast acquisition
UF.RxFreq = 4 * UF.TwFreq; % sampling frequency [MHz]

% Estimate RxDelay for ultrafast acquisition
UF.RxDelay = .75 * ImgInfo.Depth(1) * 1e3 / common.constants.SoundSpeed ;

% Estimate RxDuration for ultrafast acquisition
transmitDistanceMax = ImgInfo.Depth(2)/cosd( max(abs(UF.FlatAngles)) ) + sind( max(abs(UF.FlatAngles)) ) * UF.RxWidth;
returnDistanceMax = ImgInfo.Depth(2) * sind( max(abs(UF.FlatAngles)) ) + UF.RxWidth ;
returnDistanceMax = sqrt( returnDistanceMax^2 + ImgInfo.Depth(2)^2 ) ;
UF.RxDuration = (transmitDistanceMax + returnDistanceMax) / common.constants.SoundSpeed *1e3 + 4/UF.RxFreq;

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

    Sequence = usse.usse( 'TPC',TPC, 'acmo',AcmoList, 'Popup',0 );

    % Sequence = Sequence.selectProbe();
    [Sequence NbAcqRx] = Sequence.buildRemote();

catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return

end

%% Do NOT CHANGE - Sequence execution
try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress',AixplorerIP, 'InitTGC',UF.TGC, 'InitRxFreq',UF.RxFreq, 'InitSequence',1 );

    % Load sequence
    Sequence = Sequence.loadSequence();
    
    b = 0;
    vmax=0;
    pressedKey ='';
    figureHandle = figure();

    while ~strcmpi(pressedKey, 'q');
        pressedKey = get(figureHandle,'CurrentCharacter');
        if strcmpi(pressedKey, ' ');
            k = waitforbuttonpress;
        end
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
        
        % Get RF data
        rfMatrix = mean(buf.RFdata(200:end-128,:,:),3);
        rfMatrix = rfMatrix(:,1:NPiezos);
        % Get per element max amplitude and position to estimate
        % the times of propagation
        [maxP,absP] = max(abs(hilbert(rfMatrix)),[],1);
        posmax = absP;
        
        % Get maximum maximorum position
        u = find(maxP>max(maxP)/2); 
        absP =absP(u);
        absP= absP/UF.RxFreq;  % propagation time in µs
        
        % Center propagation times vector
        absP = absP-mean(absP);
        
        if length(absP) > 1
            % Fit a straight line on propagation times
            p = polyfit(1:length(absP),absP,1); 
            y = polyval(p,1:length(absP));
            central_line = rfMatrix(:,end/2);
            central_lineenv =  abs(hilbert(central_line));
            v = min(find(central_lineenv == max((central_lineenv))));
            envRfMatrix = abs(hilbert(rfMatrix));
            avgMax = mean(max(envRfMatrix));

            if b<avgMax
                vmax = v;
            end
            b = max(b,avgMax);
            if(UF.RxBandwidth==1)
                distancePulseInMm = (Sequence.InfoStruct.event(1).skipSamples + v)/UF.RxFreq*(SoundSpeed/1000)/2;
            elseif(UF.RxBandwidth==2)
                distancePulseInMm = -1;
            else
                distancePulseInMm = -1;
            end
            figure (1)
            plot(y*1000);
            power10 = max(0,round(log10(max(abs(y*1000)))));
            ylim([-10^power10 +10^power10])
            title(['Value: '  num2str(avgMax) ' /  Max value: ' num2str(b) ' / distance: ' num2str(distancePulseInMm) 'mm'],'FontSize',14); 
            drawnow; 
            ylabel('ns');
            
            figure(2);
            imagesc(rfMatrix);
            caxis([-1 1]*1e4);
            hold on;
            plot(1:size(rfMatrix,2),posmax,'o');
            hold off;
            ylim([mean(posmax)-200 mean(posmax)+200])
            drawnow;
      
            
        end;
        pause(.1)
    end
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
    return
end