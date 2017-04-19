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
nb_mean                     = 10;
fe                          = 6e6;
fs                          = 12e6;    % sampling frequency

TiePie1.State_channels      = [1 0];    % Voies 1 et 2 activées
TiePie1.Resolution          = 14;       % 14bits de résolution
TiePie1.Nb_points           = 10000;    % Nombre de points acquis
TiePie1.Sample_Frequency    = fs;       % Fréquence d'échantillonage
TiePie1.Trigger_EXT1        = 1;        % On/Off
time_cursor                 = [1800 1900]/fs; % only to extract phase and amplitude
time                        = (1:TiePie1.Nb_points)*1/fs;

disp(['t_{max} = ',num2str(1e6*TiePie1.Nb_points/fs),'\mu s'])
% TiePie1.Trigger_Level1 = 0.2; % 50% du calibre de la voie 1
% TiePie1.Yscale1 = 4; % Amplitude max voie 1 [-4 4]V
% TiePie1.Yscale2 = 4; % Amplitude max voie 2 [-4 4]V

% % Commandes GBF
% TiePie1.Vpp = 5;
% TiePie1.Frequency = 1e6;
% TiePie1.Shape = 'BURST_SQUARE';
% TiePie1.BurstCount = 100;
% TiePie1.State = 'on';

%% GBF
 GBF1 =  GBF('Tektronix','AFG3101C','USB','0x0699::0x034B::C010648');
 Commandes
 GBF1.Frequency = 914e3; % 914 kHz
 GBF1.State = 'off'; % Désactivation de la sortie

%======================================================================%
%% Actionneur 3 axes :: Initialisation
%======================================================================%

Axes3D1 = Axes3D('Newport','ESP301','COM','6');
 
frequencies = [6e6]; % central frequency of pulse in Hz

x = zeros(1,500);
y = 0;
z = 0;

Data_scan = single(zeros(length(x),length(y),length(z),2));

% single vector to record temporal fluctuations :
signal = zeros(TiePie1.Nb_points,1);


%GBF1.State = 'on'; % Activation de la sortie
%Axes3D1.startMotor

Axes3D1.X_position = x(1);
Axes3D1.Y_position = y(1);
Axes3D1.Z_position = z(1);

tic
for zz = 1:length(z) % loop on z 
%     Axes3D1.Z_position = z(zz); % set z position
%     while round(z(zz)-Axes3D1.Z_position,3)~=0
%         pause(0.1);
%     end % wait for position to be reached
%     pause(0.1);
    for yy=1:length(y)
%         Axes3D1.Y_position = y(yy);
%         while round(y(yy)-Axes3D1.Y_position,3)~=0
%             pause(0.1);
%         end
%         pause(0.1);
        for xx=1:length(x) 
%             Axes3D1.X_position = x(xx); %1m valeur absolue par rapport au zéro de la machine
%             while round(x(xx)-Axes3D1.X_position,3)~=0
%                 pause(0.1);
%             end
%             pause(0.1);
            
            
            disp(['Scan position X:' num2str(x(xx)) ',Y: ' num2str(y(yy)) ',Z: ' num2str(z(zz))]);
            
            %===============================================================
            % record single point %
            %===============================================================
            
            %for ff = 1:length(frequencies)
                %GBF1.Frequency = frequencies(ff);
                for kk = 1:nb_mean
                    TiePie1.Trigger_Armed = 1;
                    while ~strcmp(TiePie1.Trigger_Armed,'Value available')
                        pause(0.1);
                    end
                    signal = signal + single(TiePie1.Data_channels(1));
                end
                signal = signal/nb_mean;
                [amp, phi] = find_amp_phase(signal', fs, fe, time_cursor);
                Data_scan(xx,yy,zz,1) = amp;
                Data_scan(xx,yy,zz,2) = phi;
                
                figure(1);
                plot(time*1e6,signal);
                xlabel('time in \mu s ')
                disp(['Amp : ' num2str(Data_scan(xx,yy,zz,1)) ', phi : ' num2str(Data_scan(xx,yy,zz,2))]);      
            
                %===============================================================
                % go to next position 
                %===============================================================
                
            %end
            
        end % end loop x
    end % end loop y
end % end loop z

%Axes3D1.stopMotor
disp(['Scan terminé']);

time_to_measure = toc;

%GBF1.State = 'off';
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


