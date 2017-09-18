%%
clearvars; 

c = 1450 ;
DurationWaveform = 20 ;
pitch = 0.2e-3;
NbPixels  = 128;                     % nombre de pixels
Xs        = (0:NbPixels-1)*pitch; 
f0 = 2e6;
Lx = (NbPixels*pitch);
Lz = 30 ;
nuZ0 = 2/(50e-3); % Pas fréquence spatiale en Z (en mm-1)
nuX0 = 1/Lx;      % Pas fréquence spatiale en X (en mm-1)
NbX = 3 ;
NbZ = 1 ;
Fe = 180e6 ; % sampling frequency in Hz

[NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);

Nfrequencymodes = length(NBX(:));
MedElmtList = 1:Nfrequencymodes ;

for nbs = 1:Nfrequencymodes
    
        
        nuZ  = NBZ(nbs)*nuZ0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % fz : 
        % nuX : en mm-1

        %Waveform = CalcMatHole(f0,fz,nuX,Xs); % Calculer la matrice
        Waveform = CalcMatHole_V2(Xs,nuX,nuZ,c,f0,Fe); % Calculer la matrice
        imagesc(Waveform)
        drawnow
        pause(1)
       

end

