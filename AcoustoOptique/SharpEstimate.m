 addpath('sequences');
 addpath('subfunctions');

%% simulation of fourier traces :
        NbZ         = 11;     % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;     % 20 Nb de composantes de Fourier en X, 'JM'
        Bascule     = 'off';
        DurationWaveform = 20;
        n_low = round( 180*DurationWaveform );
        NU_low = (180)/n_low;    % fundamental temporal frequency
        
        SampFreq = 180; % aixplorer sample in MHz
        Nbtot     = 192;
        pitch     = 0.2;
        f0        = 6; % MHz
        c = 1540;
        Xs        = (0:Nbtot-1)*pitch;             % Echelle de graduation en mm
        
        seq_time = 40e-6;                        % Sequence time

 nuZ0 = (NU_low*1e6)/(c*1e3);                 % Pas fréquence spatiale en Z (en mm-1)
 nuX0 = 1/(Nbtot*pitch);                      % Pas fréquence spatiale en X (en mm-1)

        [NBX,NBZ] = meshgrid(NbX,NbZ);
        % initialization of empty frequency matrix
        NUX = zeros('like',NBX); 
        NUZ = zeros('like',NBZ); 
        Nfrequencymodes = length(NBX(:));
        

        [~,Waveform] = CalcMatSharp(f0, SampFreq, seq_time); % Calculer la matrice
                
        figure;imagesc(Waveform); colormap(parula)
