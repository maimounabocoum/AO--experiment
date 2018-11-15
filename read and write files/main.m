%%% main %%%
clearvars
path = 'D:\Data\Mai\test target\logfile\test.dat';
D = importdata(path);

[ Header , Data] = ReadDataFile(path) ;

figure; imagesc(Data)