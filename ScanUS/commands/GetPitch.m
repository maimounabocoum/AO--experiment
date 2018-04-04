function y = GetPitch(controleur,MyMotor)

%
fprintf(controleur,[MyMotor 'getpitch']);
y = str2double(fscanf(controleur,'%s'))


% Velocity result
disp([' Current Pitch (mm) ' , num2str(y) ])


end

