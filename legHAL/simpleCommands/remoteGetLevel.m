function level = remoteGetLevel(srv)
%REMOTESETLEVEL Get the remote level.
%
% Usage :
%   level = REMOTEGETLEVEL(srv)
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteSetLevel
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg.name        = 'get_level';
    disp (msg)
    retMsg = remoteSendMessage(srv, msg);
    level = retMsg.level;
end