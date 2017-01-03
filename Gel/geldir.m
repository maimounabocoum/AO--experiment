function [massAgar,massIntralipid,massInkSolution,massWater]=geldir(lambda,Youngmodulus,mu_sprime,mu_a,massGel)

%units convention
%lambda           en nm  (valid for 400 nm < lambda < 1100 nm)
%concAgar         en pourcentage massique
%concIntralipid   en pourcentage massique
%Youngmodulus  en kPa
%mu_sprime        en cm^-1
%mu_a             en cm^-1
%masse de gel     en mg



% Système d'équations

%équation d'élasticité  Hall, et al., Phantom Materials for Elastography,
%IEEE UFFC, 1997:

concAgar=(Youngmodulus/142176)^(1/1.87);

%équation de diffusion  van Staveren, et al., Light scattering in
%Intralipid-10% in the wavelength range of 400-1100 nm, AO, 1991:
g = 1.1-0.00058*lambda;
mu_agarfactor=1-2.6038*concAgar^(0.4948);
mu_sprimeuncorrected=mu_sprime/mu_agarfactor;
mu_s=mu_sprimeuncorrected/(1-g);

concIntralipid=mu_s/(2.536*10^(9)*lambda^(-2.4));

%équation d'absorption  Linear absorption. Stock solution equation obtained
%by curve-fitting on absorption spectrum of the stock solution:
mu_astocksolution=12.18; %log(10)*(1.97*10^(7)*lambda^(-1.889)+45);

concInkSolution=mu_a/mu_astocksolution;

%équation aux masses

massAgar=massGel*concAgar;
massIntralipid=massGel*concIntralipid;
massInkSolution=massGel*concInkSolution;
massWater=massGel*(1-concIntralipid-concAgar-concInkSolution);

