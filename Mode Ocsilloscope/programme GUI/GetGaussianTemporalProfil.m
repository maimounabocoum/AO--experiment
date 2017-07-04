% chirp donné en fs^2
% tau12 : durée de l'impulsion à 1/e2 donné en fs
% tau définie l'impulsion gaussienne : I = exp(t^2/tau^2)

function [t It] = GetGaussianTemporalProfil(fwhm,phi2)

% définition du chirp normalisé

tau0 = fwhm/(2*sqrt(log(2)));


xi = phi2/tau0^2;





t = linspace(-100,100,2^10);

tau = tau0*sqrt(1+xi^2);
It = exp(-t.^2/tau^2);











end