%% routine which mimics input references inside AWG

%% ---------------- matlab coerce coefficient --------------

% this function accounts for different constraits inherent to AWG
% granularity and size
f0      = 6e6; % input US frequency
DurWav  = 20e-6 ; % fundamental duration for waveform

f_ao = 80e6;  % central frequency of AO modulation


Freq_low  = 1/DurWav ;
N1 = round( (f0 + f_ao)/(16*Freq_low) ) ;

Fs    = 64*N1*3*Freq_low ;
f_ch1 = 16*N1*Freq_low  ;
f_ch2 = ( f_ch1 - f0 ) ;


N_low      = Fs/Freq_low ;
Nch1_high = 3*4 ;
Nch2_hight = Fs/f_ch2 ;


%% ------------- encoding to unit patterns --------------------
Nhhg = 1 ;
phaseBasc = 2 ;


t = ( 0:(phaseBasc*N_low-1) ) ;

M_ch1 = (cos( 2*pi*Nhhg*t/N_low ) + 1 )*0.5;
P_ch1 = exp( 2*1i*pi*t/Nch1_high);
P_basc = sign( cos( 2*pi*Nhhg*t/(phaseBasc*N_low) ) );
P_ch2 = exp( -2*pi*1i*t./Nch2_hight );

figure(1);
subplot(121)
plot(1e6*t/Fs, real(M_ch1.*P_ch1.*P_basc) );
xlabel('time (\mu s)')
subplot(122)
plot(1e6*t/Fs,angle( P_ch1.*P_basc.*P_ch2 ),'linewidth',2);
xlabel('time (\mu s)')

% 
% %% simple illustration of periodic bound conditions :
% N = 50 ;
% t = 0:(N-1) ;
% f = 2/(N) ;
% S = sin(2*pi*f*t);
% figure(2)
% plot(repmat(S,1,2),'-o','linewidth',3)




