%% =============== add subfolders ===============  %%

 addpath('..\..\AO--commons\shared functions folder')
 addpath('gui');
 addpath('sequences');
 addpath('subfunctions');
 
 %% =============== load datas ===============  %%
 
 % data : 13/11/2019:
 % importdata('Q:\datas\2019-11-08\Signal_modeTwicking_RepHz_100_17h32_35.mat')
 
 
 %% =============== screen out datas ===============  %%

     h = 6.6e-34;
     lambda = 780e-9;
     Ephoton = h*(3e8/lambda);
     Fs1 = 10e6 ;
     Fs2 = 100 ;
     % definition of 2 structure for data analyses:
     MyStat1 = stats_t( Fs1 );
     MyStat2 = stats_t( Fs2 );
     
    Hmu = figure(1);
    % set(Hmu,'WindowStyle','docked');
    
    % raw/(0.45*1e5)  [V]unit x [W/V] = [W]unit
    
    [t1,Datas_mu1]   = MyStat1.average( raw/(0.45*1e5) );
    Datas_std1  = MyStat1.standard_dev( raw/(0.45*1e5) ) ;
    [t2,Datas_mu2]   = MyStat2.average( raw'/(0.45*1e5) );
    Datas_std2  = MyStat2.standard_dev( raw'/(0.45*1e5) );
    
   % [Datas_mu1,Datas_std1,Datas_mu2,Datas_std2] = AverageDataBothWays( raw/(0.45*1e5) );
   
    subplot(221)
imagesc(1e6*raw/(0.45*1e5))
    xlabel('index long')
    ylabel('index short')
    cb = colorbar;
    ylabel(cb,'\mu W')
    colormap(parula)
  
    subplot(223)
line( t1*1e3,1e6*Datas_std1,'Color','r'); hold on 
line( t1*1e3,1e6*sqrt(Ephoton*Fs1*Datas_mu1),'Color','r'); hold off
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
line(t2*1e6,1e6*Datas_std2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\sigma (nW) over long')
    xlabel('time (\mu s)')
    

    
    subplot(222)
line(t1*1e3,1e6*Datas_mu1,'Color','r'); hold on 
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
line(t2*1e6,1e6*Datas_mu2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\mu (\mu W)over  long')
    xlabel('time (\mu s)')

    subplot(224)
[freq1 , psdx1 ] = MyStat1.PowSpecDens( raw/(0.45*1e5) ) ;
% psdx1 = mean( psdx1 , 2 ) ;
[freq2 , psdx2 ] = MyStat2.PowSpecDens( raw'/(0.45*1e5) ) ;
psdx2 = mean( psdx2 , 2 ) ;

e1  = MyStat1.Energy_t( raw/(0.45*1e5) );
ee1 = MyStat1.Energy_psd( psdx1 ); 
figure; plot(e1) ; hold on ; plot(ee1)


% [freq1 , psdx1 ] = CalculateDoublePSD( raw  , Fs1 );
% [freq2 , psdx2 ] = CalculateDoublePSD( raw' , Fs2 );
line(freq2*1e-3,10*log10(100e3*psdx2),'Color','r')
    ylim([-52 -40])
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
   
    