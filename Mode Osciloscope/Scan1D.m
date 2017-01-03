function Scan1D
%% Script d'acquisition d'une image 1D avec la baie explorer
%% (lancé par AcoustoOptiqueGUI.m)
% Créé par Clément Dupuy le 21/01/15
% Dernière modification le 27/01/15 par JB

%% Definition of the plotting environment

hf2 = figure('Visible','off',...
    'units','normalized',...
    'NumberTitle','off',...
    'Name','Scan 1D',...
    'OuterPosition',[0,0,1,1],...
    'tag','hf2');

hp1D = uicontrol('Style', 'pushbutton',...
    'string', 'Stop',...
    'Fontsize',10,...
    'BackgroundColor','white',...
    'visible', 'off',...
    'units','normalized',...
    'Position',[0.9,0.95,0.1,0.05],...
    'callback',{@Stop},...
    'tag','hp1D',...
    'parent',hf2);

%%
% Chargement des paramètres et conversion en num
slog = load('log\log.mat');
slog = structfun(@convert2num,slog,'UniformOutput',0);

slogP = load('log\logParameters.mat');
slogP = structfun(@convert2num,slogP,'UniformOutput',0);

% Definitions des constantes
soundSpeed = 1480; % vitesse du son dans le milieu (m/s)
Date = datestr(date,29);

