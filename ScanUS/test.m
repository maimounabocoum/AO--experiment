%%

N = 2048;
df = (SampleRate*1e6)/N;
dt = 1/(SampleRate*1e6);
f = (0:(N-1))*df ;
t = (0:(N-1))*dt ;

s = MyScan.Datas(5000+ (1:N));
s_fft = fft(s);

figure;plot(abs(s_fft))
% filtre donnée
s_fft1 = 0*s_fft;
s_fft2 = 0*s_fft;
s_fft1(160:260) = s_fft(160:260);
s_fft2(350:460) = s_fft(350:460);
s1 = ifft(s_fft1);
s2 = ifft(s_fft2);

f01 = trapz(f,f.*abs(s_fft1').^2)/trapz(f,abs(s_fft1').^2);
f02 = trapz(f,f.*abs(s_fft2').^2)/trapz(f,abs(s_fft2').^2);



figure;plot( t*1e6 , unwrap(angle(s1'.*exp(1i*2*pi*f01*t)))/pi )
hold on;plot( t*1e6 , 1 + unwrap(angle(s2'.*exp(1i*2*pi*f02*t)))/pi )