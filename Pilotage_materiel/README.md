Ce dépot permet de contrôler des appareils de mesures (Oscilloscope, GBF, 3 axes) depuis Matlab de façon plus intuitive. Le code n'est pas compatible sous Linux.

# Exemple d'utilisation pour l'oscilloscope
    Oscillo1 = Oscillo('Tektronix','DPO3034','TCPIP','XXX.XXX.XXX.XXX');
    Oscillo1.Xscale = 200e-9; % 200 ns/div
    Oscillo1.Yscale1 = 20; % 20 V/div
    Oscillo1.Yscale2 = 0.4; % 0.4 V/div
    Oscillo1.Nb_points = 10000; % Acquisition 10000 pts
    Data = Oscillo1.Data_channels; % Récupération des valeurs des voies en V
    Oscillo1.close_communication();
    
# Exemple d'utilisation pour le GBF
    GBF1.Frequency = 1e6; % 1 MHz
    GBF1.Vpp = 5; % 5 Vpp
    GBF1.Voffset = 0.1; % 0.1 V d'offset
    GBF1.State = 'on'; % Activation de la sortie
    GBF1.State = 'off'; % Désactivation de la sortie
    GBF1.close_communication();
    
# Exemple d'utilisation pour la TiePie
    Oscillo1 = TiePie('TiePie','HS5','USB','1');
    Oscillo1.State_channels = [1 1]; % Voies 1 et 2 activées
    Oscillo1.Resolution = 14; % 14bits de résolution
    Oscillo1.Nb_points = 10000000; % Nombre de points acquis
    Oscillo1.Sample_Frequency = 1e6*100; % Fréquence d'échantillonage
    Oscillo1.Yscale1 = 4; % Amplitude max voie 1 [-4 4]V
    Oscillo1.Yscale2 = 0.2; % Amplitude max voie 2 [-0.2 0.2]V
    clear Oscillo1
    
# Build et installation

    Placer les fichiers dans un répertoire du path de matlab (Ex: ../Mes Documents/MATLAB)
    La bibliothèque nécessite l'installation de NIVISA1401runtime.exe pour le pilotage des Oscilloscope,GBF,Analyseur de réseaux et d'un compilateur C++ type SDK pour la Tiepie