function ret = getCurrent( obj )
    status = obj.rs232.write_and_read( 'CURR?' );

    ret = str2double ( status.data_receive );
end
