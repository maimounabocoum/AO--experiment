function ret = disconnect ( obj )

    msg.name      = 'rs232_disconnect';

    ret = remoteSendMessage( obj.srv, msg );

end
