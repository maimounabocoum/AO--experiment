function ret = remote3DstartAcquisition (srv)
%remote3DstartAcquisition start an acquisition 3D
%
% Usage :
%   srv = remote3DstartAcquisition(srv)
%
% Description :
%  start the 3d acquisition
%
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/07/09$
%M-File function.
    msg.name      = '3d_start_acquisition';
    ret = remoteSendMessage(srv, msg);
end