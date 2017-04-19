function ret = getCurrentLimitationMin( obj )
    status = obj.rs232.write_and_read( 'CURR:PROT? MIN' );

    ret = str2double ( status.data_receive );
end
