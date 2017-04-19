function ret = getMeasureCurrent( obj )
    status = obj.rs232.write_and_read( 'MEAS:CURR?' );

    ret = str2double ( status.data_receive );
end
