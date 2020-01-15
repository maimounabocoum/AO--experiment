%% simulation of fourier traces :
        NbZ         = [1,10];     % 8; % Nb de composantes de Fourier en Z, 'JM'
        DurationWaveform = 20;
        SampFreq = 180; % aixplorer sample in MHz
        Nbtot     = 192;
        pitch     = 0.2;
        f0        = 6; % MHz
        X0  = 10;
        X1  = 15;
        Foc = 15;
        c = 1540;
        Xs        = (0:Nbtot-1)*pitch;             % Echelle de graduation en mm

 nuZ0 = (NU_low*1e6)/(c*1e3);                 % Pas fréquence spatiale en Z (en mm-1)
 nuX0 = 1/(Nbtot*pitch);                      % Pas fréquence spatiale en X (en mm-1)

        [NBX,NBZ] = meshgrid(NbX,NbZ);
        % initialization of empty frequency matrix
        NUX = zeros('like',NBX); 
        NUZ = zeros('like',NBZ); 
        Nfrequencymodes = length(NBX(:));
        TxWidth         = Foc/2;           % mm : effective width for focus line

        DelayLaw = sqrt(Foc^2+(TxWidth/2)^2)/(c*1e-3) ...
        - 1/(c*1e-3)*sqrt(Foc^2+((0:pitch:TxWidth)-TxWidth/2).^2);
  
    
        for nbs = 1:Nfrequencymodes
    
        nuZ  = NBZ(nbs)*nuZ0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % nuZ : en mm-1
        % nuX : en mm-1
        [nuZ,~,Waveform] = CalcMat_OFJM(f0,NBZ(nbs),nuZ0,Xs,SampFreq,c,DelayLaw); % Calculer la matrice
        % inducing delay: 
        
        end