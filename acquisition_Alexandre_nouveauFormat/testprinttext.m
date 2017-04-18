%%% print text file test 

 % code
A  = rand(10,1);
B = rand(10,1);
header1 = 'Hello';
header2 = 'World!';
fid=fopen('MyFile.txt','w');
fprintf(fid, [ header1 ' ' header2 'r\n']);
fprintf(fid, '%f %f r\n', [A B]');
fclose(fid);true
    % code