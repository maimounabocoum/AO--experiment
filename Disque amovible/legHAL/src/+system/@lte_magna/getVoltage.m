function ret = getVoltage( obj )
    status = obj.rs232.write_and_read( 'VOLT?' );

    ret = str2double ( status.data_receive );
end
