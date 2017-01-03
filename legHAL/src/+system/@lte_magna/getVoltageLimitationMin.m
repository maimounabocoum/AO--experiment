function ret = getVoltageLimitationMin( obj )
    status = obj.rs232.write_and_read( 'VOLT:PROT? MIN' );

    ret = str2double ( status.data_receive );
end
