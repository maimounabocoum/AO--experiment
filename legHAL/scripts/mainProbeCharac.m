% Probe Charac main script

Charac.AixplorerIP = '192.168.3.182';
% Select probe
probe = 'SPA5_1'; %probe = 'SPA5_1'

% Output file name
file_prefix = 'charac_Alpinion_SPA02_SSI_V2';


if (strcmp(probe, 'SL15_4') == 1)
    Charac.NPiezos        = 256;
    Charac.acqDuration    = 50;   % µs unit
    Charac.FrequencyRange = [4 15];
    Charac.TGC            = 350;
elseif  (strcmp(probe, 'SPA5_1') == 1)
    Charac.NPiezos        = 96;
    Charac.TGC            = 800;
    Charac.FrequencyRange = [1 6];
else
    disp([probe ' probe not supported yet']);
end

Charac.NbAcq  = 1;
Charac.Voltage = 30;
Charac.RxFreq = 30;   % MHz unit
Charac.RxDelay = 0;
Charac.RxDuration = 300;
Charac.Waveform = [1 1 1 1 0 0];
Charac.Pause = 200;
Charac.PauseEnd = 2000;
Charac.CharactElements = 1:Charac.NPiezos;
Charac.Nfft = 2048;

[perChannelData infoStruct] = scripts.AcqProbeCharac(Charac);

%% refine time window

figure(1);
imagesc(perChannelData);
caxis( [-1 1]*1e3 );
[X,Y] = ginput(2);

% update RxDelay and RxDuration

Charac.RxDelay = (infoStruct.event(1).skipSamples+min(Y))/Charac.RxFreq;
Charac.RxDuration = abs(Y(2)-Y(1))/Charac.RxFreq;
Charac.RxFreq = 60;
Charac.NbAcq = 10;

%Charac.NbAcq  = 1;
[perChannelData infoStruct] = scripts.AcqProbeCharac(Charac);

perChannelDataAvg = mean(double(perChannelData),3);
perChannelDataStd = std(double(perChannelData),1,3);

figure(1);
plot(0:(size(perChannelData,1)-1),perChannelDataAvg(:,end/2));

figure(2);
subplot(2,1,1);
imagesc(perChannelDataAvg); title('Averaged Pulse');
subplot(2,1,2);
imagesc(perChannelDataStd); title('Standard deviation over NbAcq');

spectrums = fft(double(perChannelData),Charac.Nfft,1)/Charac.Nfft;
spectrumsAvg = abs(mean(spectrums,3));
spectrumsStd = std(spectrums,1,3);

spectrumsAvgAcrossArray = mean(spectrumsAvg,2);
spectrumsStdAcrossArray = std(spectrumsAvg,1,2);

figure(3);
plot((0:(Charac.Nfft-1))/Charac.Nfft*Charac.RxFreq,20*log10(abs(spectrumsAvgAcrossArray)),'Linewidth',2);
hold on;
plot((0:(Charac.Nfft-1))/Charac.Nfft*Charac.RxFreq,20*log10(abs(spectrumsAvgAcrossArray)-3*spectrumsStdAcrossArray),'k--');
plot((0:(Charac.Nfft-1))/Charac.Nfft*Charac.RxFreq,20*log10(abs(spectrumsAvgAcrossArray)+3*spectrumsStdAcrossArray),'k--');
hold off;
xlim(Charac.FrequencyRange);
title('Average spectrum over all acquisition and all elements');
xlabel('Frequency MHz');

%% per channel bandwidth, fc, cuttoff

idxfftMin = round(Charac.FrequencyRange(1)*Charac.Nfft/Charac.RxFreq);
idxfftMax = round(Charac.FrequencyRange(2)*Charac.Nfft/Charac.RxFreq);

for k=1:length(Charac.CharactElements)
    [Maxfft,idxMax] = max(spectrumsAvg(idxfftMin:idxfftMax,k));
    fMax(k) = (idxMax+idxfftMin-1)/Charac.Nfft*Charac.RxFreq;
    aboveM6dB = find(spectrumsAvg(idxfftMin:idxfftMax,k)>=0.5*Maxfft);
    lowCutOff6dB(k) = (min(aboveM6dB)+idxfftMin-1)*Charac.RxFreq/Charac.Nfft;
    highCutOff6dB(k) = (max(aboveM6dB)+idxfftMin-1)*Charac.RxFreq/Charac.Nfft;
end

meanFc = mean(lowCutOff6dB+highCutOff6dB)/2;
stdFc = std((lowCutOff6dB+highCutOff6dB)/2);

meanLowCutOff6dB = mean(lowCutOff6dB);
stdLowCutOff6dB = std(lowCutOff6dB);

meanHighCutOff6dB = mean(highCutOff6dB);
stdHighCutOff6dB = std(highCutOff6dB);

meanBW = mean(2*(highCutOff6dB-lowCutOff6dB)./(highCutOff6dB+lowCutOff6dB));
stdBW = std(2*(highCutOff6dB-lowCutOff6dB)./(highCutOff6dB+lowCutOff6dB));


stat.meanFc = meanFc;
stat.stdFc = stdFc;
stat.meanLowCutOff6dB = meanLowCutOff6dB;
stat.stdLowCutOff6dB = stdLowCutOff6dB;
stat.meanHighCutOff6dB = meanHighCutOff6dB;
stat.stdLowCutOff6dB = stdLowCutOff6dB;
stat.meanBW = meanBW;
stat.stdBW = stdBW;

% tof over the array

channelRef = round(size(perChannelData,2)/2);
for acq=1:size(perChannelData,3)
    for chann=1:size(perChannelData,2)
        Rxy = xcorr(perChannelData(:,chann,acq),perChannelData(:,channelRef,acq));
        [M,I] = max(Rxy);
        tof(chann) = I-0.5*(Rxy(I+1)-Rxy(I-1))/(Rxy(I+1)+Rxy(I-1)-2*Rxy(I));
    end
    p = polyfit(Charac.CharactElements,tof,1);
    p2(acq,:) = p;
    residualTof(:,acq) = tof- polyval(p,Charac.CharactElements);
end
% 
misAligmentSlopeAvg = mean(1e3*p2(:,1)/Charac.RxFreq);
misAligmentSlopeStd = std(1e3*p2(:,1)/Charac.RxFreq);
% 
% probeMotionStd =  std((p2(2:end,2)-p2(1,2))/Charac.RxFreq);

figure(4);
errorbar(Charac.CharactElements,mean(1e3*residualTof/Charac.RxFreq,2),std(1e3*residualTof/Charac.RxFreq,1,2));
title('time of flight');
xlabel('channel');
ylabel('time of flight (ns)');

matching_value = inputdlg('matching value');
matching_value = cell2mat(matching_value);
voltage = num2str(Charac.Voltage);

disp(['BW: ' num2str(meanBW)])
disp(['LCO: ' num2str(meanLowCutOff6dB)])
disp(['HCO: ' num2str(meanHighCutOff6dB)])
disp(['voltage: ', voltage])
cc = clock;
data_time = [ num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) ] ;

save( [ file_prefix '_' voltage 'V_' matching_value 'uH_' data_time '.mat' ], 'perChannelData','infoStruct' , 'Charac', 'stat');

