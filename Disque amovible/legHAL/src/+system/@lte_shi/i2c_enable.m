function i2c_enable( obj )

    msg.name   = 'i2c_enable';
    msg.enable = true;
    msgRcv     = remoteSendMessage(obj.srv, msg);

end