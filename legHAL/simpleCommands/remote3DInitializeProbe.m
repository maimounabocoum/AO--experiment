function ret = remote3DInitializeProbe (srv)
%remote3DInitializeProbe return the position of the probe
%
% Usage :
%   srv = remote3DInitializeProbe(srv)
%
% Description :
%   init the 3D probe
% 
%
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/07/09$
%M-File function.
    msg.name      = '3d_command';
    msg.cmd       = 'initialize';
    ret = remoteSendMessage(srv, msg);
end