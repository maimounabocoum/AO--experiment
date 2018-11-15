function [ Header , Data] = ReadDataFile( path)


D = importdata(path);

Data = D.data ;

Header = D.textdata ; 

% for i = 1:length(Header)
%    
%     MyString = regexp(Header{i},'\d*','Match')
%     
%     
% end




end

