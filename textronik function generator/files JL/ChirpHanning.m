function [t,sig,fe,N,t0] = ChirpHanning(duree,f1,f2,option)

% Linear Hanning Chirplet 
% duree (µs)
% fe (MHz)
% f0 (MHz)
% df (MHz)
% [t,sig,fe,N,t0] = ChirpHanning(10,2,0.2,'f');

N  = 2^14;% max 2^15-36; % AFG3101 max 128k
tmin = 0; 
tmax = duree;
t0 = (tmax-tmin)/2; 
dt = (tmax - tmin)/(N-1); 
fe = 1/dt;
t = (tmin:dt:tmax)'; 

% seconde methode
% fe = 100*f0;
% t  = [0:1/fe:duree-(1/fe)]';
% N  = length(t);
% t0 = (t(end)-t(1))/2;
% dt = (t(end)-t(1))/(N-1);

sig = chirp(t,f1,t(end),f2).*hanning(N);
% h = real((pi*s^2)^-0.25*exp(-(t-t0).^2./(2*s^2) + 1i*(2*pi*f0*(t-t0) + b/2*(t-t0).^2)));


if nargin == 4 && option == 'f'
    [f,fresu,df] = fft_cal(sig,t,5*N,0,2*(f2));
    figure('Name','Chirp')
    set(gcf,'Color',[1 1 1]), %set(gcf,'position',[70 687 1162 216])
    subplot 121, plot(t,sig,'k')
    set(gca,'FontSize',18)
    ylabel('Amplitude (V)','FontSize',18)
    xlabel('Temps (µs)','FontSize',18)
    subplot 122, plot(f,dban(abs(fresu)),'k')
    set(gca,'FontSize',18)
    xlabel('Fréquence (MHz)','FontSize',18)
    ylabel('Module (dB)','FontSize',18)
    axis([0 2*f2 -120 0])
end