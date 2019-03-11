function [nuX,nuZ,t,Mat] = CalcMatHole_OC(f0,nuX,nuZ,x,Fe,c)

% this function can be evaluated using testsheet script

% c input in m/s
% f0  (en MHz) est la fréquence de porteuse
% nuZ (en mm-1)
% nuX (en mm-1)
% Fe : sampling frequency in MHz ; 
% x  : coordinate vector in mm

% conversion of all input to SI unitzs : 
Fe = Fe*1e6 ;   %MHz->Hz
f0 = f0*1e6;    %MHz->Hz
nuZ = 1e3*nuZ ; %mm-1->m-1
nuX = 1e3*nuX ; %mm-1->m-1
x = x*1e-3;     %mm->m

% conversion to temporal frequency along z
fz = c*nuZ ;

dt = 1/Fe ; % in s
Tmax = (20.1*1e-6); % periode maximale d'un cycle élémentaire (en s)

Tz = 1/fz;          % periode de l'envelloppe A in s
T0 = 1/f0;          % periode de la porteuse A in s

% si la période de la modulation de phase est plus grande que Tmax --> Manip impossible
% (à remplacer par une exception..)
if (Tz>Tmax) 
   Mat = zeros(size(X));
   return;
end;


Nrep = floor(Tmax/Tz);    % on essaie de se rapprocher au mieux de Tmax (essentially Nrep = 1 for fundamental)
N = round(Nrep*(Tz/dt));  % Nombre de point effectifs

Tot = N*dt;        % durée totale de la séquence



Tz = Tot/Nrep;    % ré-ajustement de la période ??
fz = 1/Tz        % ré-ajustement de la fréquence (en MHz) ??
nuZ = fz/c ;

k = floor(Tot/T0); % nombre de cycles porteuse

  
f0 = k/Tot; % ré-ajustement de la fréquence porteuse
t = (0:N-1)*dt;  % time in us

[X,T] = meshgrid(x,t);

% need a periodic T to lock the phase
T_periodic = Tz*( (sawtooth(2*pi*fz.*T)+1)/2 );

chirp = 100e3;   % Hz
tau = 200e-6;  % s

PHI2 = chirp/tau ;

Phi = 2*pi*(f0*T + PHI2*T_periodic.^2) ;

carrier = sin(Phi);

Mat = sign(carrier).*(sin(2*pi*nuX*X)>0);

% convert m-1->mm-1
nuZ = 1e-3*nuZ;
nuX = 1e-3*nuX;

% print matrix
figure(100)
        imagesc(carrier)
        xlabel('x (piezo)')
        ylabel('z (index)')
        drawnow
        cb = colorbar ;
        colormap(parula)
end
    