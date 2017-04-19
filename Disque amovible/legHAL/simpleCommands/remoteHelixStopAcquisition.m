function ret = remoteHelixStopAcquisition (srv)
%REMOTEHELIXSTOPACQUISITION stop the 3D acquisition for whole breast scan
%
% Usage :
%   srv = REMOTEHELIXSTOPACQUISITION(srv)
%
% Description :
%   stop the 3D acquisition for whole breast scan
%
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name            = 'helix_stop_acquisition';
    ret = remoteSendMessage(srv, msg);
end