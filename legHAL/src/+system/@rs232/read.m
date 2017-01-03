function ret = read ( obj )

    msg.name      = 'rs232_read';

    ret = remoteSendMessage( obj.srv, msg );

end
