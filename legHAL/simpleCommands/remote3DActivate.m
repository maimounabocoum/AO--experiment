function ret = remote3DActivate (srv, active)
%remote3DActivate activate or unactive the remote 3D
%
% Usage :
%   srv = remote3DActivate(srv, active)
%
% Description :
%   activate or unactive the remote 3D
% Can be used with :
%       argA parameter is required => active, if 1 3D remote will be
%       activate, if 0 3D will be unactivate
%
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/07/09$
%M-File function.
    msg.name      = '3d_command';
    msg.cmd       = 'activate';
    msg.active    = active;
    ret = remoteSendMessage(srv, msg);
end