%%% generate signal with arbitrary noise %%%
clearvars;

N = 2^10;    % number of points
Nloop = 100; % number of triggers 

Fe = 10e6;  % sampling frequency in MhZ
c = 1490 ;  % sound velocity in M/s

F = TF_t(N,2*Fe);

S = exp(-F.t.^2/(5e-6)^2);
S_TF = 0*S +1; % mulplied matrix intitialization
Slist = zeros(Nloop,N);
Slist_TF = zeros(Nloop,N);
for loop = 1:Nloop
Slist(loop,:)    =  S + 0*rand(1,1)*sin(loop*F.t*Fe/10) + 0.1*rand(1,N); 
Slist_TF(loop,:) = F.fourier(Slist(loop,:));

S_TF = S_TF.*Slist_TF(loop,:).^2;
plot(Slist(loop,:))
drawnow
end

S_TF = (S_TF).^(1/(2*Nloop));
S_reconstruct= F.ifourier(S_TF);
figure
plot(S_reconstruct)
% hold on 
% plot(S,'-r')




