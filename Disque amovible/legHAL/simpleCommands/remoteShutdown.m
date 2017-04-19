function status = remoteShutdown(srv)
%REMOTESHUTDOWN Shutdown the system.
%
% Usage :
%   REMOTESHUTDOWN(srv)
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg.name        = 'quit_requested';
    disp (msg)
    status = remoteSendMessage(srv, msg);
end