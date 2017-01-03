function status = setLocal( obj )
    status = obj.rs232.write_and_read( 'CONF:SETPT 0' );
end
