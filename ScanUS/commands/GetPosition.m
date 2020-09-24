function y = GetPosition(controleur,MyMotor)

%
fprintf(controleur,[MyMotor 'npos']);
y = str2double(fscanf(controleur,'%s'))


% Velocity result
disp([' Current Pitch (mm) ' , num2str(y) ])


end

