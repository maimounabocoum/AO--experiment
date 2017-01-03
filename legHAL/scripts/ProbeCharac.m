

% clear all

AixplorerIP = '192.168.3.182';
% Select probe
probe = 'SPA5_1'; %probe = 'SPA5_1'

% Output file name
file_prefix = 'charac_HumanScan_3PCX_V2_reworked_0uH_9MHz_1hc_10V';


elementsVector = 1:96;
elementsVectorSize = length(elementsVector);

if (strcmp(probe, 'SL15_4') == 1)
    Cano.NPiezos        = 256;
    Cano.acqDuration    = 50;   % µs unit
    Cano.RXSamplingRate = 30;   % MHz unit
    Cano.TXFreq         = 7.5   % MHz unit
    Cano.TGCValue       = 350;
    nbIter         = 8;
elseif  (strcmp(probe, 'SPA5_1') == 1)
    Cano.NPiezos        = 96;
    Cano.acqDuration    = 400;  % µs unit
    Cano.RXSamplingRate = 60;   % MHz unit
    Cano.TXFreq         = 3  %MHz unit
    Cano.TGCValue       = 300;
    nbIter         = ceil(Cano.NPiezos / elementsVectorSize );
else
    disp([probe ' probe not supported yet']);
end

Repeat_seq = 1;

Cano.RxDelay = 0;
Cano.TxDelays = 0;
Cano.NbHcycle = 1;
Cano.RxDuration = Cano.acqDuration;
Cano.RxFreq = Cano.RXSamplingRate;
Cano.TwFreq = Cano.TXFreq;
Cano.TGC = Cano.TGCValue;
Cano.DutyCycle = 1;
Cano.Voltage = 10;

RxElemts = 1:Cano.NPiezos;

clear rfData
for k=1:nbIter
    TxElemts = elementsVector; 

    % Create canonical elusev
    % ELUSEV = elusev.hadamard( 9MHz...
    ELUSEV = elusev.canonical( ...
        'TrigIn', 0, ...
        'TrigOut', 0, ...
        'TrigAll', 0, ...
        'TxElemts', TxElemts, ...
        'TxDelays', Cano.TxDelays, ... % scalar: all, vector: size of TxElemts
        'TwFreq', Cano.TwFreq, ...
        'NbHcycle', Cano.NbHcycle, ...
        'Bandwidth', -1, ...
        'DutyCycle', Cano.DutyCycle, ...
        'RxElemts', RxElemts, ... % -1: emitting element, 0: all, [...]>0 only given elements
        'RxFreq', Cano.RxFreq, ...
        'RxDelay', Cano.RxDelay, ...
        'RxDuration', Cano.RxDuration, ...
        'VGAInputFilter', 0, ... 3=voltage, 0=impedance, ... % 3*voltage_measurement, ...
        'QFilter', 1, ...
        'Bandwidth', -1, ...
        'Pause', 20, ...
        'Repeat', 1, ...
        'PauseEnd', 8, ...
        0);

    % ACMO for the sequence
    ACMO = acmo.acmo( ...
        'elusev', ELUSEV, ...
        'ControlPts', Cano.TGC, ...
        0);

    % USSE for the sequence
    SEQ = usse.usse( ...
        'acmo', ACMO, ...
        ... 'Repeat', Repeat_seq, ...
        'TPC', remote.tpc('imgVoltage', Cano.Voltage, 'imgCurrent', 1), ...
        'Popup',0, ...
        0);

    % Build remote structure
    [Sequence NbAcq] = SEQ.buildRemote();

    % Sequence execution

    % Initialize & load sequence remote
    Sequence = Sequence.initializeRemote( 'IPaddress', AixplorerIP, 'InitTGC',Cano.TGC, 'InitRxFreq',Cano.RxFreq );
    Sequence = Sequence.loadSequence();

    clear buf_tmp
    clear buf
    for r = 1:Repeat_seq
        % Start sequence
        Sequence = Sequence.startSequence( 'Wait', 1 );

        % Retrieve data
        disp( 'getting data' )
        tic
        for k = 1 : NbAcq
            buf_tmp(r,k) = Sequence.getData( 'Realign', 2 ); %, 'RxChans', RxElemts );
        end
        toc

        % Stop sequence
        Sequence = Sequence.stopSequence( 'Wait', 1 );
    end

    r=1;
    buf_tmp2 = buf_tmp(r).RFdata(200:end-128,:,1:2:end) + buf_tmp(r).RFdata(200:end-128,:,2:2:end);

    buf = zeros(size(buf_tmp2));
    for r = 1:Repeat_seq
        buf_tmp2 = buf_tmp(r).RFdata(200:end-128,:,1:2:end) + buf_tmp(r).RFdata(200:end-128,:,2:2:end);
        buf = buf + double(buf_tmp2);
    end
    buf = buf / Repeat_seq;
    clear buf_temp3
    for k=1:elementsVectorSize
        buf_temp3(:,k) = squeeze(buf(200:end,k,k));
    end
    rfData(:, elementsVector) = buf_temp3;
    elementsVector = elementsVector+elementsVectorSize;
