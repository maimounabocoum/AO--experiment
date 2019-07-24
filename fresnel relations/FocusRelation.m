%%% choose lens focal

% relation of conjugated plane :

% w0' = (lambda*f)/(pi*w0)
clearvars


lambda = 780e-9;
f = (1:1:100)*1e-2 ;
d0 = 20e-3;

d0_p = 2*(lambda*f)/(pi*(d0/2));

figure(3);
plot(f*1e3,d0_p*1e6)
xlabel('focal(mm)')
ylabel('beam size(\mu m)')

% Zr = pi*(d0/2)^2/lambda