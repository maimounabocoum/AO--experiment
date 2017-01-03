close all
clear

TwFreq = 6e6;
TxFreq = 60e6;
Ncycles = 2;
Nbele = 192;
% T_x = 1e-3;
% pitch = 0.2e-3;
N_x = 6;

T_Wf = 0:TwFreq/TxFreq:Ncycles;

Wf = sin(2*pi*T_Wf);
Wf_mat1 = zeros(length(Wf),Nbele);
Wf_mat2 = zeros(length(Wf),Nbele);
Wf_mat3 = zeros(length(Wf),Nbele);
Wf_mat4 = zeros(length(Wf),Nbele);

% N_x = round(T_x/pitch);
T_4 = floor(N_x/2);

for kk=1:Nbele
    
    Wf_mat1(:,kk)=(1-2*rem(ceil(kk/N_x),2))*Wf;
    Wf_mat2(:,kk)=(1-2*rem(ceil((kk+T_4)/N_x),2))*Wf;
    Wf_mat3(:,kk)=(1-2*rem(ceil((kk+2*T_4)/N_x),2))*Wf;
    Wf_mat4(:,kk)=(1-2*rem(ceil((kk+3*T_4)/N_x),2))*Wf;
    
end

Wf_mat1(:,(1:floor(Nbele/N_x))*N_x)=0;
Wf_mat2(:,(1:floor((Nbele+T_4)/N_x))*N_x-T_4)=0;
Wf_mat3(:,(2-rem(N_x,2):floor((Nbele+2*T_4)/N_x))*N_x-2*T_4)=0;
Wf_mat4(:,(2:floor((Nbele+3*T_4)/N_x))*N_x-3*T_4)=0;

figure
imagesc(Wf_mat1)
figure
imagesc(Wf_mat2)
figure
imagesc(Wf_mat3)
figure
imagesc(Wf_mat4)