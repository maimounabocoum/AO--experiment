%Amaury 11 mai 2010 (basé sur un programme d'Arik sur mathematica)

%% Parametres à changer


%units convention
%lambda           en nm  (valid for 400 nm < lambda < 1100 nm)
%concAgar         en pourcentage massique
%concIntralipid   en pourcentage massique
%Youngmodulus  en kPa
%mu_sprime        en cm^-1
%mu_a             en cm^-1
%masse de gel     en g%

lambda=780;

concAgar=0.0135;
concIntralipid=0.1269;
concInkSolution=0;

Youngmodulus=60;
mu_sprime=10;
mu_a=0;
massGel=220;




%% programme principal (pas besoin de toucher normalement)
rep=input('propriétés physiques (1) sinon nimporte quelle touche\n'); 

if rep==1
%     lambda=input('lambda? (nm)\n');
%     concAgar=input('concentration en agar? (pourcentage massique)\n');
%     concIntralipid=input('concentration en intralipides? (pourcentage massique)\n');
%     concInkSolution=input('concentration en encre? (pourcentage massique)\n');
    
    [Youngmodulus,mu_sprime,mu_a]=gelind(lambda,concAgar,concIntralipid,concInkSolution);
    Youngmodulus
    mu_sprime
    mu_a
else
%     lambda=input('lambda? (nm)\n');
%     Youngmodulus=input('module dYoung? (en kPa)\n');
%     mu_sprime=input('coefficient de diffusion? (en cm^-1)\n');
%     mu_a=input('coefficient dabsorption? (en cm^-1)\n');
%     massGel=input('masse de gel voulue? (en mg)\n');
    
    [massAgar,massIntralipid,massInkSolution,massWater]=geldir(lambda,Youngmodulus,mu_sprime,mu_a,massGel);
    massAgar
    massIntralipid
    massInkSolution
    massWater
end

return
    