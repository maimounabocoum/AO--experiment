%% =============== add subfolders ===============  %%

 addpath('..\..\AO--commons\shared functions folder')
 addpath('gui');
 addpath('sequences');
 addpath('subfunctions');
 
 %% =============== load datas ===============  %%
 
 % data : 13/11/2019:
 importdata('Q:\datas\2019-11-08\Signal_modeTwicking_RepHz_100_17h32_35.mat')
 
 
 %% =============== screen out datas ===============  %%
 PmuW
     h = 6.6e-34;
     lambda = 780e-9;
     Ephoton = h*(3e8/lambda);
 
    Hmu = figure(1);
    % set(Hmu,'WindowStyle','docked');
     
    % raw/(0.45*1e5) unit = W
    [Datas_mu1,Datas_std1,Datas_mu2,Datas_std2] = AverageDataBothWays( raw/(0.45*1e5) );

    mu_short = mean(1e6*Datas_mu1)
    mu_long = mean(1e6*Datas_mu2)
    Sig_short = mean(1e6*Datas_std1)
    Sig_long = mean(1e6*Datas_std2)
    
% mu   = [5.5134   11.4693 14.7709 17.6676  17.9219 22.5880 25.4040 29.4386 35.6482] ;
% sig1 = [0.0454 0.0493  0.0520  0.0553  0.0551  0.0723  0.0766  0.0807  0.0881] ;
% sig2 = [0.0488 0.0949  0.0978 0.0997   0.1574  0.1299  0.1366  0.1950  2.2718] ;
%    
%    figure(2);
%    plot(mu,sig1)
%    hold on
%    plot(mu,sig2)
%    legend({'short','long'})
%    xlabel('power(\mu W)')
%    ylabel('\sigma (\mu W)')
%    hold off 
    
    subplot(221)
    imagesc(1e6*raw/(0.45*1e5))
    xlabel('index long')
    ylabel('index short')
    cb = colorbar;
    ylabel(cb,'\mu W')
    colormap(parula)
   
    

    
    
    subplot(223)
    line((1:length(Datas_std1))*1e-2,1e6*Datas_std1,'Color','r'); hold on 
    line((1:length(Datas_std1))*1e-2,1e6*sqrt(Ephoton*(10e6)*Datas_mu1),'Color','r'); hold off
    ylabel('\sigma (\mu W) over short ')
    xlabel('time (ms)')
    ylim([0 2])
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
    ax1_pos = get(ax1,'Position'); % position of first axes
    ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
    line(t,1e6*Datas_std2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\sigma (nW) over long')
    xlabel('time (\mu s)')
    

    
    subplot(222)
    line((1:length(Datas_std1))*1e-2,1e6*Datas_mu1,'Color','r'); hold on 
    ylabel('\mu (\mu W)over short ')
    xlabel('time (ms)')
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
    ax1_pos = get(ax1,'Position'); % position of first axes
    ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
    line(t,1e6*Datas_mu2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\mu (\mu W)over  long')
    xlabel('time (\mu s)')

    subplot(224)
    [freq1 , psdx1 ] = CalculateDoublePSD( raw , 10e6 );
    [freq2 , psdx2 ] = CalculateDoublePSD( raw' , 100e3 );
    line(freq2*1e-3,10*log10(100e3*psdx2),'Color','r')
    ylim([-52 -30])
    xlabel('Frequency (kHz)')
    ylabel('Power (dB)')
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
ax1_pos = get(ax1,'Position'); % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
    line(freq1*1e-6,10*log10(10e6*psdx1),'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    xlabel('Frequency (MHz)')
    ylabel('Power (dB)')
   
    