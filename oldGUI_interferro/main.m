%%*****************************************************************
% Definition des paramètres TiePie
%**************************************************************************

%% Init program
clear all; close all; clc
w = instrfind; if ~isempty(w) fclose(w); delete(w); end
clear all;
if (exist('Pilotage_materiel')~=7)
    disp(['Library Pilotage_materiel not loaded']);
end

%==============================================================================%
%% Tiepie :: Initialisation
%==============================================================================%
 TiePie1 = TiePie('TiePie','HS5','USB','1');
% Commandes Oscillo
nb_mean                     = 1;
fe                          = 6e6;
fs                          = 50e6;    % sampling frequency

TiePie1.State_channels      = [1 0];    % Voies 1 et 2 activées
TiePie1.Resolution          = 14;       % 14bits de résolution
TiePie1.Nb_points           = 40000;    % Nombre de points acquis
TiePie1.Sample_Frequency    = fs;       % Fréquence d'échantillonage
TiePie1.Trigger_EXT1        = 1;        % On/Off
time_cursor                 = [18000 19000]/fs; % only to extract phase and amplitude
time                        = (1:TiePie1.Nb_points)*1/fs;

% addpath(genpath('./'));
Fpulse=8e6;
Ncycles=2;
npts=40000; %nb pts par cycle d
Fe=50*10^6; %fréquence d'échantillonage
t=1:npts; 
gen1=sin(2*pi.*t.*Ncycles./npts);
gen1=[gen1];
gen1=[zeros(1,1e-6*Fpulse*npts./Ncycles) gen1 zeros(1,150e-6*Fpulse*npts./Ncycles)].';
Fegen=npts*Fpulse./(Ncycles*length(gen1));
resultat=[];

if exist( 'Gen' , 'var' )
  % Select sine:
  Gen.SignalType = ST.ARBITRARY;
  Gen.Frequency = Fegen;
  Gen.Amplitude = 0;
  Gen.Offset = 0;
  Gen.BurstMode = BM.COUNT;
  Gen.BurstCount = 1;
  Gen.Data = gen1;
  Gen.OutputOn = 1;
  Gen.TriggerOutputs(2).Event  = Gen.TriggerOutputs(1).Events(2);
  Gen.TriggerOutputs(2).Enabled = true; 
  % Display generator info:
  Gen

end 

 
  % Start measurement:

%%******************************************************************************
% Interface graphique
%********************************************************************************
previousfile=[];

y1limit.Value=2;
y2limit.Value=2;
x1limit.Value=1e6.*1e5./fs;
x2limit.Value=1e6.*1e5./fs;

voie1=zeros(1,TiePie1.Nb_points);
tata=0;
scan=[];
k=1; 
kkk=0;

inter1=figure('Position',[30 60 1400 700]);
fenetre2.fig=inter1;
fenetre2.axe= axes('position',[.06  .2  .9 .65]);
fenetre2.hhh=uicontrol('Style', 'slider','Min',0.01,'Max',100,'Value',50,'SliderStep',[0.0001 0.0002],'Position', [1370 120 20 550],'Callback', 'y2limit=get(fenetre2.hhh)');
fenetre2.hhhh=uicontrol('Style', 'slider','Min',1,'Max',100,'Value',50,'SliderStep',[0.01 0.02],'Position', [10 60 1350 20],'Callback', 'x2limit=get(fenetre2.hhhh)');
%title(fenetre2.axe,'pression mesurèe (Voie2)')

gene=uicontrol('Style', 'radiobutton','Fontsize',20,'String', 'Gen ON','Position', [400 640 130 25]);
uicontrol('Style', 'edit','Fontsize',20,'string','Vpp (V)', 'Position', [570 655 100 35],'Callback', '');
s1=uicontrol('Style', 'edit','Fontsize',20,'string','0.1', 'Position', [570 625 100 30],'Callback', '[gen1,Gen.Frequency,Gen.Amplitude]=generateurfonction(s1,s2,s3);Gen.Data = gen1;');

uicontrol('Style', 'edit','Fontsize',20,'string','Ncycles', 'Position', [680 655 100 35],'Callback', '');
s2=uicontrol('Style', 'edit','Fontsize',20,'string','10', 'Position', [680 625 100 30],'Callback', '[gen1,Gen.Frequency,Gen.Amplitude]=generateurfonction(s1,s2,s3);Gen.Data = gen1;');

