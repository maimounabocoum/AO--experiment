function acq = analog_acq_display( obj )
    acq = obj.get_analog_acq();
    
    disp('analog measures :')
    fprintf('V_HVA1 %f V \n', acq(1,1));
    fprintf('V_HVB1 %f V \n', acq(1,2));
    fprintf('V_HVA2 %f V \n', acq(1,3));
    fprintf('V_HVB2 %f V \n', acq(1,4));
    fprintf('I_HVA1 %f A \n', acq(1,5));
    fprintf('I_HVB1 %f A \n', acq(1,6));
    fprintf('I_HVA2 %f A \n', acq(1,7));
    fprintf('I_HVB2 %f A \n', acq(1,8));
    disp(' ');
    fprintf('V_-5VA1   %f V \n', acq(2,1));
    fprintf('V_+5.5VA2 %f V \n',acq(2,2));
    fprintf('Curr LD1  %f \n', acq(2,3)); % unit ?
    fprintf('Curr LD2  %f \n', acq(2,4)); % unit ?
    fprintf('V_+5V     %f V \n', acq(2,5));
    fprintf('V_-5VA1   %f V \n', acq(2,6));
    fprintf('V_+5.5VA1 %f V \n', acq(2,7));
    fprintf('V+12V     %f V \n', acq(2,8));
    disp(' ');
    fprintf('TEMP1  %f degrees C \n', acq(3,1));
    fprintf('TEMP2  %f degrees C \n', acq(3,2));
    fprintf('TEMP3  %f degrees C \n', acq(3,3));
    fprintf('TEMP4  %f degrees C \n', acq(3,4));
    fprintf('TEMP9  %f degrees C \n', acq(3,5));
    fprintf('TEMP10 %f degrees C \n', acq(3,6));
    fprintf('TEMP11 %f degrees C \n', acq(3,7));
    fprintf('TEMP12 %f degrees C \n', acq(3,8));
    disp(' ');
    fprintf('TEMP5  %f degrees C \n', acq(4,1));
    fprintf('TEMP6  %f degrees C \n', acq(4,2));
    fprintf('TEMP7  %f degrees C \n', acq(4,3));
    fprintf('TEMP8  %f degrees C \n', acq(4,4));
    fprintf('User0 %f V \n', acq(4,5));
    fprintf('User1 %f V \n', acq(4,6));
    fprintf('User2 %f V \n', acq(4,7));
    fprintf('User3 %f V \n', acq(4,8));
end