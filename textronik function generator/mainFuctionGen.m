%%% here is the routine to generate a function
clearvars

%=========== create fourier parameters ================%
N = 2^12;
Fmax = 100e6; 
F = TF_t(N,Fmax) ;
%=============== generate gaussian noise============%
 
 noiseBW = 100e3; % noise bandwith frequency in Hz
 Dist = exp(-(F.f).^2/noiseBW^2);
 NoisePhase = 2*pi*rand(1,length(Dist));
 NoiseVolt  = 20; % in mVolt 
   
 TemporalNoise = F.ifourier(Dist.*exp(1i*NoisePhase));

 figure;
 plot(F.t*1e6, NoiseVolt*real(TemporalNoise)/max(abs(TemporalNoise)))
 xlabel('time (\mu s)')
 ylabel('mVolt')

%=============================== generation du signal à frequence Fe %===========
 fe   = 100e6;       % sampling frequency 
 tmax = 20e-6;      % temporal window 
 time = 0:(1/fe):tmax ;
 
%================= generate carrier frequency wave ====%
Fwaveform = 0.1e6;
WavformAmpl = 200; % in mVolt
waveform = WavformAmpl*cos(2*pi*Fwaveform*time);
 
 figure;
 plot(time*1e6,waveform)
 xlabel('time (\mu s)')
 ylabel('mVolt')
 
 
 