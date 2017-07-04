function Mat = CalcMatHole(f0,f,nuX,X);
% f0 (en MHz) est la fréquence de porteuse,  f (en Hz) la fréquence de modulation de phase

Tmax = 20.1;  % durée maximale d'un cycle élémentaire (en us)
Fe = 180; % Fréquence d'échantillonnage en MHz

T = 1e6/f;
if (T>Tmax) % si la période de la modulation de phase est plus grande que Tmax --> Manip impossible
   Mat = zeros(size(X));
   return;
end;

N = floor(Tmax/T); %on essaie de se rapprocher au mieux de Tmax
Nech = round(N*T*Fe); % Nombre d'échantillons effectivement utilisés

Tot = Nech/Fe; % durée totale de la séquence à répéter 

  if (T ~= Tot/N)
      d = 999
  end

T = Tot/N; % ré-ajustement de la période
f = 1.0/T; % ré-ajustement de la fréquence (en MHz)

k = floor(Tot*f0); % nombre de cycles porteuse
 if (f0 ~= k/Tot)
      d = 88888888888
  end
f0 = k/Tot; % ré-ajustement de la fréquence porteuse

t = (0:Nech-1)/180; % Echelle de temps;
s0 = sin(2*pi*f0*t); %porteuse
tT = t'*ones(1,length(X));
tX = nuX*ones(length(t),1)*X/f;
ts0 = s0'*ones(1,length(X));

Mat = sign(ts0).*(sin(2*pi*f*(tT-tX))>0);
    