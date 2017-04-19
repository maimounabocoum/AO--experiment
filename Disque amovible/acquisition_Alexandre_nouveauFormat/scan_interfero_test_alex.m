%% Init program
clear all; close all; clc
w = instrfind; if ~isempty(w) fclose(w); delete(w); end
clear all;
if (exist('Pilotage_materiel')~=7)
    disp(['Library Pilotage_materiel not loaded']);
end

%% Tiepie
% Initialisation
TiePie1 = TiePie('TiePie','HS5','USB','1');
% Commandes Oscillo
nb_mean = 5;
fe = 914e3;
TiePie1.State_channels = [1 0]; % Voies 1 et 2 activées
TiePie1.Resolution = 14; % 14bits de résolution
TiePie1.Nb_points = 20000; % Nombre de points acquis
fs = 1e6*100;
TiePie1.Sample_Frequency = fs;% Fréquence d'échantillonage
TiePie1.Trigger_EXT1 = 1; % On/Off
time_cursor = [15000 19000]/fs;
time = (1:TiePie1.Nb_points)*1/fs;
% %TiePie1.Trigger_Level1 = 0.5; % 50% du calibre de la voie 1
% TiePie1.Yscale1 = 4; % Amplitude max voie 1 [-4 4]V
% TiePie1.Yscale2 = 4; % Amplitude max voie 2 [-4 4]V
% 
% % Commandes GBF
% TiePie1.Vpp = 5;
% TiePie1.Frequency = 1e6;
% TiePie1.Shape = 'BURST_SQUARE';
% TiePie1.BurstCount = 100;
% TiePie1.State = 'on';

%% GBF
GBF1 =  GBF('Tektronix','AFG3101C','USB','0x0699::0x034B::C010648');
% Commandes
GBF1.Frequency = 914e3; % 914 kHz
GBF1.State = 'off'; % Désactivation de la sortie


%% Actionneur 3 axes
% Initialisation
Axes3D1 = Axes3D('Newport','ESP301','COM','4');


%%
frequencies = [914e3];
xstep = 0.2;
ystep = 0.2;
nb_point = 7;
xcenter = 5.4;
ycenter = 0;

xmin = xcenter-xstep*nb_point;%4.6-0.2*15;
xmax = xcenter+xstep*nb_point;%4.6+0.2*15;
ymin = ycenter-ystep*nb_point;%-1.6-0.2*15;
ymax = ycenter+ystep*nb_point;%-1.6+0.2*15;
zmin = -29;
zmax = -21;
zstep = 0.5;
%
x = xmin:xstep:xmax;
y = ymin:ystep:ymax;
z = zmin:zstep:zmax;

Data_scan = single(zeros(length(x),length(y),length(z),2,length(frequencies)));

signal = zeros(TiePie1.Nb_points,1);



%%
GBF1.State = 'on'; % Activation de la sortie
Axes3D1.startMotor

Axes3D1.X_position = x(1);
Axes3D1.Y_position = y(1);
Axes3D1.Z_position = z(1);

tic
for zz=1:length(z)
    Axes3D1.Z_position = z(zz);
    while round(z(zz)-Axes3D1.Z_position,3)~=0
        pause(0.1);
    end
    pause(0.1);
    for yy=1:length(y)
        Axes3D1.Y_position = y(yy);
        while round(y(yy)-Axes3D1.Y_position,3)~=0
            pause(0.1);
        end
        pause(0.1);
        for xx=1:length(x)
            disp(['Scan position X:' num2str(x(xx)) ',Y: ' num2str(y(yy)) ',Z: ' num2str(z(zz))]);
            Axes3D1.X_position = x(xx); %1m valeur absolue par rapport au zéro de la machine
            while round(x(xx)-Axes3D1.X_position,3)~=0
                pause(0.1);
            end
            pause(0.1);
            for ff = 1:length(frequencies)
                GBF1.Frequency = frequencies(ff);
                for kk = 1:nb_mean
                    TiePie1.Trigger_Armed = 1;
                    while ~strcmp(TiePie1.Trigger_Armed,'Value available')
                        pause(0.1);
                    end
                    signal = signal + single(TiePie1.Data_channels(1));
                end
                signal = signal/nb_mean;
                [amp, phi] = find_amp_phase(signal', fs, fe, time_cursor);
                Data_scan(xx,yy,zz,1,ff) = amp;
                Data_scan(xx,yy,zz,2,ff) = phi;
                figure(1);
                plot(time,signal);
                disp(['Amp : ' num2str(Data_scan(xx,yy,zz,1,ff)) ', phi : ' num2str(Data_scan(xx,yy,zz,2,ff))]);      
            end
        end
    end
end
Axes3D1.stopMotor
disp(['Scan terminé']);
time_to_measure = toc;

GBF1.State = 'off';
return

%% Affichage
figure; for kk = length(z):-1:1 imagesc(20*log10(squeeze(Data_scan(:,:,kk,1)'/max(max(max(Data_scan(:,:,:,1))))))); colorbar; title(num2str(z(kk))); caxis([-30 0]); pause; end

%%
figure; for kk = length(z):-1:1 imagesc(Data_scan(:,:,kk,1)'); colorbar; title(num2str(z(kk))); pause; end

%%
figure; for kk = length(z):-1:1 imagesc(Data_scan(:,:,kk,2)'); colorbar; title(num2str(z(kk))); pause; end
%%
figure
plot(z, squeeze(Data_scan(18,18,:,1)))
%%
return
clear Axes3D1 Tiepie1


