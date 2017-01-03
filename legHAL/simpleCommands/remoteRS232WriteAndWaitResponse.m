function ret_message = remoteRS232WriteAndWaitResponse (srv, message, endmessage, timeout)
%REMOTERS232WRITEANDWAITRESPONSE Send to remote a message to send throw the
%serial port and wait for the response
%
% Usage :
%   srv = REMOTERS323WRITEANDWAITRESPONSE(srv, message, endmessage,
%   timeout)
%
% Description :
%   Connect the rs232 port on the host machine
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
%       argC parameter is required => timeout, the time to wait the
%       response in ms
%                  (like '400')
%     
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name      = 'rs232_write_and_read';
    msg.message   = message;
    msg.endLine   = endmessage;
    msg.timeout   = timeout;
    ret_message = remoteSendMessage(srv, msg);
end