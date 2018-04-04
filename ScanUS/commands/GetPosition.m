function y = GetPosition(controleur,MyMotor)

fprintf(controleur,[MyMotor ' np']);
y = str2double(fscanf(controleur,'%s'));

% print result
disp([' Current Position (mm) ' , num2str(y) ])