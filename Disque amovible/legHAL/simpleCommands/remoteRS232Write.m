function ret = remoteRS232Write (srv, message, endmessage)
%REMOTERS232WRITE Send to remote a message to send throw the
%serial port
%
% Usage :
%   srv = REMOTERS323WRITE(srv, message, endmessage)
%
% Description :
%   write data on rs232 port on the host machine
%
% Can be used with :
%       argA parameter is required => message, the message to send
%                  (like '>rs')
%       argB parameter is required => endmessage.
%                                           0 -> nothing add to the end of
%                                           the message
%                                           1 -> add \r at the end of the
%                                           message
%                                           2 -> add \n at the end of the
%                                           message     
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name      = 'rs232_write';
    msg.message   = message;
    msg.endLine   = endmessage;
    ret = remoteSendMessage(srv, msg);
end