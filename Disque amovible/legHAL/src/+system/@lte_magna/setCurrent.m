function status = setCurrent( obj, value )
    status = obj.rs232.write_and_read( [ 'CURR ' num2str(value) ] );
end
