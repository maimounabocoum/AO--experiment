function ret = getCurrentLimitation( obj )
    status = obj.rs232.write_and_read( 'CURR:PROT?' );

    ret = str2double ( status.data_receive );
end
