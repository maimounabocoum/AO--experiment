function ret = getVoltageLimitationMax( obj )
    status = obj.rs232.write_and_read( 'VOLT:PROT? MAX' );
    
    ret = str2double ( status.data_receive );
end
