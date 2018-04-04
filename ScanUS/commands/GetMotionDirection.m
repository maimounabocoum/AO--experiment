function y = GetMotionDirection(controleur,MyMotor)

%
fprintf(controleur,[MyMotor 'getmotiondir']);
y = str2double(fscanf(controleur,'%s'))


% Velocity result
switch y
    
    case 0
    
disp([' Current Motion direction is clockwise' ])

    case 1
        
        disp([' Current Motion direction is anti-clockwise' ])
end


end

