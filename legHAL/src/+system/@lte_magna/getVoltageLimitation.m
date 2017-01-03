function ret = getVoltageLimitation( obj )
    status = obj.rs232.write_and_read( 'VOLT:PROT?' );

    ret = str2double ( status.data_receive );
end
