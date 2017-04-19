function remoteFreeze (srv, state)
%REMOTEFREEZE Define the remote server freeze state
%
% Usage :
%   REMOTEFREEZE(srv, state)
%
% Description :
%   Configure the remote server freeze state . With :
%       - state = 0 : unblocked
%       - state = 1 : blocked
%
%   This option performe a 'classic' freeze on the Aixplorer. In opposition
%   to the remoteBlock status wherer the system is blocked to allow many
%   remote opreations
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteDefineServer, remoteBlock
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name      = 'freeze';
    msg.active    = state;
    remoteSendMessage(srv, msg);
end