function [amp, phi] = find_amp_phase(signal, fs, f0, time_cursor)
% output
% amp = amplitude du signal
% phase = phase du signal
% signal = signal temporel a analyser
% fs = frequence d'echantillonnage [Hz]
% f0 = frequence centrale du burst sinusoidal [Hz]
% time_cursor = vecteur 2*1 donnant le debut et la fin de la fenetre
% temporelle a analyser dans le signal [s]

signal_window = signal(round(time_cursor(1)*fs):round(time_cursor(2)*fs));
t = 0:1/fs:length(signal_window)/fs;
t = t(1:length(signal_window));
cos_fun = cos(2*pi*f0*t);
sin_fun = sin(2*pi*f0*t);
normalisation=2/length(signal_window);
an = normalisation*(sum(signal_window.*cos_fun));
bn = normalisation*(sum(signal_window.*sin_fun));
amp = abs(an + sqrt(-1)*bn);
phi = angle(an + sqrt(-1)*bn);



end

