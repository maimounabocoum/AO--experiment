function [t, Mat] = CalcMatBas(f0,Fe, seq_time, sequence)
% c input in m/s
% f0  (en MHz) est la fréquence de porteuse
% nuZ (en mm-1)
% nuX (en mm-1)
% Fe        : sampling frequency of Aixplorer in MHz ;
% x         : coordinate vector in mm
% tau_cam   : camera integration time in s;
 
% conversion of all input to SI units :
 
Fe = Fe*1e6 ;           % MHz->Hz
dt  = 1/Fe ;             % in s
f0 = f0*1e6;
N = floor(seq_time/dt)

z_time = 5e-6;
padding_starts = [floor(N/3) floor(2*N/3)];

disp('Generating US sequence for N =')
disp(N)

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

%% Padding zeroes for reset
z_steps = floor(z_time/dt);

padding_starts = [padding_starts floor(N)];
padding = ones(1, padding_starts(1));
for i = 1:length(padding_starts) - 1
    padding = [padding zeros(1, z_steps) ones(1, padding_starts(i+1) - padding_starts(i) - z_steps)];
end
padding = transpose(padding);
plot(padding);
%%

Mat = zeros(length(t), 192);

for y = 1:192
    Mat(x, y) = sign(sequence) * padding;
end
%% print matrix
figure(100)
        %imagesc(Mat);
      	%xlabel('x (mm)')
        %ylabel('z(mm)')
        %drawnow

end