uicontrol('Style', 'edit','Fontsize',20,'string','F(Hz)', 'Position', [790 655 100 35],'Callback', '');
s3=uicontrol('Style', 'edit','Fontsize',20,'string','2.25e6','Position', [790 625 100 30],'Callback', '[gen1,Gen.Frequency,Gen.Amplitude]=generateurfonction(s1,s2,s3);Gen.Data = gen1;');

action=uicontrol('Style', 'popup','Fontsize',20,'String', 'Mesure pression|Spectre|Positionnement|Tension CH1|Tension CH2','Position', [50 640 300 40],'Callback','');   

uicontrol('Style', 'edit','Fontsize',20,'string','Moyennage', 'Position', [990 655 150 35],'Callback', '');
s5=uicontrol('Style', 'edit','Fontsize',20,'string','4','Position', [990 625 150 30],'Callback', '');

uicontrol('Style', 'edit','Fontsize',20,'string','Filtrage PB(Hz)', 'Position', [1140 655 200 35],'Callback', '');
s6=uicontrol('Style', 'edit','Fontsize',20,'string','10e6', 'Position', [1140 625 200 30],'Callback', '');

kk=1;kkk=0;
uicontrol('Style', 'pushbutton','Fontsize',20,'String', 'STOP','Position', [1100 10 200 40],'Callback', 'k=0;');
uicontrol('Style', 'pushbutton','Fontsize',20,'String', 'PAUSE','Position', [800 10 200 40],'Callback', 'kk=abs(kk-1);');
uicontrol('Style', 'pushbutton','Fontsize',20,'String', 'SCAN','Position', [500 10 200 40],'Callback', 'k=0;kkk=2');

%SIGNAL_SAUVEGARDE=[];


%%****************************************************************************************
% Demodulation et filtrage numerique
%****************************************************************************************
set(gca, 'FontSize', 20)
    set(gcf,'color','w')
compteur=0;BB=zeros(1,40);   

while k==1
    while kk==0
        pause(0.1)
    end
    Nmoy=str2num(get(s5,'string'));
    wc=str2num(get(s6,'string'))./(fs./2);
    [B,A]=butter(4,wc);
    if get(gene,'value')==1; % si on utilise le generateur de fonction du TiePie
        Gen.Amplitude=str2num(get(s1,'string'));
        Gen.Data = gen1;
    else
        Gen.Data = 0;
        Gen.Amplitude=0;
    end;
    
    %% signal
    if get(action,'value')==1 % Si on cherche à observer le signal démodulé   

            for kkkk=1:Nmoy
                
                if kkkk==1
                    voie1=0.*voie1;
                end;
             TiePie1.Trigger_Armed = 1;
             while ~strcmp(TiePie1.Trigger_Armed,'Value available')
               pause(0.1);
             end

            signal = TiePie1.Data_channels(1);

                [u,v]= func_demod(Fe*1e-6,signal,1);
                voie1=voie1+u;
               
            end;
%             voie1 = double(voie1./Nmoy);
              voie1=filtfilt(B,A,double(voie1./Nmoy));
             v=diff(voie1).*Fe.*1e-9.*1.49e6; 
             %vitesse* fréq échantillonage (1/dt) * (passage nm -> m) * impédance 
                 pause(0.01);
                 v_x=1:length(v);v_x=v_x./Fe; % vecteur temps
              
        
       % end;
       
       x2limit=get(fenetre2.hhhh,'value');%x2pos=get(hhhh2,'value');
       y2limit=get(fenetre2.hhh,'value');
       
       figure(inter1)
         plot(fenetre2.axe,v_x(1:round(length(v_x)*x2limit./100)),v(1:round(length(v_x)*x2limit./100)),'LineWidth',1);
         axis(fenetre2.axe,[0 v_x(round(length(v_x)*x2limit./100)) -1*(y2limit./100).*100e6 (y2limit./100).*100e6]);grid on
                         xlabel('temps');ylabel('Pression (Pa)')

    %% fourier
    elseif get(action,'value')==2 %Si on cherche à observer la fft du signal démodulé
        for kkkk=1:Nmoy
                if kkkk==1
                    voie1=0.*voie1;
                end;
                   TiePie1.Trigger_Armed = 1;
                    while ~strcmp(TiePie1.Trigger_Armed,'Value available')
                        pause(0.1);
                    end

            signal=single(TiePie1.Data_channels(1));
            signal2=single(TiePie1.Data_channels(2));
                [u,v]= func_demod(Fe*1e-6,signal,1);
                voie1=voie1+u;
               
            end;
            voie1=filtfilt(B,A,double(voie1./Nmoy));
             v=diff(voie1).*Fe.*1e-9.*1.49e6/1e3;  

        fftsignal=20*log10(abs(fft(v)))-20*log10(max(abs(fft(v))));        
        f=[1:length(fftsignal)].*(fs./length(fftsignal));
        x2limit=get(fenetre2.hhhh,'value');%x2pos=get(hhhh2,'value');
        y2limit=get(fenetre2.hhh,'value');
