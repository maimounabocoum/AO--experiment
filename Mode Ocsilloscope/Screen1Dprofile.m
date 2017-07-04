function [] = Screen1Dprofile(FigHandle ,x,y)

%   set figure properties :
set(FigHandle,'name','1D data analysis');
set(FigHandle,'NextPlot', 'replace'); 

subplot(121)
plot(x,y)
hold on 
ysmoothed = smooth(y,10);
plot(x,ysmoothed,'color','red')
% ylim([0  0.1e-3]+5.6e-3)
xlabel('x(mm)')
ylabel('tension (V)')

% SNR calculation :
signalPow = rssq(y(:)).^2;
noisePow  = rssq(ysmoothed(:) - y(:)).^2;
r = 10*log10(signalPow/noisePow);
title(['S/N(dB) = ',num2str(r)])

subplot(122)
% historgam of noise differences :
hist(1e3*(ysmoothed(:) - y(:)),50)

title('noise histogram (50bins)')
xlabel('y - y_{smoothed} (mV)')
ylabel('counts')


end

