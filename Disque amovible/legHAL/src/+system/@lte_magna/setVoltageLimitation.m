function status = setVoltageLimitation( obj, value )
    status = obj.rs232.write_and_read( [ 'VOLT:PROT ' num2str(value) ] );
end
