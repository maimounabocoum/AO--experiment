function remoteStartStopSequence (srv, state)
%REMOTESTARTSTOPSEQUENCE Define the remote server sequence state
%
% Usage :
%   REMOTESTARTSTOPSEQUENCE(srv, state)
%
% Description :
%   Configure the remote server sequence state
%       - state = 0 : sequence stopped
%       - state = 1 : sequence started
%
%   All the necessary fonctions to :
%       - Block in remote state
%       - load the correct(s) sequence(s) have to be perform before send a
%       start
%   must be previously performed
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteDefineServer, remoteBlock, remoteLoadSequence
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.

    msg.name        = 'start_stop_sequence';
    if state
        msg.start       = '1';
    else
        msg.start       = '0';
    end
    remoteSendMessage(srv, msg);
end