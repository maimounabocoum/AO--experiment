 addpath('sequences');
 addpath('subfunctions');

%% simulation of fourier traces :
        NbZ         = 11;     % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;     % 20 Nb de composantes de Fourier en X, 'JM'
        DurationWaveform = 20;
        n_low = round( 180*DurationWaveform );
        NU_low = (180)/n_low;    % fundamental temporal frequency
        
        SampFreq = 180; % aixplorer sample in MHz
        Nbtot     = 192;
        pitch     = 0.2;
        f0        = 6; % MHz
        c = 1540;
        Xs        = (0:Nbtot-1)*pitch;             % Echelle de graduation en mm

 nuZ0 = (NU_low*1e6)/(c*1e3);                 % Pas fréquence spatiale en Z (en mm-1)
 nuX0 = 1/(Nbtot*pitch);                      % Pas fréquence spatiale en X (en mm-1)

        [NBX,NBZ] = meshgrid(NbX,NbZ);
        % initialization of empty frequency matrix
        NUX = zeros('like',NBX); 
        NUZ = zeros('like',NBZ); 
        Nfrequencymodes = length(NBX(:));
        
        for nbs = 1:Nfrequencymodes
    
        nuZ  = NBZ(nbs)*nuZ0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % nuZ : en mm-1
        % nuX : en mm-1
        [nuX,nuZ,~,Waveform] = CalcMatHole(f0, NBX(nbs),NBZ(nbs),nuX0,nuZ0,Xs,SampFreq,c); % Calculer la matrice
                
        figure;imagesc(Waveform); colormap(parula)
        end