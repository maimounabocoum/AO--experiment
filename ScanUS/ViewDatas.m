
%% read saved datas
Hf = figure;
set(Hf,'WindowStyle','docked'); 
D=[1 1 1;0 0 1;0 1 0;1 1 0;1 0 0;];
F=[0 0.25 0.5 0.75 1];
G=linspace(0,1,256);
cmap=interp1(F,D,G);
colormap(hot)


t = (1:MyScan.Npoints)*(1/(1e6*SampleRate));

cc = jet(2);
% view data with common z value
for i = 1:length(MyScan.z)
zin = MyScan.z(i) ;

% find index which position equals zin
I_zin = find( abs(MyScan.Positions(:,3) - zin ) < 1e-6 );
% extract x values with position zin
X_zin = MyScan.Positions(I_zin,1);
[X_zin,Isort] = sort(X_zin);
% exctract datas with position zin
D_zin = MyScan.Datas(:,I_zin(Isort));

imagesc(X_zin,t*1e6,D_zin)
%plot(X_zin,sum(abs(D_zin),1),'color',cc(i,:))
%ylim([11 40])
%xlim([min(MyScan.x) (1+1e-5)*max(MyScan.x)])
%shading interp
%view([0 90])
xlabel('x(mm)')
ylabel('t(\mu s)')
title(['z = ',num2str(zin)])
%title(['Scan = ',num2str(ScanIndex)])
cb = colorbar;
ylabel(cb,'Volt')
set(findall(Hf,'-property','FontSize'),'FontSize',15) 
drawnow
%hold on

%saveas(gcf,['datas\moviebin\test',num2str(i)],'png')
end

% hold on
% plot(60+find(ActiveLIST(:,ScanIndex)==1)*0.2,...
%      0*find(ActiveLIST(:,ScanIndex)==1)+4,'o','color','red')
% 
%  legend({'z=0mm','z=30mm','command'})

%% plot propagating spectra

% %% read saved datas
Hf = figure;
set(Hf,'WindowStyle','docked'); 
D=[1 1 1;0 0 1;0 1 0;1 1 0;1 0 0;];
F=[0 0.25 0.5 0.75 1];
G=linspace(0,1,256);
cmap=interp1(F,D,G);
colormap(hot)


t = (1:MyScan.Npoints)*(1/(1e6*SampleRate));
N = length(t);
frequencies = (0:N/2)*( SampleRate/(N) ) ;

for i = 1:length(MyScan.z)
zin = MyScan.z(i) ;

% find index which position equals zin
I_zin = find(MyScan.Positions(:,3) == zin);
% extract x values with position zin
X_zin = MyScan.Positions(I_zin,1);
[X_zin,Isort] = sort(X_zin);
% exctract datas with position zin
D_zin = MyScan.Datas(:,I_zin(Isort));
signal_FT = fft(D_zin,N,1);
signal_FT = abs(signal_FT(1:(N/2+1) , :) );

imagesc(X_zin,frequencies,signal_FT )
ylim([0 30])
%xlim([min(MyScan.x) max(MyScan.x)])
%shading interp
%caxis([0 0.1])
xlabel('x(mm)')
ylabel('f(MHz)')
title(['z = ',num2str(zin)])
cb = colorbar;
ylabel(cb,'Volt')
set(findall(Hf,'-property','FontSize'),'FontSize',15) 
drawnow

%saveas(gcf,['datas\moviebin\test',num2str(i)],'png')
end



%% improfile extraction
% t = (1:MyScan.Npoints)*(1/(1e6*SampleRate));
% 
% z_profile = 35 ;
% x_profile = 73 ;
% 
% I_z = find(MyScan.Positions(:,3) == z_profile);
% I_x = find(MyScan.Positions(:,1) == x_profile);
% I_xz = intersect(I_x,I_z);
% 
% H1d = figure;
% set(H1d,'WindowStyle','docked'); 
% plot(t*1e6,MyScan.Datas(:,I_xz),'linewidth',3)
% xlabel('time(\mu s)')
% 
% %% colormaps
% D=[1 1 1;0 0 1;0 1 0;1 1 0;1 0 0;];
% F=[0 0.25 0.5 0.75 1];
% G=linspace(0,1,256);
% cmap=interp1(F,D,G);
% 
% D=[0 0 1;0 1 1;1 1 1;1 1 0;1 0 0;];
% F=[0 0.25 0.5 0.75 1];
% G=linspace(0,1,256);
% cmap2=interp1(F,D,G);





