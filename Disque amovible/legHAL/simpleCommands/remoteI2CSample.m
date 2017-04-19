 function msgRcv = remoteI2CSample (srv)
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/03/04$
%M-File function.

    remoteBlock(srv, 1);

    msgSndEnable.name           = 'i2c_enable';
    msgSndEnable.enable         = true;    
    msgRcv = remoteSendMessage(srv, msgSndEnable);

    msgSndI2CCommand.name       = 'i2c_rw';
    msgSndI2CCommand.read       = '1';
    msgSndI2CCommand.data       = '0';  %mandatory parameter, like in the non useful read case
    msgSndI2CCommand.rw16Bits   = '1';
    msgSndI2CCommand.opcode     = 'shi_conn_ok';
    
    msgRcv = remoteSendMessage(srv, msgSndI2CCommand);

    remoteBlock(srv, 0);  
end
