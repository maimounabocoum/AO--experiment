function [ t, Mat ] = CalcMatSharp(f0, Fe, seq_time)
%CALCMATSHARP Computes the Aixplorer matrix input for the frequency shaft
%   f0 (MHz) is the carrier frequency
%   Fe (MHz) is the sampling frequency
%   seq_time (s) is the sequence time

% MHz -> Hz
f0 = f0 * 1e6;
Fe = Fe * 1e6;

dt  = 1/Fe ;             % in s
N = floor(seq_time/dt);
NP = floor(seq_time * f0); % Number of signal periods
N_period = floor(Fe/f0); % Number of points in a period of signal
disp(NP);

% Sequence loading
ENABLE_SEQ_LOADING_FROM_FILE = false;
sequenceFile = 'sequence_sharp.txt';

z_time = 5e-6;
padding_starts = [floor(NP/3) floor(2*NP/3)];

t = (0:N-1)*dt;  % time in us

min_freq = f0;
max_freq = 10e6;

if(exist(sequenceFile, 'file') == 2 && ENABLE_SEQ_LOADING_FROM_FILE) % Using saved sequence
    % Loading sequence time, padding starts, padding duration, minimum
    % frequency, maximum frequency
    
    
end

%% Padding zeroes for reset
z_steps = floor(z_time/dt);

padding_starts = [padding_starts floor(NP)];
padding = ones(1, N_period*padding_starts(1));
for i = 1:length(padding_starts) - 1
    padding = [padding zeros(1, z_steps) ones(1, N_period*padding_starts(i+1) - N_period*padding_starts(i) - z_steps)];
end

f = linspace(min_freq, max_freq, N);
Mat = zeros(length(t), 192);
for y = 1:192
    Mat(:, y) = sign(sin(2*pi*f.*t) .* padding); % .* is element-wise multiplication (not matrix multiplication)
end

end

