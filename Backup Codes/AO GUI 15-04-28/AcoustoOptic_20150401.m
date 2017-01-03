%% Script d'acquisition d'une image acousto-optique avec Aixplorer

%% Select probe : lancer à l'ouverture de la communication avec l'Aixplorer
% SEQ = usse.usse;
% SEQ = SEQ.selectProbe;
% clear all

%% Clear everything

clearvars
%close all;
clc;

%% Enregistrement des donnees : a changer

% enregistrement
nomgogol = 'test';

%% Enregistrement des parmetres du montage : a changer

Pref = 0; %puissance de la reference en mW
Psonde = 0; %puissance de la sonde en mW avant l'echantillon
Psonde2 = 0; %puissance de la sonde en mW apres l'echantillon
MOPA = 3500; %intensité dans le MOPA en mA
DIODE = 112; %Intensité dans la diode laser en mA
PDiode = 0; %Puissance en sortie de DL en mW
gainPD = 0; %gain de la photodiode en dB
gainAmpli = 10; %gain de l'ampli en dB
Spd = 0; %signal sur la PD en V
Ssonde = 0; %signal sur la PD sans la reference en V
Sref = 0; %signal sur la PD sans la sonde en V

%% Parametres de séquence ultrasonore

%Type de scan = 2D ou 3D
drapeau=2; % 1 = Scan 2D, 2 = Scan 3D

sauvegarde = 1;   %on enregistre les donnees ou non?
%1 : oui
%0 : non
%Param US
Foc = 20;%Profondeur de focalisation des US en mm; on définit D pour que f/D=1;
Volt = 50; %tension à envoyer dans la sonde en V (attention a la limite max)
FreqSonde = 6; %frequence de la sonde en MHz
NbHemicycle=8; %Nombre d'hémicycles a pulser
NTrig=1000; %nombre de moyennage
%Pour le scan 2D
X0 = 7; %position de départ du scan en X, mm
ScanLength = 40; %longueur à explorer, mm
Prof=40; %profondeur à explorer dans la direction des US

%Pour le scan 3D
Z0=0;    %position de départ du scan en Z, mm; positif = vers la porte
%position absolue par rapport au zero
dz=2; %pas du scan en Z, mm
ZscanLength = 5; %longueur à scanner en Z, mm


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

%% Verif tension 15MHz
if FreqSonde==15 && Volt>25
    Volt=25;
    warning('Tension max dépassée ! Limite 25 V');
end

%% Fichier d'enregistrement

date=datestr(now,'yymmdd');
path='C:\AcoustoOptique\Data\';
time=datestr(now,'hh:MM:ss');

mkdir([path date '\'])

filename=[nomgogol '_' time];

% ============================================================================ %
% ============================================================================ %


%% Build the sequence
% ============================================================================ %

AOSeqInit_FOC;

%% Paramètres du scan

axe_moteur=1; %direction du scan en Z avec le moteur (ne pas changer); 1=Z

if drapeau==1
    NPosZ=1;
elseif drapeau==2
    NPosZ=round(ZscanLength/dz);
else
    NPosZ=1;
    warning('Invalid scan type, 2D scan performed')
end

for kk=0:(NPosZ-1)
    
    PosZ=Z0+kk*dz;
    
    data_end=zeros(N_points,round(ScanLength/system.probe.Pitch));
    
    motors=PolluxOpenAndInitialize(1);
    command=sprintf('%.1f %d nm',PosZ,axe_moteur);
    fprintf(motors,command);
    
    if kk==0
        pause(10e-3)
    else pause(1e-3)
    end
    
    PolluxClose(motors,1);
    
    try
        
        ligne = zeros(N_points/N_trig,1);
        
        SEQ = SEQ.startSequence();
        
        %%traitement : decoupe du signal à chaque trig
        
    catch exception
        errordlg(exception.message, exception.identifier);
    end
    disp('Done')
    % ============================================================================ %

    
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

