function ret = write_and_read ( obj, message )

    msg.name      = 'rs232_write_and_read';
    msg.message   = message;
    msg.endline   = obj.getParam('EndLine');
    msg.timeout   = obj.getParam('Timeout');

    ret = remoteSendMessage( obj.srv, msg );

    obj.check_status( msg, ret );
end
