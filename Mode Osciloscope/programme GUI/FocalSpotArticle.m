% clear all
% h1 = open('ImagePrepulse.fig');
% h2 = open('ImageReseau.fig');
% 
% [X1 Y1 D1] = GetDataFromFigure(h1);
% [X2 Y2 D2] = GetDataFromFigure(h2);
% 
 close all

figure()

 
 %H1 = pcolor(X1,Y1,D1/max(D1(:)));
 H2 = pcolor(X2,Y2,D2);
 shading interp
 hold on

%[Lines,Vertices,Objects]=isocontour(D1,max(D1(:))/2);

contour(X1+2,Y1,D1/max(D1(:)),0.5,'color','red','LineWidth',4)
contour(X1+2,Y1,D1/max(D1(:)),0.25,'color','black','LineWidth',4)

% 0.1353

xlim([-25 25])
ylim([-25 25])