% Creation du fichier de sauvegarde
mkdir([slog.Path '\' Date '\'])

% Marqueur pour pouvoir arreter la'acquisition en cours de route
stp=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% DEBUT DU PROGRAMME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Definition des paramètres de la carte d'acquisition
SampleRate = 1e6*slogP.SampleRate; % Sample rate (Hz)

N_points = slogP.Averaging*SampleRate*slogP.AcqTime*1e-6;
tps = 0:1/SampleRate:(N_points/slogP.Averaging-1)/SampleRate; %vecteur temps (s)
y_position = tps*soundSpeed*10^3; % Vecteur position (mm)

switch slogP.Range
    case 1
        Range = '200m';
    case 2
        Range = '1';
end

% Selection du bon fichier task et définition du nombre de répetition US
switch slogP.Chan
    case 1
        DAQFileName = sprintf('multi-record_%imoy_sr%iMHz_%sV_%ius_par_ligne.tsk',...
            slogP.Averaging, slogP.SampleRate,Range,slogP.AcqTime);
        repeat = slogP.Averaging+1;
    case 2
        DAQFileName = sprintf('multi-record_2Voies_%imoy_sr%iMHz_%sV_%ius_par_ligne.tsk',...
            slogP.Averaging, slogP.SampleRate,Range,slogP.AcqTime);
        repeat = 2*slogP.Averaging+1;
end

dossierTask = 'C:\ADLINK\DAQPilot\Task Folder\';

% Verification de l'existence du fichier Task
if ~exist([dossierTask DAQFileName],'file')
    clear
    errordlg('ERREUR ! Aucun ficher task ne correspond aux paramètres définis');
    return
end

%% Security check
if slog.Freq==15 && slog.Volt>25
    slog.Volt=25;
    warning('Tension max dépassée ! Limite 25 V');
end

%% Creation du fichier de sauvegarde
if slog.sauvegarde==1
    
    n_scan=1;
    A=exist([slog.Path '\' Date '\' slog.Name '_' num2str(n_scan) '_ligne.mat'],'file');
    while A==2
        n_scan=n_scan+1;
        A=exist([slog.Path '\' Date '\' slog.Name '_' num2str(n_scan) '_ligne.mat'],'file');
    end
    clear A
    
    saveparam(1,n_scan);
    
end

%% Ouverture communication avec l'échographe
IPaddress = '192.168.1.20'; % IP address of Aixplorer

try
    srv = remoteDefineServer('extern',IPaddress,'9999');
catch exception
    errordlg(exception.message, exception.identifier)
    clear
    return
end

%% Ouverture communication avec la carte d'acquisition

%Create an analog output object. 0 stands for the first ADLINK device
%installed.
try
    ai_device = analoginput('mwadlink', 0);
    %Add channel#0 to ao_device object.
    ai_channel0 = addchannel(ai_device, 0);
    if slogP.Chan==2
        ai_channel1 = addchannel(ai_device, 1);
    end
    %Règle les paramètres d'acquisition à partir d'un task file
    set(ai_device,'DAQPilotFile',DAQFileName);
catch exception
    errordlg(exception.message, exception.identifier)
    clear
    return
end

% ============================================================================ %
% ============================================================================ %

%% Paramètres de la séquence US
% tension etc...
ImgVoltage = slog.Volt;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]
PushVoltage = 25;             % imaging voltage [V]
PushCurrent = 5;            % security limit for imaging current [A]

% ============================================================================ %

% Image info
ImgInfo.LinePitch = 1;  % dx / PiezoPitch
ImgInfo.PitchPix  = 0.5;  % dz / lambda
ImgInfo.Depth(1)  = 2;   % initial depth [mm]
ImgInfo.Depth(2)  = 20;  % final depth [mm]
ImgInfo.RxApod(1) = 0.4; % RxApodOne
ImgInfo.RxApod(2) = 0.6; % RxApodZero

% ============================================================================ %

% Emission
CP.TwFreq     = slog.Freq;       % MHz 15
CP.NbHcycle   = slog.Hemicycle;         %
CP.ApodFct    = 'none';    %
CP.DutyCycle  = 1;         %
CP.TxCenter   = 0;        % mm
CP.TxWidth    = slog.Foc/2;        % mm


CP.PosZ = slog.Foc; %mm

% ============================================================================ %

% Acquisition
CP.RxFreq       = 60; %4 * CP.TwFreq; % MHz
CP.RxCenter     = 0;          % mm
CP.RxWidth      = 32;          % mm - no synthetic acquisition
CP.RxBandwidth  = 2;          % 1 = 200%, 2 = 100%

% ============================================================================ %

% Sequence execution
NbLocalBuffer = 1; % # of local buffer
NbHostBuffer  = 1; % # of host buffer
NbRun         = 1; % # of sequence executions
RepeatElusev  = 1; % # of acmo repetition before dma

% ============================================================================ %

% DO NOT CHANGE - Estimate dedicated variables for UltraColor
NumSamples   = ceil(1.4 * (2 * ImgInfo.Depth(2) - ImgInfo.Depth(1)) * 1e3 ...
    * CP.RxFreq / (common.constants.SoundSpeed * 2^(CP.RxBandwidth-1) * 128)) * 128;
SkipSamples  = floor(0.6 * ImgInfo.Depth(1) * CP.RxFreq * 1e3 ...
    / common.constants.SoundSpeed);

% DO NOT CHANGE - Estimate dedicated variables for Ultrafast
CP.RxDuration = NumSamples / CP.RxFreq * 2^(CP.RxBandwidth-1);
CP.RxDelay    = SkipSamples / CP.RxFreq;

% ============================================================================ %
% ============================================================================ %

%% Build the sequence
% =========================================================================
% Initialize motors and move probe
motors=PolluxOpenAndInitialize(1);
command=sprintf('%.1f %d nm',slog.Z0,1);
fprintf(motors,command);
pause(10);
PolluxClose(motors,1);

CP.PosX =slog.X0;

FOCUSED = elusev.focused( ...
    'TwFreq', CP.TwFreq, ...
    'NbHcycle', CP.NbHcycle, ...
    'Polarity', 1, ...
    'SteerAngle', 0, ...
    'Focus', CP.PosZ, ...    %en mm
    'Pause', 50, ...       % Debut de la pause entre chaque tir (µs)
    'PauseEnd', CP.NbHcycle/(2*CP.TwFreq*0.002),... %200, ...       % Fin de la pause (µs)
    'DutyCycle', 1, ...
    'TxCenter', CP.PosX, ...
    'TxWidth', CP.TxWidth, ...
    'RxFreq', CP.RxFreq, ...
    'RxCenter', CP.RxCenter, ...
    'RxDuration', 8.5333, ...
    'RxDelay', 0, ...
    'RxBandwidth', 2, ...
    'FIRBandwidth', 0, ...
    'PulseInv', 0, ...
    'TrigOut', 50, ...%slogP.AcqTime , ...    %en µs
    'TrigAll', 0, ...
    'Repeat', repeat, ...
    'ApodFct', 'none', ...
    0);

% Acousto ACMO
ACOUSTO = acmo.acmo( ...
    'Repeat', 1, ...
    'Duration', 0, ...
    'ControlPts', 900, ...
    'fastTGC', 0, ...
    'NbLocalBuffer', 0, ...
    'NbHostBuffer', 1, ...
    'RepeatElusev', 1, ...
    0);

ACOUSTO = ACOUSTO.setParam('elusev',FOCUSED,'Ordering',[1]);

clear 'FOCUSED'

% ============================================================================ %

% Create sequence
TPC = remote.tpc( ...
    'imgVoltage', ImgVoltage, ...
    'imgCurrent', ImgCurrent, ...
    'pushVoltage', PushVoltage, ...
    'pushCurrent', PushCurrent, ...
    0);
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACOUSTO, ...
    'Repeat', NbRun, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

clear 'ACOUSTO'
clear 'TPC'
% ============================================================================ %

% Build the REMOTE structure
[SEQ NbAcq] = SEQ.buildRemote();

%% Sequence execution

% ============================================================================ %
% Initialize & load sequence remote
SEQ = SEQ.initializeRemote('IPaddress', IPaddress);
SEQ = SEQ.loadSequence();

% Start sequence
clear buffer;

%%   Mode oscilloscope pour scan d'une ligne
%Bornes des axes de visualisation

ligne_stack=zeros(N_points/slogP.Averaging,slog.Loops);

set(hf2,'visible','on')
set(hp1D,'visible','on')

for l=1:slog.Loops
    
    if stp
        clear
        return
    end
    
    ligne=zeros(N_points/slogP.Averaging,1);
    %%lancement acquisition
    start(ai_device);
    
    %%lancement sequence US
    SEQ = SEQ.startSequence();
    try
        wait(ai_device,20);
        
    catch exception
        errordlg(exception.message, exception.identifier)
        stop(ai_device);
        %%stop sequence US
        SEQ = SEQ.stopSequence('Wait', 1);
        flushdata(ai_device);
        
        if slog.sauvegarde==1
            save([slog.Path '\' Date '\' slog.Name '_' num2str(n_scan) '_ligne'],'y_position','ligne_stack')
            display('Données enregistrées');
        end
        
        clear
        return
    end
    data=getdata(ai_device);
    
    %%stop sequence US
    SEQ = SEQ.stopSequence('Wait', 1);
    flushdata(ai_device);
    
    
    %%traitement : decoupe du signal à chaque trig
    if slogP.Chan==1;
        for k=1:slogP.Averaging
            ligne=ligne+1/slogP.Averaging*data(1+(k-1)*N_points/slogP.Averaging:(k*N_points/slogP.Averaging),1);
        end
    else
        for k=1:slogP.Averaging
            ligne=ligne+1/slogP.Averaging*...
                data(1+(k-1)*N_points/slogP.Averaging:(k*N_points/slogP.Averaging),1)./...
                mean(data(1+(k-1)*N_points/slogP.Averaging:(k*N_points/slogP.Averaging),2));
        end
    end
    
    ligne_stack(:,l)=ligne;
    
    %%affichage après soustraction de la valeur basse du signal
    if l==1
        toto = zeros(size(ligne-mean(ligne(400:end))));
    end
    
    toto = toto +ligne-mean(ligne(400:end));
    
    figure(hf2)
    
    plot(tps,ligne,'k')
    
    set(gca,'xlim',[0 tps(end)])
    
    title(num2str(l))
    xlabel('Time (us)')
    drawnow
    
end
stop(ai_device);

if slog.sauvegarde==1
    save([slog.Path '\' Date '\' slog.Name '_' num2str(n_scan) '_ligne'],'y_position','ligne_stack')
    display('Données enregistrées');
end
clear
display('Travail Terminé !');

    function Stop(source, eventdata)
        
        stp=1;
        
    end

end
