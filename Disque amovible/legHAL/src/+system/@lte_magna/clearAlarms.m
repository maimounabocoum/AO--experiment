function status = clearAlarms( obj )
    status = obj.rs232.write_and_read( 'OUTP:PROT:CLE' );
end
