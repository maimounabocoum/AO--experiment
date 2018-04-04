function y = GetAccelerationRamp(controleur,MyMotor)
%
fprintf(controleur,[MyMotor 'getnaccel']);
y = str2double(fscanf(controleur,'%s'))


% Velocity result
disp([' Current Acceleration Ramp is (mm/s^{-2}) ' , num2str(y) ])

end