%figure(inter1)
        plot(fenetre2.axe,f(1:round(length(fftsignal)*x2limit./100)),fftsignal(1:round(length(fftsignal)*x2limit./100)),'LineWidth',1);
        axis(fenetre2.axe,[0 f(round(length(fftsignal)*x2limit./100)) -120*(y2limit./100) 0]);grid on
        xlabel('frequence (Hz)');ylabel('Amplitude dB')
                         
    %% tension CH1
    elseif get(action,'value')==4 %Si on cherche à observer la fft du signal démodulé
        TiePie1.Trigger_Armed = 1;
                    while ~strcmp(TiePie1.Trigger_Armed,'Value available')
                        pause(0.1);
                    end
        u_ch1 = TiePie1.Data_channels(1);
        
        pause(0.1);
        x2limit=get(fenetre2.hhhh,'Value');%x2pos=get(hhhh2,'value');
        y2limit=get(fenetre2.hhh,'Value');
        figure(inter1)
        plot(fenetre2.axe,v_x(1:round(length(u_ch1)*x2limit./100)),u_ch1(1:round(length(u_ch1)*x2limit./100)),'LineWidth',1);
        %axis(fenetre2.axe,[0 u_ch2(round(length(u_ch2)*x2limit./100)) -5 5]);grid on
        axis(fenetre2.axe,[0 v_x(round(length(v_x)*x2limit./100)) -1*(y2limit./100).*0.5 (y2limit./100).*0.5]);grid on
        xlabel('temps');ylabel('tension (V)');
%% tension CH2
    elseif get(action,'value')==5 %Si on cherche à observer la fft du signal démodulé
        TiePie1.Trigger_Armed = 1;            
        while ~strcmp(TiePie1.Trigger_Armed,'Value available')
             pause(0.1);
        end
        u_ch2=TiePie1.Data_channels(2);
    
        pause(0.1);
        x2limit=get(fenetre2.hhhh,'Value');%x2pos=get(hhhh2,'value');
        y2limit=get(fenetre2.hhh,'Value');
        figure(inter1)
        plot(fenetre2.axe,v_x(1:round(length(u_ch2)*x2limit./100)),u_ch2(1:round(length(u_ch2)*x2limit./100)),'LineWidth',1);
        %axis(fenetre2.axe,[0 u_ch2(round(length(u_ch2)*x2limit./100)) -5 5]);grid on
        axis(fenetre2.axe,[0 v_x(round(length(v_x)*x2limit./100)) -1*(y2limit./100).*50 (y2limit./100).*50]);grid on
        xlabel('temps');ylabel('tension (V)');
        
    else
    fp = 69.99965*1e6;    % fréquence de la porteuse (MHz)
    Npts = TiePie1.Nb_points ;    % nbre de points
    %Fe=fs;
    tps=[0:1./Fe:(Npts-1)/Fe];
    BB=BB(2:end);
    
                    TiePie1.Trigger_Armed = 1;
                    while ~strcmp(TiePie1.Trigger_Armed,'Value available')
                        pause(0.1);
                    end
                    
    u=(double(TiePie1.Data_channels(1)).*exp(-1i*2*pi*fp*tps'));
    BB=[BB mean(u.*conj(u))];
    figure(inter1)
    plot(69+(20*log10(BB)),'LineWidth',2,'Color','blue');hold on
    plot(40,69+20*log10(BB(end)),'o','MarkerEdgeColor','w','MarkerFaceColor','b','MarkerSize',20);
    plot([1 50],[0 0],'--','LineWidth',2,'Color','red');hold off 
    axis([1 50 -70 10]); grid on
     xlabel('trial');ylabel('signal dBm')
    drawnow
    pause(0.01);
                        
                         
    end;
end;
if kkk==2
    Main_scan;
end;




return


