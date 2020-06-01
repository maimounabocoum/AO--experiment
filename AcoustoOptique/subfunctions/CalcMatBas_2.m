function [t, Mat] = CalcMatBas(f0,Fe, seq_time)
% c input in m/s
% f0  (en MHz) est la fréquence de porteuse
% nuZ (en mm-1)
% nuX (en mm-1)
% Fe        : sampling frequency of Aixplorer in MHz ;
% x         : coordinate vector in mm
% tau_cam   : camera integration time in s;
 
% conversion of all input to SI units :
set(0,'DefaultFigureVisible','on');
fprintf('Sequence time is %f, Fe = %f MHz, fo = %f MHz\n', seq_time, Fe, f0);

Fe = Fe*1e6 ;           % MHz->Hz
dt  = 1/Fe ;             % in s
f0 = f0*1e6;
N = floor(seq_time/dt);
NP = floor(seq_time * f0); % Number of signal periods
N_period = floor(Fe/f0); % Number of points in a period of signal
sequenceFile = 'sequence.txt';



tau_carac = 2e-6;
NP_carac = tau_carac * f0; % Number of carac periods for the phase jumps

z_time = 5e-6;
padding_starts = [floor(NP/3) floor(2*NP/3)];

% 2 constraints are imposed on the repeating patter:
% fz*Tot should be integer
% f0*Tot should be integer
% where Tot is the temporal windows of the fondamental pattern
% since Tot = N*(1/Fe)
% this forces the following constraints:
% N*fz0/Fe should be integer
% N*f0/Fe should be integer
 
% consequently, if fz0/Fe and f0/Fe are integers, than:

t = (0:N-1)*dt;  % time in us
Nduree = 50;


phi = zeros(1,N);



y = sin(2*pi*f0*t + phi);


Jumps = [];
if(exist(sequenceFile, 'file') == 2) % Using saved sequence
    disp('Found sequence file, loading from it.');
    fileId = fopen(sequenceFile);
    line = fgetl(fileId);
    while ischar(line)
        Jumps = [Jumps str2double(line)];
        line = fgetl(fileId);
    end
    fclose(fileId);

else % Generating sequence instead
    disp('No sequence file detected, generating sequence...');
    % Generating jumps
    rng(0, 'twister');
    total_periods = 0;
    Jumps = 1;
    while total_periods + NP_carac + 1 < NP
        r = floor(rand() * NP_carac) + 1; %+1 period if rand is 0 : we want at least one period of signal
        Jumps = [Jumps r];
        total_periods = total_periods + r;
    end
    Jumps = [Jumps NP - total_periods]; % Finish the jump sequence with the only what's left (overflow security)
end
    %% Padding zeroes for reset
    z_steps = floor(z_time/dt);

    padding_starts = [padding_starts floor(NP)];
    padding = ones(1, N_period*padding_starts(1));
    for i = 1:length(padding_starts) - 1
        padding = [padding zeros(1, z_steps) ones(1, N_period*padding_starts(i+1) - N_period*padding_starts(i) - z_steps)];
    end
    
    disp(size(padding));
    disp(N);
    
    %% Loading from jump sequence

    Mat = zeros(length(t), 192);
    t_base = (0:N_period - 1);  % Points for one period of signals
    signal = [];
    phi = [];
    
    state = false; % false is base, true is oppos
    for i = 1:length(Jumps)
        %fprintf('%i to %i\n', Jumps(i-1), Jumps(i));
        for j = 1:Jumps(i)
            signal = [signal sin(2*pi*t_base/N_period + state*pi)];
        end
        state = not(state);
    end
    disp(size(signal));
    figure(1);
    %plot(t, signal, 'color', [1, 0, 0]);
    
    for y = 1:192
        Mat(:, y) = sign(signal .* padding); % .* is element-wise multiplication (not matrix multiplication)
    end
    %% print matrix
    %figure(100)
            %imagesc(Mat);
            %xlabel('x (mm)')
            %ylabel('z(mm)')
            %drawnow

    %% save into file
    fileId = fopen(sequenceFile, 'w');
    fprintf(fileId, '%i\n', length(padding_starts));
    fprintf(fileId, '%i\n', padding_starts);
    fprintf(fileId, '%i\n', Jumps);
    fclose(fileId);

end