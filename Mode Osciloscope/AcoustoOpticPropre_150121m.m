%% Script d'acquisition d'une image acousto-optique avec Aixplorer

%% Select probe : lancer à l'ouverture de la communication avec l'Aixplorer
% SEQ = usse.usse;
% SEQ = SEQ.selectProbe;
% clear all

%% Clear everything

clear all;
%close all;
clc;

%% Enregistrement des donnees : a changer

% enregistrement
date='1501121';
path='G:\JB\Data\TestFibre\';
nomgogol = 'GelInclusionCylindriqueTransmission';

mkdir([path date '\'])

%% Enregistrement des parmetres du montage : a changer

Pref = 80; %puissance de la reference en mW 
Psonde = 1200; %puissance de la sonde en mW avant l'echantillon
Psonde2 = 0; %puissance de la sonde en mW apres l'echantillon
MOPA = 2600; %intensité dans le MOPA en mA
DIODE = 114; %Intensité dans la diode laser en mA
PDiode = 0; %Puissance en sortie de DL en mW
gainPD = 0; %gain de la photodiode en dB
gainAmpli = 40; %gain de l'ampli en dB
Spd = 0; %signal sur la PD en V
Ssonde = 0; %signal sur la PD sans la reference en V
Sref = 0; %signal sur la PD sans la sonde en V

%% Parametres de séquence ultrasonore

%Type de scan
drapeau =1;  %1 : mode acquisition d'une ligne
            %2 : mode scan 2D
            %3 : Mode scan 3D
sauvegarde = 0;   %on enregistre les donnees ou non?
                %1 : oui
                %0 : non
%Param US
Foc = 20;%Profondeur de focalisation des US en mm; on définit D pour que f/D=1;
Volt = 70; %tension à envoyer dans la sonde en V (attention a la limite max)
FreqSonde = 6; %frequence de la sonde en MHz
NbHemicycle=8; %Nombre d'hémicycles a pulser

%Pour le scan 1D
N_boucles = 1000; %nb de répétition de la séquence pour visualisation

%Pour le scan 2D
X0 = 20; %position de départ du scan en X, mm
dx = 0.2;%0.2; %pas du scan en X, mm

largueur = 20; 
Npos = floor(largueur/dx);   %148; %Nombre de positions du scan US (si le choix se porte sur une
%acquisition une ligne, ce param vaut automatiquement 1

%Pour le scan 3D
Z0=0;    %position de départ du scan en Z, mm; positif = vers la porte
         %position absolue par rapport au zero
dz=2; %pas du scan en Z, mm
NposZ=4;    %Nombre de positions du scan US (si le choix se porte sur une
%acquisition 2D, ce param vaut automatiquement 1

%Filtrage : fcut = fréquence de coupure en Hz,
%fcut = 0 => pas de filtrage
fcut=0;

%% Initialisation a zero de la position du moteur

% % définir la position actuelle comme le 0
% motors=PolluxOpenAndInitialize(1);
% fprintf(motors,'0.0 1 setnpos');
% fprintf(motors,'0.0 2 setnpos');
% PolluxClose(motors,1);

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% DEBUT DU PROGRAMME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ouverture communication avec l'échographe
IPaddress = '192.168.1.20'; % IP address of Aixplorer
srv = remoteDefineServer('extern',IPaddress,'9999');
%remoteSetLevel('srv','system');

%% Paramètres acquisition

N_points = 1080000; % 1080000;  %751000;%round(1520000/56*20);
SampleRate = 4e7;
Tps = 27; %14; %27; %temps par ligne d'acquisition en µs
N_trig = 1000;%*2; %2000
DAQFileName = '2Voies-record_1000moy_sr40MHz_200mV_27us_par_ligne';
tps = 0:1/SampleRate:(N_points/N_trig-1)/SampleRate; %vecteur temps s
y_position = tps*1480*10^3; %mm

% max(y_position)

%% Numero du scan automatique
if FreqSonde==15 && Volt>25
    Volt=25;
    warning('Tension max dépassée ! Limite 25 V');
end
%boucle pour changer le n_scan automatiquement pour eviter de les
%ecraser si la sauvegarde est activée
if sauvegarde==1
    
    n_scan=1;
    
    if drapeau==1
        A=exist([path date '\' nomgogol '_' num2str(n_scan) '_ligne.mat'],'file');
        while A==2
            n_scan=n_scan+1;
            A=exist([path date '\' nomgogol '_' num2str(n_scan) '_ligne.mat'],'file');
        end
        clear A
        
    elseif drapeau==2||3
        A=exist([path date '\' nomgogol '_' num2str(n_scan) '_planXY_en_Z0.mat'],'file');
        
        while A==2
            n_scan=n_scan+1;
            A=exist([path date '\' nomgogol '_' num2str(n_scan) '_planXY_en_Z0.mat'],'file');
        end
        clear A
    end
    
end

%% Ouverture communication avec la carte d'acquisition
tic
%Create an analog output object. 0 stands for the first ADLINK device
%installed.
ai_device = analoginput('mwadlink', 0);
%Add channel#0 to ao_device object.
ai_channel = addchannel(ai_device, 0);
%Règle les paramètres d'acquisition à partir d'un task file
set(ai_device,'DAQPilotFile',[DAQFileName '.tsk']);

% ============================================================================ %
% ============================================================================ %

%% Paramètres de la séquence US
% tension etc...
ImgVoltage = Volt;             % imaging voltage [V]
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
CP.TwFreq     = FreqSonde;       % MHz 15
CP.NbHcycle   = NbHemicycle;         %
CP.ApodFct    = 'none';    %
CP.DutyCycle  = 1;         %
CP.TxCenter   = 0;        % mm
CP.TxWidth    = Foc/2;        % mm


CP.PosZ = Foc; %mm

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
% ============================================================================ %

%% Paramètres du scan

if drapeau==1
    Npos =1; %17%154; %nombre de positions en x
end

if drapeau~=3
    NposZ=1; %nombre de position en Z
end

axe_moteur=1; %direction du scan en Z avec le moteur (ne pas changer); 1=Z

X=X0:dx:X0+(Npos-1)*dx;
Y=tps*1480*1000;
Z=Z0:dz:Z0+(NposZ-1)*dz;

% Enregistrement des paramètres
if sauvegarde==1
    saveparam;
end

for kk=0:(NposZ-1)
    
    PosZ=Z(kk+1);
    data_end=zeros(N_points/N_trig,Npos);
    
    motors=PolluxOpenAndInitialize(1);
    command=sprintf('%.1f %d nm',PosZ,axe_moteur);
    fprintf(motors,command);
    if kk==0
        pause(10)
    else pause(3)
    end
    
    
    PolluxClose(motors,1);
    
    for uu=0:(Npos-1)
        
        CP.PosX =X0+dx*uu;
        
        
        FOCUSED = elusev.focused( ...
            'TwFreq', CP.TwFreq, ...
            'NbHcycle', CP.NbHcycle, ...
            'Polarity', 1, ...
            'SteerAngle', 0, ...
            'Focus', CP.PosZ, ...    %en mm
            'Pause', 60, ...       %en  µs
            'PauseEnd', 101, ...       %en µs
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
            'TrigOut', 50 , ...    %en µs
            'TrigAll', 0, ...
            'Repeat', N_trig+1, ...
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
        % Ajouter les commandes moteur
        % Initialize & load sequence remote
        SEQ = SEQ.initializeRemote('IPaddress', IPaddress);
        SEQ = SEQ.loadSequence();
        
        % Start sequence
        clear buffer;
        %loop
        
        if drapeau==1
            try
                %%   Mode oscilloscope pour scan d'une ligne
                %Bornes des axes de visualisation
                xmin=0;
                xmax=50;
                ymin=-0.005;
                ymax=0.05;
                
                ligne_stack=zeros(N_points/N_trig,N_boucles);
                
                for l=1:N_boucles
                    ecart_type=1;
                    moyenne=0;
                    while ecart_type>0.89 %|| moyenne>=0.5 || moyenne<=-0.5 || moyenne==0
                        ligne=zeros(N_points/N_trig,1);
                        %%lancement acquisition
                        start(ai_device);
                        %%lancement sequence US
                        SEQ = SEQ.startSequence();
                        %%acquisition
                        data=getdata(ai_device);
                        %%stop carte d'acquisition
                        stop(ai_device);
                        %%stop sequence US
                        SEQ = SEQ.stopSequence('Wait', 1);
                        flushdata(ai_device);
                        
                        
                        ecart_type=std(data);
                        moyenne=mean(data);
                    end
                    
                    %%traitement : decoupe du signal à chaque trig
                    c=0;
                    for k=1:N_trig
                        %if mean(data((k-1)*N_points/N_trig+1:(k*N_points/N_trig)))<=0.5 && mean(data((k-1)*N_points/N_trig+1:(k*N_points/N_trig)))>=-0.5 && mean(data((k-1)*N_points/N_trig+1:(k*N_points/N_trig)))~=0
                        % c=c+1;
                        %ligne=ligne+data(1+(k-1)*N_points/N_trig:(k*N_points/N_trig));
                        %end
                        ligne=ligne+1/N_trig*data(1+(k-1)*N_points/N_trig:(k*N_points/N_trig));
                    end
                    %ligne=ligne/c;
                    ligne=ligne-mean(ligne(1:200));
                    ligne_stack(:,l)=ligne;
                    
                    %enregistrement
                    %             date='060412';
                    %             courant=6;
                    %             n_scan_1D=l;
                    %             save(['G:\Emilie\Acquisitions carte adlink\270412\scan1D_' num2str(courant) '_' num2str(n_scan_1D)],'ligne');
                    %             save(['G:\Emilie\Acquisitions carte adlink\270412\scan1D_' num2str(courant) '_' num2str(n_scan_1D) '_y'] ,'y_position');
                    %             save(['G:\Emilie\Acquisitions carte adlink\270412\scan1D_' num2str(courant) '_' num2str(n_scan_1D) '_row_data'],'data');
                    
                    %%affichage après soustraction de la valeur basse du signal
                    if l==1
                        toto = zeros(size(ligne-mean(ligne(400:end))));
                    end
                    
                    toto = toto +ligne-mean(ligne(400:end));
                    
                    figure(42)
                    %subplot 121
                    plot(tps*1480*10^3,ligne,'k')
                    %                 drawnow
                    %                 subplot 122
                    %                 plot(tps*1540*10^3,toto,'r')
                    
                    dist_mm=tps*1480*10^3;
                    set(gca,'xlim',[0 dist_mm(end)])
                    %set(gca,'ylim',[-0.01 0.01])
                    %set(gca,'ylim',[0 15*10^-3])
                    %drawnow
                    
                    %                 ymax = max(ligne-mean(ligne(400:end)));
                    %
                    %                 if l==1
                    %                     refmax=ymax;
                    %                     set(gca,'ylim',[0 refmax])
                    %                 end
                    %                 if ymax > refmax
                    %                     refmax =ymax;
                    %                     set(gca,'ylim',[0 refmax])
                    %                 else
                    %                     set(gca,'ylim',[0 refmax])
                    %                 end
                    %
                    
                    title(num2str(l))
                    drawnow
                    %set(gca,'ylim',[ymin ymax])
                    %axis([xmin xmax ymin ymax])
                    
                end
                
                if sauvegarde==1
                    save([path date '\' nomgogol '_' num2str(n_scan) '_ligne'],'dist_mm','ligne_stack')
                end
                
                disp('Ok')
                
            catch exception
                errordlg(exception.message, exception.identifier);
            end
            
            return
            
            % %       ==========================================================
            %% Mode scan 2D ou 3D
        elseif drapeau==2||3
            
            try
                
                ligne = zeros(N_points/N_trig,1);
                %%lancement acquisition
                start(ai_device);
                %%lancement sequence US
                SEQ = SEQ.startSequence();
                %%acquisition
                data=getdata(ai_device);
                %%stop carte d'acquisition
                stop(ai_device);
                %%stop sequence US
                SEQ = SEQ.stopSequence('Wait', 1);
                flushdata(ai_device);
                clear 'SEQ'
                
                %%traitement : decoupe du signal à chaque trig
                
                for k=1:N_trig
                    ligne=ligne+1/N_trig*data(1+(k-1)*N_points/N_trig:(k*N_points/N_trig));
                end
                ligne=ligne-mean(ligne(1:200));
                
                if fcut>0
                    FFT=fftshift(fft(ligne));
                    f=linspace(-SampleRate/2,SampleRate/2,length(ligne));
                    filt=zeros(size(ligne));
                    filt(abs(f)<fcut)=1;
                    FFTfilt=filt.*FFT;
                    ligne=abs(ifft(FFTfilt));
                    clear FFT FFTfilt f filt
                end
                
                data_end(:,uu+1)=ligne;
                clear 'ligne'
                %save(['G:\Emilie\Acquisitions carte adlink\270612\scan2D_1_' 'position_' num2str(uu) '_row_data'],'data');
                figure(30)
                subplot(1,2,1);   
                imagesc(X,Y,data_end)
                axis image
                title('Image 2D')
                xlabel('X (mm)')
                ylabel('Y (mm)')
                %colormap gray
                subplot(1,2,2);
                plot(data_end(:,uu+1),Y)
                set(gca,'ydir','reverse')
                title('Profil axial')
                xlabel('Signal AO (V)')
                ylabel('Y (mm)')
                drawnow
                disp(['Ok_X_' num2str(uu)])
            catch exception
                errordlg(exception.message, exception.identifier);
            end
            disp('Done')
            % ============================================================================ %
        end
    end
    
    %% Visualisation et enregistrement en scan 2D ou 3D
    if sauvegarde==1
        %save(['G:\Emilie\Acquisitions carte adlink\' date '\' nomgogol '_' num2str(n_scan) '_brut'],'data_mean');
        save([path date '\' nomgogol '_' num2str(n_scan) '_planXY_en_Z' num2str(kk)],'data_end','X','Y','Z','PosZ');
        
        %save(['G:\Emilie\Acquisitions carte adlink\' date '\' nomgogol '_' num2str(n_scan) '_lisse'],'Mb');
        % =========================================================================
        clear 'data_end'
        try
            GetBmode;
            disp('Bmode OK')
        catch error1
            warning(error1.message);
        end
    end
    disp(['Ok_Z_' num2str(kk)])
end

%enregistrement des axes
% if sauvegarde==1
%     save([path date '\' nomgogol '_' num2str(n_scan) '_X'],'X')
%     save([path date '\' nomgogol '_' num2str(n_scan) '_Y'],'Y')
%     save([path date '\' nomgogol '_' num2str(n_scan) '_Z'],'Z')
% end


% %%   Séquence US sans acquisition
% if drapeau==2
%     try
%
%         for p=1:500
%             %%lancement sequence US
%             SEQ = SEQ.startSequence();
%
%             %%stop sequence US
%             SEQ = SEQ.stopSequence('Wait', 1);
%         end
%
%
%
%
%
%     catch exception
%         errordlg(exception.message, exception.identifier);
%     end
%     disp('Ok')
% end

% delete(ai_device);
% wtime=toc;
% s=sprintf('processing time is %f s.',wtime);
% fid=fopen(FileName,'a');
% fprintf(fid,s);