function status = remoteGetStatus(srv)
%REMOTEGETSTATUS Get the global remote status.
%
% Usage :
%   status = REMOTEGETSTATUS(srv)
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg.name        = 'get_status';
    disp (msg)
    retMsg = remoteSendMessage(srv, msg);
    status = retMsg;
end