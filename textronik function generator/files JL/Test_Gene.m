clear,clc

% Linear Hanning Chirplet
f0    = 2.87;   % (MHz)

duree = 10;     % (µs)
df    = 0.15;    %(MHz)
[t_sig,sig,fe,N,t0] = ChirpHanning(duree,1.85,1.98,'f');

% émission du signal par le générateur
nb_cyc = 1;
T_rep  = 15;
Vpp    = 0.8;
offset = -3.8175;
Tek_AFG_3101(sig,fe,T_rep,nb_cyc,duree,Vpp,offset);

%%
addpath O:\Instrument\Acquisition_TiePie\two_channel


Init_TiePie;

% Réglages paramètres carte TiePie
T       = 2500;          % Durée d'acquisition (µs)
fe      = 20;          % Fréquence d'échantillonnage  --> 500,200,100,50 (valable pour 1 voie et 12 bits)
Vrange1 = 4;            % Idem au calibre d'un oscillo --> 0.2,0.4,0.8,2,4,8,20,40 ou 80 Vpp
Vrange2 = 4;
TriggerType =   'EXT1';%'INT1';
[N,T_out,fs_out,Vrange1_out,Vrange2_out] = SetConfigTiepPie_Osc2(scp,T,fe,Vrange1,Vrange2,TriggerType);


[t,SIP,SOOP] = TiePie_acquisition2(scp,N,fs_out,200);
SIP = SIP - mean(SIP);
SOOP = SOOP - mean(SOOP);
figure(15);
set(gcf,'Color',[1 1 1]), set(gcf,'Position',[1441 1 1440 824])
subplot 211,plot(t,SIP,'k');
set(gca,'FontSize',18)
xlabel('Time (µs)','FontSize',18)
ylabel('Amplitude (V)','FontSize',18)
axis([t(1) t(end) 1.1*min(SIP) 1.1*max(SIP)])
subplot 212,plot(t,SOOP,'k')
set(gca,'FontSize',18)
xlabel('Time (µs)','FontSize',18)
ylabel('Amplitude (V)','FontSize',18)
axis([t(1) t(end) 1.1*min(SOOP) 1.1*max(SOOP)])


%%
% Scan dispersion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%           5. Acquisition              %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%clear,
clc
path='O:\USERS\Benoit\R_mur';
cd(path); [newpath,nom] = New_Folder(path);cd('../')

clc
moy   = 200; tmp_stab = 1;
File  = sprintf('.\\%s\\Courbe_Disp_Chirp_',nom);
pasX  = 1; 
distanceX = [0:pasX:50];


clear resu time
resu     = zeros(N,length(distanceX));
time_ref = clock;
for i=43:length(distanceX)
    disp(sprintf('Point = %d/%d ',i,length(distanceX)));
    [t,SIP(:,i),SOOP(:,i)] = TiePie_acquisition2(scp,N,fs_out,moy);
    time(i,:)     = etime(clock,time_ref);
    mot_dep_LS15_I(pasX,0);
    display('mot_dep_LS15_I(pasX,0) - fait');
    pause(tmp_stab);
end
save(sprintf('%s_%03d.mat',File,1),'t','SIP','SOOP','moy','distanceX','pasX','time');