end
%%
freqMin = 0.5; % MHz
temporalWindowDuration = 5; % µs
temporalWindowLength = temporalWindowDuration*Cano.RXSamplingRate; % sample unit
offset = 1000;
validChannel = max(abs(rfData(offset:end, :)))>0.7*mean(max(abs(rfData(offset:end, :))));

% Compute per element spectrum
Hs=spectrum.mtm(1.5);
clear spectr
for k=1:Cano.NPiezos
    if validChannel(k)
        [vmax posmax] = max(abs(rfData(offset:end,k)));
        pulse = rfData(offset+posmax-ceil(temporalWindowLength/2):offset+posmax+ceil(temporalWindowLength/2),k);
        h=psd(Hs, pulse, 'Fs', Cano.RXSamplingRate);
        validFreqIndex = find(h.Frequencies>freqMin);
        firstFreqIndex = validFreqIndex(1);
        freqAxis = h.Frequencies(firstFreqIndex:end);
        spectr(:,k) = h.Data(firstFreqIndex:end);
        [vMax freqCentroid] = max(spectr(:,k)); %round(sum((1:length(freqAxis))'.*spectr(:,k).*spectr(:,k))/sum(spectr(:,k).^2));
        centerfreqSpectrumValue = spectr(freqCentroid,k);
        mainLobeBuffer = find(spectr(:,k)>0.5*centerfreqSpectrumValue);
        lowCutOffFreq(k)  = freqAxis(mainLobeBuffer(1));
        highCutOffFreq(k) = freqAxis(mainLobeBuffer(end));
        centerFreq_6dB(k) = 0.5*(lowCutOffFreq(k) + highCutOffFreq(k));
        fractionalBandwidth(k) = 100*(highCutOffFreq(k)-lowCutOffFreq(k))/centerFreq_6dB(k);
    else
        if (exist('spectr'))
            spectr(:,k) = 0;
        end
        lowCutOffFreq(k)  = 0;
        highCutOffFreq(k) = 0;
        centerFreq_6dB(k) = 0;
        fractionalBandwidth(k) = 0;
    end
end

stat(1) = round(100*mean(centerFreq_6dB(validChannel)))/100;
stat(2) = round(mean(fractionalBandwidth(validChannel))) ;
stat(3) = round(100*max(centerFreq_6dB(validChannel)))/100;
stat(4) = round(max(fractionalBandwidth(validChannel)));
stat(5) = round(100*min(centerFreq_6dB(validChannel)))/100;
stat(6) = round(min(fractionalBandwidth(validChannel)));

disp(['Average -6dB center frequency : ' num2str(stat(1)) 'MHz'])
disp(['Average fractional bandwidth  : ' num2str(stat(2)) '%'])
disp(['Max -6dB center frequency     : ' num2str(stat(3)) 'MHz'])
disp(['Max fractional bandwidth      : ' num2str(stat(4)) '%'])
disp(['Min -6dB center frequency     : ' num2str(stat(5)) 'MHz'])
disp(['Min fractional bandwidth      : ' num2str(stat(6)) '%'])
fprintf('\n')
disp(['Meas. voltage: ', num2str(Cano.Voltage), ' V'])
disp(['Meas. nb hc: ', num2str(Cano.NbHcycle)])
disp(['Meas. tx freq: ', num2str(Cano.TXFreq), ' MHz'])
disp(file_prefix)
cc = clock;
data_time = [ num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(cc(6)) ] ;

save( [ file_prefix '_' data_time '.mat' ], 'Cano', 'Sequence', 'rfData', 'spectr', 'lowCutOffFreq', 'highCutOffFreq', 'centerFreq_6dB', 'fractionalBandwidth', 'stat' );

return

%%
close all 
figure; plot(rfData(offset+posmax-ceil(temporalWindowLength/2):offset+posmax+ceil(temporalWindowLength/2),30))
pause()
figure; plot(freqAxis,20*log10(abs(spectr(:, 36)))); xlim([0 10])
pause()
close all
figure; plot(rfData(:, 36))
pause() 
close all
figure; imagesc(rfData); ylim([2200 2500])
pause()
close all