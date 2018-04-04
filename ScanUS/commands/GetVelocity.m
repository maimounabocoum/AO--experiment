function y = GetVelocity(controleur,MyMotor)
%
fprintf(controleur,[MyMotor 'gnv']);
y = str2double(fscanf(controleur,'%s'))


% Velocity result
disp([' Current Velocity (mm/s) ' , num2str(y) ])

end

