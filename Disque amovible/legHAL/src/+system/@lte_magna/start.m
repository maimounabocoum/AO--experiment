function status = start( obj )
    status = obj.rs232.write_and_read( 'OUTP:START' );
end
