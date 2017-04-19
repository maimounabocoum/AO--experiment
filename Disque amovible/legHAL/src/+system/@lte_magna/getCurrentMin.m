function ret = getCurrentMin( obj )
    status = obj.rs232.write_and_read( 'CURR? MIN' );

    ret = str2double ( status.data_receive );
end
