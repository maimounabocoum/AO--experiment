%% read trace from saved datas %%%


% open file to read :

[filename,foldername] = uigetfile('D:\Data\Mai\2017-04-14\1D oscilloscope')

load([foldername,filename]);
SData = oscilloTrace(size(S.Lines,1),S.Nlines,S.SampleRate,1540) ;
SData.Lines = S.Lines;
SData.z = S.z;
SData.t = S.t;


hold on
plot(SData.z*1e3,mean(SData.Lines,2)*1e3)