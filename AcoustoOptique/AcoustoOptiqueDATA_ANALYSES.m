%% =============== add subfolders ===============  %%

%  addpath('..\..\AO--commons\shared functions folder')
%  addpath('gui');
%  addpath('sequences');
%  addpath('subfunctions');
 
 %% =============== load datas ===============  %%
 
 % data : 13/11/2019:
 % importdata('Q:\datas\2019-11-08\Signal_modeTwicking_RepHz_100_17h32_35.mat')
 
 % detector menlo PD: frequenc BD: 150 MHz BW
 
 %% =============== screen out datas ===============  %%

     h = 6.6e-34;
     lambda = 780e-9;
     Ephoton = h*(3e8/lambda);
     Fs1 = SampleRate ;  % gage sampling frequncy
     Fs2 = Frep ;        % triggerbox sampling frequency
     BW = 150e6 ; % photo-detector bandwith
     % definition of 2 structure for data analyses:
     MyStat1 = stats_t( Fs1 );
     MyStat2 = stats_t( Fs2 );
     
    Hmu = figure;
    set(Hmu,'WindowStyle','docked'); 
    % raw/(0.45*1e5)  [V]unit x [W/V] = [W]unit - SI PD
    % raw/(0.45*1e5)  [V]unit x [W/V] = [W]unit - Menlo PD
    
     [t1,Datas_mu1]   = MyStat1.average( raw/(0.45*1e5) );
     Datas_std1  = MyStat1.standard_dev( raw/(0.45*1e5) ) ;   
     [t2,Datas_mu2]   = MyStat2.average( raw'/(0.45*1e5) );
     Datas_std2  = MyStat2.standard_dev( raw'/(0.45*1e5) );
       
    % [Datas_mu1,Datas_std1,Datas_mu2,Datas_std2] = AverageDataBothWays( raw/(0.45*1e5) );
    t1 = (1/Fs2)*(1:length(Datas_mu1));
    t2 = (1/Fs1)*(1:length(Datas_mu2));
    
    subplot(221)
imagesc(1e3*t1,1e6*t2,1e6*raw/(0.45*1e5))
    xlabel('time( ms )')
    ylabel('time( \mu s )')
    cb = colorbar;
    ylabel(cb,'\mu W')
    colormap(parula)
  
    subplot(223)
    s1 = 1e6*Datas_std1;
    s2 = 1e6*Datas_std2;
    s3 = 1e6*sqrt(Ephoton*BW*Datas_mu1); % shot noise for detector BW 150
line( t1*1e3,s1,'Color','r'); hold on 
line( t1*1e3,s3,'Color','b'); hold off
    ylabel('\sigma (\mu W) over short ')
    xlabel('time (ms)')
    ylim([0 0.5])
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
    set(ax1,'Ylim',[0.5*min([s1(:);s2(:);s3(:)]) max([s1(:);s2(:)])]);
    ax1_pos = get(ax1,'Position'); % position of first axes
    ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
line(t2*1e6,s2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\sigma (\mu W) over long')
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
    %set(ax2,'Ylim',get(ax1,'Ylim'));
    set(ax2,'Ylim',[15.36 15.4]);
    ylabel('\mu (\mu W)over  long')
    xlabel('time (\mu s)')

    subplot(224)
    % psdx unit: [raw^2/Hz] = [W^2/Hz] (cf Equation 3)
% [freq1 , psdx1 ] = MyStat1.PowSpecDens( raw/(0.45*1e5) )  ; % acquisition quick
% [freq2 , psdx2 ] = MyStat2.PowSpecDens( raw'/(0.45*1e5) ) ; % acquisition long
% % averaging over the many realizations:
% psdx1 = mean(psdx1,2);
% psdx2 = mean(psdx2,2);

% test avec noise VA directement:
[freq1 , psdx1 ] = MyStat1.PowSpecDens( Datas_mu1 )  ; % acquisition quick
[freq2 , psdx2 ] = MyStat2.PowSpecDens( Datas_mu2 ) ; % acquisition long

% plot(sqrt(1:10)); 
% h = legend(['$$\sqrt{blah}$$'])
% set(h,'Interpreter','latex','fontsize',24) 

%  figure;plot(freq1,10*log10(Fs1*psdx1)),
%  figure;plot(freq2,10*log10(Fs2*psdx2),'Color','r')
% e1  = MyStat1.Energy_t( raw/(0.45*1e5) );
% ee1 = MyStat1.Energy_psd( psdx1 ); 

s1 = 10*log(sqrt(psdx1(2:end))/mean(Datas_mu1)) ;
s2 = 10*log(sqrt(psdx2(2:end))/mean(Datas_mu2)) ;
s3_1 = (1+0*freq1(2:end))*10*log(sqrt(Ephoton*BW/mean(Datas_mu1))/(Fs1/2));   % shot noise for detector BW 150MHz
s3_2 = (1+0*freq2(2:end))*10*log(sqrt(Ephoton*BW/mean(Datas_mu2))/(Fs2/2));   % shot noise for detector BW 150MHz
line(freq2(2:end),s2,'Color','k'); hold on
line(freq2(2:end)*1e-6,s3_2,'Parent',ax2,'Color','k')
    xlabel('Frequency (Hz)','Interpreter','latex')
    ylabel('RIN dBc$$\sqrt{Hz}$$','Interpreter','latex');
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
    set(ax1,'Ylim',[min([s1(:);s2(:);s3_1(:);s3_2(:)])-10 , 10 + max([s1(:);s2(:);s3_1(:);s3_2(:)])] );
ax1_pos = get(ax1,'Position'); % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
line(freq1(2:end)*1e-6,s1,'Parent',ax2,'Color','r'); hold on
line(freq1(2:end)*1e-6,s3_1,'Parent',ax2,'Color','r')
     set(ax2,'Ylim',get(ax1,'Ylim'));
     set(ax2,'Xlim',[min(freq1*1e-6) max(freq1*1e-6)]);
    xlabel('Frequency (MHz)','Interpreter','latex')
    ylabel('Relative Intensity Noise $$\sqrt{Hz}$$','Interpreter','latex');

    