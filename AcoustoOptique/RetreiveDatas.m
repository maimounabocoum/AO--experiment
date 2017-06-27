function datas = RetreiveDatas( raw , Ntrig, Nlines)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% test to see o raw as the rigth number of coulumn :
if size(raw,2)~=Ntrig*Nlines
    datas = [];
    fprintf('wrong num of columns for input matrix')
    
else

datas = reshape(raw,size(raw,1),Nlines, Ntrig);
datas = mean(datas,3);
end


end

