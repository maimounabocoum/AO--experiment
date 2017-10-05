function [NUX,NUZ] = evalNUs(NbX,NbZ,f0,SampFreq)

Nbtot    = 128 ;
pitch = 0.2;
c = 1540 ;

Xs        = (0:Nbtot-1)*pitch;             % Echelle de graduation en mm
DurationWaveform = 20;

nuZ0 = 1/((c*1e3)*DurationWaveform*1e-6);  % Pas fréquence spatiale en Z (en mm-1)
nuX0 = 1.0/(Nbtot*pitch);                  % Pas fréquence spatiale en X (en mm-1)
[NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
% initialization of empty frequency matrix
NUX = zeros('like',NBX); 
NUZ = zeros('like',NBZ); 


Nfrequencymodes = length(NBX(:));

Nfrequencymodes = length(NBX(:));

for nbs = 1:Nfrequencymodes
    
        nuZ  = NBZ(nbs)*nuZ0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % nuZ : en mm-1
        % nuX : en mm-1
        [nuX,nuZ,~,~] = CalcMatHole(f0,nuX,nuZ,Xs,SampFreq,c); % Calculer la matrice
        % upgrade frequency map : 
        NUX(nbs) = nuX ;
        NUZ(nbs) = nuZ ;
end


end





