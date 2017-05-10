function [signal,t] = makeGausPulse(fe,f0,T)

% Cree un signal sinusoidal de frequence centrale F_CENTRAL, echantillone à
% FE, de NB_PERIODE, normalisé avec maximum à 1,
%
% FE : frequence d'échantillonage
% F_CENTRAL : frequence centrale du pulse
% TGRID : vecteur temps sur lequel est calculé le signal

f0 = 1.4;
T  = 10;
t0 = T/2;
W  = 1;

t = (0:1/fe:T);

signal = cos(2*pi*f0*t).*exp(-(t-t0).^2./(10*W^2));
signal = signal/max(signal(:));

figure,plot(t,signal);grid
[f,fresu,df]=fft_cal(signal',t,5*length(t),0,10,'flog');

end