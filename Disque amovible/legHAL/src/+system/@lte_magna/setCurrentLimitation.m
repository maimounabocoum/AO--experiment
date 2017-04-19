function status = setCurrentLimitation( obj, value )
    status = obj.rs232.write_and_read( [ 'CURR:PROT ' num2str(value) ] );
end
