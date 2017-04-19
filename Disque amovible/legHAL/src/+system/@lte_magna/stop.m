function status = stop( obj )
    status = obj.rs232.write_and_read( 'OUTP:STOP' );
end
