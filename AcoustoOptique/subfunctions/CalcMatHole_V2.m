function Mat = CalcMatHole_V2(x,fx,fz,c,f0,Fe)
% all input parameters should be in SI unit
% f0 (en MHz) est la fréquence de porteuse,  f (en Hz) la fréquence de modulation de phase
% Fe : sampling frequency in MHe
% Mat(x,t) : emissison matrix 

% definition of initial waveform over one period :
T0 = 1/(c*fz) ;
F0 = 1/T0 ;
N = floor(T0*Fe);

% definition of time vector :
t = (1:N)*(1/Fe) ;
alpha = fx/(fz*c);

% porteuse :
[X,T] = meshgrid(x,t);

Mat = (sin(2*pi*F0*(T - alpha*X)) > 0).*sin(2*pi*f0*T) ;








end
    