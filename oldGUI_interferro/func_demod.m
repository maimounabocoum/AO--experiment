function [u,v] = func_demod(Fe,signal,N)
Npts = length(signal) ;    % nbre de points

u=zeros(N,Npts);
v=zeros(N,Npts-1);

fp = 69.99965;    % fréquence de la porteuse (MHz)
bp = 80 ;         % bande passante filtre appliqué à la porteuse avant démodulation


for imoy=1:N

tps=[0:1./Fe:(Npts-1)/Fe];


Nmin = round(Npts*(fp-bp/2)/Fe) ;
Nmax = round(Npts*(fp+bp/2)/Fe) ;

if (Fe/2)<fp
    disp('error ! Shannon non respecté')
end;
% sa=signal analytique
sa = hilbert(signal) ;  

sref = exp(-1i*2*pi*fp*tps) ;

dep_comp = sa.*sref.' ;
intermediaire = unwrap(angle(dep_comp)) ;
u(imoy,:) =633/(4*pi)*(intermediaire-mean(intermediaire)) ; %==> en nm
% 633nm correspond à la longueur d'onde laser du laser utilisé
% 4pi pour passage vecteur d'onde longueur d'onde et le 2 pour l'aller
% retour laser (vient de la forme phi=2*K*u(t))
% v(imoy,:) = diff(u(imoy,:)).*Fe ; %==> nm/us ==> 10-6 mm/us ==> 10-3 m/s

u = -u; % inversion du signal sinon pressions neg/pos inversees !

u=mean(u,1);
v=mean(v,1);

end;
end

