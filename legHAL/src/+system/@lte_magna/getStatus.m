function ret = getStatus( obj )
    status = obj.rs232.write_and_read( 'STAT:QUES:COND?' );
    
    hex_val = dec2hex( str2num(status.data_receive) , 3);
    disp(['Magna questionnable regiter value: 0x', hex_val]);
    
    ret = status.data_receive;
end
