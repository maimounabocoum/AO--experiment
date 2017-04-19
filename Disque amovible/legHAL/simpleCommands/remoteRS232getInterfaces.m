function ret = remoteRS232getInterfaces (srv, device)
%REMOTERS323GETINTERFACES return the serial port on the host machine
%
% Usage :
%   srv = REMOTERS323GETINTERFACES(srv, device)
%
% Description :
%   find the rs232 port on the host machine
%
% Can be used with :
%       argA parameter is required => device, the device to search
%                                     "ttyS" or ttyUSB"
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name      = 'rs232_get_interface';
    msg.device    = device;
    ret = remoteSendMessage(srv, msg);
end