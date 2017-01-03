function status = setVoltage( obj, value )

    disp( obj.getIdn() );
    obj.setRemote();
    
    obj.start();

    status = obj.getStatus();
    ques_cond = dec2hex(str2double(status), 3);
    disp(['Magna questionnable regiter value (before set voltage): 0x', num2str(ques_cond)]);
    
    obj.clearAlarms();

    status = obj.getStatus();
    ques_cond = dec2hex(str2double(status), 3);
    disp(['Magna questionnable regiter value (before set voltage): 0x', num2str(ques_cond)]);

    % setParameter Voltage ?
    status = obj.rs232.write_and_read( [ 'VOLT ' num2str(value) ] );
end
