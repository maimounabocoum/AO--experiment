function remoteSetLevel(srv, level)
%REMOTESETLEVEL Change the remote level.
%
% Usage :
%   REMOTESETLEVEL(srv, level)
%
% Description :
%   Change the remote level. With :
%       - level = "user_coarse"
%       - level = "user_fine"
%       - level = "system"
%
%   The system level blocks all AixPlorer processes in a remote 'hub'. 
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteDefineServer, remoteFreeze
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.

    msg.name        = 'set_level';
    msg.level       = level;
    disp (msg)
    remoteSendMessage(srv, msg);
end