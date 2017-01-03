function ret = getMeasureVoltage( obj )
    status = obj.rs232.write_and_read( 'MEAS:VOLT?' );

    ret = str2double ( status.data_receive );
end
