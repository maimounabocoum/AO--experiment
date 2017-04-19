function ret = getCurrentMax( obj )
    status = obj.rs232.write_and_read( 'CURR? MAX' );

    ret = str2double ( status.data_receive );
end
