function ret = getIdn( obj )
    status = obj.rs232.write_and_read( '*IDN?' );

    ret = strtrim ( status.data_receive );
end
