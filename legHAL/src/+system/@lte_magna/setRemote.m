function status = setRemote( obj )
    status = obj.rs232.write_and_read( 'CONF:SETPT 3' );
end
