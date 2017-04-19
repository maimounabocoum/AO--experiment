function sequence = remoteGetUserSequence(srv)
%REMOTEGETUSERSEQUENCE Get the user sequence parameters
%
% Usage :
%   sequence = REMOTEGETUSERSEQUENCE(srv)
% 
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteSetUserSequence
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg.name        = 'get_user_sequence';
    disp (msg)
    sequence = remoteSendMessage(srv, msg);
end