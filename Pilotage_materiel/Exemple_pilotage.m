%% Init program
clear all; close all; clc
w = instrfind; if ~isempty(w) fclose(w); delete(w); end
clear all;
if (exist('Pilotage_materiel')~=7)
    disp(['Library Pilotage_materiel not loaded']);
end

%% Oscilloscope
% Initialisation
%Oscillo1 = Oscillo('Tektronix','DPO2034','USB','0x0699::0x03a3::C021351');
%Oscillo1 = Oscillo('Tektronix','DPO3034','USB','0x0699::0x413::C020347');
Oscillo1 = Oscillo('Tektronix','DPO3034','TCPIP','10.40.1.117');
% Commandes
Oscillo1.Xscale = 200e-9; % 200 ns/div
Oscillo1.Yscale1 = 20; % 20 V/div
Oscillo1.Yscale2 = 0.4; % 0.4 V/div
Oscillo1.Nb_points = 10000; % Acquisition 10000 pts
Data = Oscillo1.Data_channels; % Récupération des valeurs des voies en V

%% GBF
% Initialisation
% GBF1 = GBF('Rigol','DG1022','USB','0x09C4::0x0400::DG1D154702380');
% GBF1 =  GBF('Tektronix','AFG3101C','TCPIP','10.40.1.19');
% % Commandes
% GBF1.Frequency = 1e6; % 1 MHz
% GBF1.Vpp = 5; % 5 Vpp
% GBF1.Voffset = 0.1; % 0.1 V d'offset
% GBF1.State = 'on'; % Activation de la sortie
% GBF1.State = 'off'; % Désactivation de la sortie
% GBF1.BurstMode = 'on'; % activate/desactivate burst mode
% GBF1.BurstInterval = 200; % intervalle between two bursts [ms]
% GBF1.BurstNcycles = round(f0*t_burstTest*1e-3); % number of cycles per burst 

%% Actionneur 3 axes
% Initialisation
Axes3D1 = Axes3D('Newport','MM4006','COM','5');
% Commandes
Axes3D1.startMotor
Axes3D1.X_position = 1; %mm valeur absolue par rapport au zéro de la machine
Axes3D1.Y_position = 2;
Axes3D1.Z_position = 3;
Axes3D1.stopMotor

%% Micro-balance
% Initialisation
Scale1 = Scale('Sartorius','CPA423S','COM','5');
%Scale1 = Scale('Sartorius','QUINTIX3102','COM','3');
% Commandes
Scale1.Tare; % Tare de la balance
Masse = Scale1.Mass; % Mesure de la masse mesuré par la balance

%% Tiepie
% Initialisation
TiePie1 = TiePie('TiePie','HS5','USB','1');
% Commandes Oscillo
TiePie1.State_channels = [1 1]; % Voies 1 et 2 activées
TiePie1.Resolution = 14; % 14bits de résolution
TiePie1.Nb_points = 1000; % Nombre de points acquis
TiePie1.Sample_Frequency = 1e6*50;% Fréquence d'échantillonage
TiePie1.Nb_points = 10000;
TiePie1.Trigger_EXT1 = 1; % On/Off
%TiePie1.Trigger_Level1 = 0.5; % 50% du calibre de la voie 1
TiePie1.Yscale1 = 4; % Amplitude max voie 1 [-4 4]V
TiePie1.Yscale2 = 4; % Amplitude max voie 2 [-4 4]V

% Commandes GBF
TiePie1.Vpp = 5;
TiePie1.Frequency = 1e6;
TiePie1.Shape = 'BURST_SQUARE';
TiePie1.BurstCount = 100;
TiePie1.State = 'on';

%% Analyseur de réseaux
% Initialisation
Analyseur1 = Analyseur('ROHDE_SCHWARZ','ZVL','TCPIP','10.10.20.32');
% Commandes
Analyseur1.Mode = 'S11';
Analyseur1.Start_frequency=10e3;
Analyseur1.Start_frequency=2e6;
freq = Analyseur1.Frequency;
imp = Analyseur1.Impedance;

%% Analyseur de spectre
% Initialisation
Spectrum_Analyser1 = Spectrum_Analyser('SignalHound','USB_SA44B','USB','1');
Spectrum_Analyser1.Level = -100; %-50;
Spectrum_Analyser1.CenterFrequency = 123.3e6; %98.27e6;
Spectrum_Analyser1.Span = 10e3; %1e6;
Spectrum_Analyser1.RBW = 100; %6.5e3;

%% Configuration et démarrage
Spectrum_Analyser1.startAcq;
courbe=ones(100,Spectrum_Analyser1.sweepLen)*Spectrum_Analyser1.defaultLevel;
pause(3);
%%
for ii=1:size(courbe,1)
    courbe(ii,:) = Spectrum_Analyser1.measure; 
    pause(0.1); 
    figure(1); imagesc(courbe); 
end; 
%%
Spectrum_Analyser1.stopAcq;
Spectrum_Analyser1.delete;
%% Fermeture des liaisons avec les appareils de mesures
Oscillo1.close_communication();
GBF1.close_communication();
Scale1.close_communication();

%% Suppression des objets créés
clear Oscillo1 GBF1 Axes3D1 Scale1 


