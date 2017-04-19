function status = remoteCheckVersion(srv, clientVersion)
%REMOTECHECKVERSION Compare local and server version.
%
% Usage :
%   status = remoteCheckVersion(srv, version)
%
%   The fuction return :
%       - equal : if true, client and server are equal
%       - compatible : if equal = fale, client and server are not version
%           equal but are compatible
%       - server_version : the server version
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg.name        = 'check_remote_version';
    msg.version     = clientVersion;
    retMsg = remoteSendMessage(srv, msg);
    status = retMsg;
end