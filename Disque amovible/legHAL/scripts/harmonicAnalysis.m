% Probe Charac main script

Charac.AixplorerIP = 'local'%'192.168.3.182';
% Select probe
probe = 'SC6_1'; %probe = 'SPA5_1'


if (strcmp(probe, 'SL15_4') == 1)
    Charac.NPiezos        = 256;
    Charac.RxDuration     = 200;
    Charac.TGC            = 350;
elseif  (strcmp(probe, 'SPA5_1') == 1)
    Charac.NPiezos        = 96;
    Charac.RxDuration     = 300;
    Charac.TGC            = 800;
elseif  (strcmp(probe, 'SC6_1') == 1)
    Charac.RxDuration     = 300;
    Charac.NPiezos        = 192;
    Charac.TGC            = 800;
else
    disp([probe ' probe not supported yet']);
end

Charac.NbAcq  = 1;
Charac.Voltage = 70;
Charac.RxFreq = 30;   % MHz unit
Charac.RxDelay = 0;
Charac.Pause = 200;
Charac.PauseEnd = 2000;

% TX parameters
txFrequ          = 1.875; % MHz
nbHalfCycles     = 3;
masterClockFrequ = 180; %MHz
dutyCycle        = 0.8;

% Waveform generation
nbTicksPerHalfcycle = floor(masterClockFrequ / txFrequ / 2);
nbHighTicksPerHalfCycles = floor(nbTicksPerHalfcycle*dutyCycle);
elementaryWaveform = zeros(1,nbTicksPerHalfcycle);
nbLowTicksPerHalfCycles = nbTicksPerHalfcycle - nbHighTicksPerHalfCycles;
elementaryWaveform(ceil(nbLowTicksPerHalfCycles/2):floor(nbLowTicksPerHalfCycles/2)+nbHighTicksPerHalfCycles) = 1;
waveform = [];

for k=1:nbHalfCycles
    waveform = [waveform (-1)^k*elementaryWaveform];
end

nbActiveElements = 16;

for k=1:nbActiveElements*2
    Charac.CharactElements(k) = ceil((Charac.NPiezos-nbActiveElements)/2+k/2);
    Charac.Waveform(k,:) = (-1)^k*waveform;
end

[perChannelData infoStruct] = scripts.AcqProbeCharac(Charac);

posChannelData = perChannelData(:, 1:2:end);
negChannelData = perChannelData(:, 2:2:end);

harmChannelData = posChannelData+negChannelData;

