%%%% data screening %%%
clearvars;


[filename,foldername] = uigetfile('D:\Data\Mai\2017-04-14');

load([foldername,filename]);


figure;
imagesc(X,Y,data(:,:,1))
title(filename)
xlabel('x(mm)')
ylabel('y(mm)')
colorbar