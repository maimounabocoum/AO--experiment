function [Datas_mu1,Datas_std1, Datas_mu2 , Datas_std2] = AverageDataBothWays( raw )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

Datas_mu1 = mean(raw,1);
Datas_std1 = sqrt(var(raw,0,1));

Datas_mu2 = mean(raw,2);
Datas_std2 = sqrt(var(raw,0,2));


end

