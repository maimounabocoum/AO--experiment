function ret = getCurrentLimitationMax( obj )
    status = obj.rs232.write_and_read( 'CURR:PROT? MAX' );

    ret = str2double ( status.data_receive );
end
