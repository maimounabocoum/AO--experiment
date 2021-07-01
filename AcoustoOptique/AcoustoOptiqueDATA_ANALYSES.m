%% =============== add subfolders ===============  %%

 addpath('..\..\AO--commons\shared functions folder')
%  addpath('gui');
%  addpath('sequences');
%  addpath('subfunctions');
 
 %% =============== load datas ===============  %%
 
 % data : 13/11/2019:
 % importdata('Q:\datas\2019-11-08\Signal_modeTwicking_RepHz_100_17h32_35.mat')
 
 % detector menlo PD: frequenc BD: 150 MHz BW
 
 %% =============== screen out datas ===============  %%

     h = 6.6e-34;
     lambda = 1064e-9;
     Ephoton = h*(3e8/lambda);
     Fs1 = SampleRate ;     % gage sampling frequncy
     Fs2 = Frep ;           % triggerbox sampling frequency
     BW = 150e6 ;           % photo-detector bandwith
     % definition of 2 structure for data analyses:
     MyStat1 = stats_t( Fs1 );
     MyStat2 = stats_t( Fs2 );
     unit = 'W';
     %alpha = 1/(0.45*1e5) ; % convertion W/Volt - thorlabs
     % alpha = (200e-6)/0.3057 ; % convertion W/Volt - Menlo
     alpha = 1/(0.65e5) ; % convertion W/Volt - DET20C2+AMPLI-100kV/A
     
     % interval for long time analysis
     t1 = (1/Fs1)*(1:size(raw,1)); % s
     t2 = (1/Fs2)*(1:size(raw,2)); % s
     I_extract = find( t1 >= 300e-6 & t1 <= 301e-6);
     
    Hmu = figure(1); clf(Hmu,'reset');
    set(Hmu,'color','w')
    % set(Hmu,'units','normalized','outerposition',[0 0 1 1])
    %set(Hmu,'WindowStyle','docked'); 
    % raw/(0.45*1e5)  [V]unit x [W/V] = [W]unit - SI PD
    % raw/(0.45*1e5)  [V]unit x [W/V] = [W]unit - Menlo PD - saturation 0.7529 V

    
     Datas_mu1   = MyStat1.average(     alpha*raw(I_extract,:)  );
     Datas_std1  = MyStat1.standard_dev( alpha*raw(I_extract,:)  );   
     Datas_mu2   = MyStat2.average(     alpha*raw' );
     Datas_std2  = MyStat2.standard_dev( alpha*raw');
     [freq1 , PSDx1 , unit_psdx1  ] = MyStat1.PowSpecDens( alpha*raw   , unit )  ; % acquisition quick
     [freq1 , NSDx1 , unit_psdx1  ] = MyStat1.PowSpecDens( alpha*raw - repmat(Datas_mu2',1,length(Datas_mu1))   , unit ) ; % noise spectral density
     [freq2 , PSDx2 , unit_psdx2  ] = MyStat2.PowSpecDens( alpha*raw' , unit ) ;   % acquisition long
     psdx1 = mean(PSDx1,2);
     nsdx1 = mean(NSDx1,2);
     psdx2 = mean(PSDx2,2);
     
    
    
    subplot(221)
    imagesc(1e3*t2,1e6*t1,1e6*alpha*raw);
    set(gca,'XAxisLocation','top');
    xlabel('t2( ms )')
    ylabel('t1( \mu s )')
    cb = colorbar;
    ylabel(cb,'\mu W')
    colormap(parula)
    title(sprintf('Number of traces = %d',size(raw,2)))
  
    subplot(223)
    s1 = Datas_std1./sqrt(Ephoton*BW*abs(mean(Datas_mu1)));
    s2 = Datas_std2./sqrt(Ephoton*BW*abs(mean(Datas_mu1)));

    %s3 = 1e6*sqrt(Ephoton*BW*abs(mean(Datas_mu1))); % shot noise for detector BW 150
 line( t2*1e3,Datas_std1,'Color','k'); 
    ylabel(strcat('\sigma / \sigma_{sn} over long '))
    xlabel('time (ms)')
    ax1 = gca; % current axes
    set(ax1,'XColor','k','YColor','k');
    %set(ax1,'Ylim',[0.1*min([s1(:);s2(:)]) 1.5*max([s1(:);s2(:)])]);
    ax1_pos = get(ax1,'Position'); % position of first axes
    set(ax1,'YAxisLocation','left','XAxisLocation','top');
    
    ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','left',...
    'Color','none');
line(t1*1e6,Datas_std2,'Parent',ax2,'Color','r')
    %set(ax2,'Ylim',get(ax1,'Ylim'));
    set(ax2,'YColor','r','XColor','r','XAxisLocation','bottom','YAxisLocation','right');
    ylabel(strcat('\sigma / \sigma_{sn} over short'))
    xlabel('t1 (\mu s)','fontsize',5)
     
    subplot(222)
    title('average traces')
l = line(t2*1e3,1e6*Datas_mu1,'Color','k'); hold on 
    ylabel(strcat('\mu (\mu ',unit,')over short '))
    xlabel('time (ms)','fontsize',10)
    ax1 = gca; % current axes
    set(ax1,'XColor','k');
    set(ax1,'YColor','k');
    ax1_pos = get(ax1,'Position'); % position of first axes
    ax1_tightIn = get(ax1,'TightInset'); % position of first axes
    %get(ax1)
    set(ax1,'XAxisLocation','top','YAxisLocation','left');
    patch = fill([t2*1e3,fliplr(t2*1e3)],[1e6*( Datas_mu1 + Datas_std1 ),fliplr(1e6*( Datas_mu1 - Datas_std1 ))],...
      get(l,'color'),'Parent',ax1,'FaceAlpha',0.2, 'EdgeColor','none');
  
    ax2 = axes('Position',[ax1_pos(1),ax1_pos(2),ax1_pos(3)-ax1_tightIn(3),ax1_pos(4)],'XAxisLocation','bottom','YAxisLocation','right','Color','none');

l = line(t1*1e6,1e6*Datas_mu2,'Parent',ax2,'Color','r'); hold on
patch = fill([t1*1e6,fliplr(t1*1e6)],[1e6*( Datas_mu2 + Datas_std2 ),fliplr(1e6*( Datas_mu2 - Datas_std2 ))],...
      get(l,'color'),'Parent',ax2,'FaceAlpha',0.2, 'EdgeColor','none');
    %set(ax2,'Ylim',[0.9*min(1e6*abs(Datas_mu2)) 1.2*max(1e6*abs(Datas_mu2))]);
    set(ax2,'XColor','r');
    set(ax2,'YColor','r');
    ylabel('\mu (\mu W)over  long','fontsize',10)
    xlabel('time (\mu s)')

% figure;
% x = t1*1e6;
% curve1 = 1e6*( Datas_mu2 + Datas_std2 ) ;
% curve2 = 1e6*( Datas_mu2 - Datas_std2 ) ;
% x2 = [x, fliplr(x)];
% inBetween = [curve1, fliplr(curve2)] ;
% patch = fill([t1*1e6,fliplr(t1*1e6)],[1e6*( Datas_mu2 + Datas_std2 ),fliplr(1e6*( Datas_mu2 - Datas_std2 ))],[128 193 219]./255);
% %patch = fill(x2, inBetween, [128 193 219]./255) ;
% set(patch, 'edgecolor', 'none');
% set(patch, 'FaceAlpha', 0.5);
% get(patch)

    subplot(224)
    % psdx unit: [raw^2/Hz] = [W^2/Hz] (cf Equation 3)
% test avec noise VA directement:

% plot(sqrt(1:10)); 
% h = legend(['$$\sqrt{blah}$$'])
% set(h,'Interpreter','latex','fontsize',24) 

%  figure;plot(freq1,10*log10(Fs1*psdx1)),
%  figure;plot(freq2,10*log10(Fs2*psdx2),'Color','r')
% e1  = MyStat1.Energy_t( raw/(0.45*1e5) );
% ee1 = MyStat1.Energy_psd( psdx1 ); 

s1 = 10*log(sqrt( psdx1(2:end)/(1e-3) )) ; % dBm/Hz unit
s2 = 10*log(sqrt( psdx2(2:end)/(1e-3) )) ; % dBm/Hz unit
s3 = 10*log(sqrt( nsdx1(2:end)/(1e-3) )) ; % dBm/Hz unit

line(freq2(2:end),s2,'Color','k'); hold on
    xlabel('Frequency (Hz)')
    ylabel('PSD dBm/Hz');
    ax1 = gca; % current axes
    set(ax1,'XColor','k');
    set(ax1,'YColor','k');
    set(ax1,'Ylim',[min([s1(:);s2(:)])-10 , 10 + max([s1(:);s2(:)])] );
    set(ax1,'XAxisLocation','top','YAxisLocation','left','Color','none');
    
ax1_pos = get(ax1,'Position'); % position of first axes
ax1_tightIn = get(ax1,'TightInset'); % position of first axes
ax2 = axes('XAxisLocation','bottom','YAxisLocation','right','Color','none','Position',ax1_pos);
get(ax1,'DataAspectRatio')
get(ax2,'DataAspectRatio')

line(freq1(2:end)*1e-6,s1,'Parent',ax2,'Color','r'); hold on ;
line(freq1(2:end)*1e-6,s3,'Parent',ax2,'Color','g'); hold off ;
     set(ax2,'Ylim',get(ax1,'Ylim'));
     %set(ax2,'Xlim',[min(freq1*1e-6) max(freq1*1e-6)]);
     set(ax2,'XColor','r');
    set(ax2,'YColor','r');
    xlabel('Frequency (MHz)')
    ylabel('PSD dBm/Hz');

    set(findall(Hmu,'-property','FontSize'),'FontSize',8) 
    
%    figure(2); hold on ; plot( 1e6*Datas_mu1 , Datas_std1./sqrt(Ephoton*BW*abs(Datas_mu1)) , 'o') ;  
%    %figure; plot( 1e6*Datas_mu1 , Datas_std1./Datas_mu1  , 'o') ;
%     xlabel('Power PD (\mu W)')
%     ylabel('\sigma / \sigma_{sn} over sort ')

    

    
    
    
    