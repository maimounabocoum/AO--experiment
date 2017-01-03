% Probe Charac main script
%clear all; % close all; clc;
clear Charac

% Charac.AixplorerIP = 'local';
Charac.AixplorerIP = '192.168.3.204';

% Select probe
probe = 'SC6_1'; 

% Output file name
file_prefix = 'charac_SC6_1_Humanscan_3CIX_EC1_012045';


if (strcmp(probe, 'SL15_4') == 1)
    Charac.NPiezos        = 256;
    Charac.FrequencyRange = [4 15];
    Charac.TGC            = 200;
elseif  (strcmp(probe, 'SPA5_1') == 1)
    Charac.NPiezos        = 96;
    Charac.TGC            = 10;
    Charac.FrequencyRange = [1 6];
elseif  (strcmp(probe, 'SC6_1') == 1)
    Charac.NPiezos        = 192;
    Charac.TGC            = 10;
    Charac.FrequencyRange = [1 10];
else
    disp([probe ' probe not supported yet']);
end

Charac.NbAcq  = 4;
Charac.Voltage = 10;
Charac.RxFreq = 60;   % MHz unit4.7485
Charac.RxDelay = 0;
Charac.RxDuration = 1; % us
Charac.Pause = 200;
Charac.PauseEnd = 2000;

Charac.Nfft = 2048;

% for k=1:system.probe.NbElemts*2
% Charac.CharactElements(k) = ceil(k/2);
% Charac.Waveform(k,:) = (-1)^k*[1 1 1 1 0 0];
% 
% end

for k=1:system.probe.NbElemts
    Charac.CharactElements(k) = k;
%    Charac.Waveform(k,:) = [ repmat(0, 1, 50)  1 1 0 0 0 0];
    Charac.Waveform(k,:) = [ 1 1 1 0 0 0 0];
end

[perChannelData infoStruct] = scripts.AcqProbeCharac(Charac);
perChannelData = squeeze( perChannelData( :, :, end ) );

figure(1); imagesc( perChannelData ); colorbar; caxis( [ -1 1 ] * 5e3 )

perChannelDataAvg = mean(double(perChannelData),2);
perChannelDiff = perChannelData - repmat( perChannelDataAvg, 1, size(perChannelData,2) ) ;
% figure(2); imagesc( perChannelDiff )

perChannelDiffStd = std( perChannelDiff );

figure(2); plot( perChannelDiffStd, '.' ); ylim( [ 0 2000 ] )

dead_chans = find( perChannelDiffStd > 400 )
