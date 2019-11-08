
%% read saved datas
Hf = figure(1);
set(Hf,'WindowStyle','docked'); 
D=[1 1 1;0 0 1;0 1 0;1 1 0;1 0 0;];
F=[0 0.25 0.5 0.75 1];
G=linspace(0,1,256);
cmap=interp1(F,D,G);
colormap(hot)


t = (1:MyScan.Npoints)*(1/(1e6*SampleRate));

cc = jet(2);
% view data with common z value
% find index which position equals zin

% extract x values with position zin

% exctract datas with position zin
D_zin2 = MyScan.Datas;

D_zin2bis = interp1(t*1e6,D_zin2,((t*1e6)+1.5),'linear',0);
figure(2)
hold on
ytest=-0.955-0.25*sin(2*pi*0.5e6*t).*(1+cos(pi*0.1e6*t))/2;
plot(t*1e6,ytest,'r');
plot(t*1e6,D_zin2bis'-D_zin1)

% D_zin2bis = interp1(t*1e6,D_zin2,((t*1e6)+29.5),'linear',0);
% figure(2)
% hold on
% ytest=-0.955-0.25*cos(2*pi*0.5e6*t).*cos(pi*0.05e6*t-0.7);
% plot(t*1e6,ytest,'r');
% plot(t*1e6,D_zin2bis'-D_zin1)

%plot(X_zin,sum(abs(D_zin),1),'color',cc(i,:))
%ylim([11 40])
%xlim([min(MyScan.x) (1+1e-5)*max(MyScan.x)])
%shading interp
%view([0 90])
xlabel('x(mm)')
ylabel('t(\mu s)')
%title(['Scan = ',num2str(ScanIndex)])

set(findall(Hf,'-property','FontSize'),'FontSize',15) 
drawnow
%hold on


% hold on
% plot(60+find(ActiveLIST(:,ScanIndex)==1)*0.2,...
%      0*find(ActiveLIST(:,ScanIndex)==1)+4,'o','color','red')
% 
%  legend({'z=0mm','z=30mm','command'})

