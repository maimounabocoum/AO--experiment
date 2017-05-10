function [signal, signalTgrid] = makeSinPulse(fe, f_central, dureeSignal)

% Cree un signal sinusoidal de frequence centrale F_CENTRAL, echantillone à
% FE, de NB_PERIODE, normalisé avec maximum à 1,
%
% FE : frequence d'échantillonage
% F_CENTRAL : frequence centrale du pulse
% TGRID : vecteur temps sur lequel est calculé le signal

signalTgrid = (0:1/fe:dureeSignal);

signal = sin(signalTgrid*2*pi*f_central).*hanning(length(signalTgrid))';
signal = signal/max(signal(:));

ls = length(signal);

end