function [datas_mu,datas_std,V] = RetreiveDatas( raw , Ntrig, Nlines,MedElmtList)
% Retreiving average from raw datas
%   Maïmouna Bocoum

%% test to see o raw as the rigth number of column :
if size(raw,2)~=Ntrig*Nlines
    datas = [];
    fprintf('wrong num of columns for input matrix')
    
else
    
    
fprintf('For current processed data : \r Nlines = %d , Ntrig = %d \r\n',Nlines, Ntrig)

[Isorted,Iposition] = sort(MedElmtList);

datas = reshape(raw,size(raw,1),Nlines, Ntrig);
% datas(:,Isorted,:) = datas(:,Iposition,:);
% size(datas)
V = var(datas,0,3);
datas_mu = mean(datas,3);
datas_std = sqrt( var(datas,0,3) ); 

end


end

