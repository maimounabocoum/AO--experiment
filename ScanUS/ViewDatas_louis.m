
%% read saved datas
Hf = figure;
set(Hf,'WindowStyle','docked'); 
D=[1 1 1;0 0 1;0 1 0;1 1 0;1 0 0;];
F=[0 0.25 0.5 0.75 1];
G=linspace(0,1,256);
cmap=interp1(F,D,G);
colormap(hot)


%imagesc(MyScan.Datas )
figure,plot(envelope(MyScan.Datas(:,1)))
signal=MyScan.Datas(:,1)
power=signal.^2
%[a,b]=envelope(power(:),300)
figure,plot(abs(hilbert(power,1000)))


t = 0:1e-4:0.1;
x = (1+cos(2*pi*50*t)).*cos(2*pi*1000*t);

plot(t,x)
xlim([0 0.04])
[up,lo] = envelope(x);
hold on
plot(t,up,t,lo,'linewidth',1.5)