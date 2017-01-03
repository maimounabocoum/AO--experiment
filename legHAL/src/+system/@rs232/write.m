function ret = write ( obj, message )

    msg.name      = 'rs232_write';
    msg.message   = message;
    msg.endline   = obj.getParam('EndLine');

    ret = remoteSendMessage( obj.srv, msg );

end
