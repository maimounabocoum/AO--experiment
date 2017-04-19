function ret = connect ( obj )

    msg.name      = 'rs232_connect';
    msg.device    = obj.getParam('Port');
    msg.bauderate = obj.getParam('BaudRate');
    msg.bitData   = obj.getParam('DataBits');
    msg.bitArret  = obj.getParam('StopBits');
    msg.parity    = obj.getParam('Parity');

    ret = remoteSendMessage( obj.srv, msg );

end
