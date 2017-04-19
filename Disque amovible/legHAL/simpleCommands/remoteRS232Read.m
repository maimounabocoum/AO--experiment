function ret = remoteRS232Read (srv)
%REMOTERS232Read Read data on the serial port
%
% Usage :
%   srv = REMOTERS323Read(srv)
%
% Description :
%   read the rs232 port on the host machine
%
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name      = 'rs232_read';
    ret = remoteSendMessage(srv, msg);
end