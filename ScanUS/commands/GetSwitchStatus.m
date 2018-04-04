function y = GetSwitchStatus(controleur,MyMotor)


%
fprintf(controleur,[MyMotor 'getswst']);
y = str2double(fscanf(controleur,'%s'))


% Velocity result
disp([' Current switch status ' , num2str(y) ])


end

