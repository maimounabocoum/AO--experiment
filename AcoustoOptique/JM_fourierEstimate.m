%% simulation of fourier traces :
        NbZ         = 3;     % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 3;     % 20 Nb de composantes de Fourier en X, 'JM'
        DurationWaveform = 20;
      
        FT = fft2(Datas) ;
        
        for nbs = 1:Nfrequencymodes
    
        nuZ  = NBZ(nbs)*nuZ0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % nuZ : en mm-1
        % nuX : en mm-1
        [nuX,nuZ,~,Waveform] = CalcMatHole(f0,nuX,nuZ,Xs,SampFreq,c); % Calculer la matrice
        
        
        end