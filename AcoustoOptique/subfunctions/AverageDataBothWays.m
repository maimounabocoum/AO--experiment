function [Datas_mu1,Datas_std1, Datas_mu2 , Datas_std2] = AverageDataBothWays( raw )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Datas_mu1 = mean(raw);
Datas_std1 = sqrt(var(raw));

Datas_mu2 = mean(raw');
Datas_std2 = sqrt(var(raw'));


end

