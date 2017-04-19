function ret = remote3DsetPosition (srv, position, speed, option)
%remote3DsetPosition set the position of the probe
%
% Usage :
%   srv = remote3DsetPosition(srv)
%
% Description :
%   read the position of the 3D probe
% Can be used with :
%       argA parameter is required => position, the position to reach in degree
%       (float)
%       argB parameter is required => speed, the speed og the movement in
%       degree/s
%       argC parameter is required => option, 1 if you want to wait the
%       end of the mouvement before the end of the function, 0 otherwise
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
    msg.cmd       = 'set_position';
    msg.position  = position;
    msg.speed     = speed;
    msg.option    = option;
    ret = remoteSendMessage(srv, msg);
end
