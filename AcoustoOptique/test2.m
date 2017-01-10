%% this a a test %% (to be deleted)

 %clear
 %load('F:\code et developpement\code matlab\snake-matlab\dataOP-JB\2016-02-01\OP0deg-2016-02-01_13-22.mat')
 %DataOP0=data;
 
 theta=X;
 Proj=DataOP0(:,:,1);
 
 figure;
 imagesc(theta,Y,data(:,:,1))
 shading interp
 title(['Plane Wave scan from',num2str(Param.X0),'to',num2str(Param.Prof)])
 xlabel('\theta (°)')
 ylabel(' z (mm)')