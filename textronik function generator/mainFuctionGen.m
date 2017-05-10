%%% here is the routine to generate a function
clearvars

%=========== create fourier parameters ================%
N = 2^12;
Fmax = 100e6; 
fs = 100e6; % sampling frequency 
F = TF_t(N,Fmax) ;

%================= generate carrier frequency wave ====%
Fwaveform = 1e6;
WavformAmpl = 200; % in mVolt
waveform = WavformAmpl*cos(2*pi*Fwaveform*F.t);

 %=============== generate gaussian noise============%
 
 noiseBW = 500e3; % noise bandwith frequency in Hz
 Dist = exp(-(F.f).^2/noiseBW^2);
 NoisePhase = 4*pi*rand(1,length(Dist));
 NoiseVolt  = 20; % in mVolt 
 
%  figure;
%  plot(1e3*F.f,Dist)
%  xlabel('frequency (kHz)')
%  ylabel('Volt')
%  
 TemporalNoise = F.ifourier(Dist.*exp(1i*NoisePhase));

 figure;
 subplot(121)
 plot(F.t*1e6, NoiseVolt*real(TemporalNoise)/max(abs(TemporalNoise)))
 xlabel('time (\mu s)')
 ylabel('mVolt')
 subplot(122)
 plot(F.t*1e6,waveform+NoiseVolt*real(TemporalNoise)/max(abs(TemporalNoise)))
 hold on 
 plot(F.t*1e6,waveform,'red')
 xlabel('time (\mu s)')
 ylabel('waveform')
%========================= saving file to text format===================

% fileID = fopen('GeneratedWave.txt','w');
% fprintf(fileID,'%6s %12s\n','x','y');
% fprintf(fileID,'%6.2f %12.8f\n',[x,y]);
% fclose(fileID);

