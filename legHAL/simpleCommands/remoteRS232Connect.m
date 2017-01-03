function ret = remoteRS232Connect (srv, device, bauderate, bitData, bitStop, parity)
%REMOTEFREEZE connect serial port on the host machine
%
% Usage :
%   srv = REMOTERS323CONNECT(srv, device, bauderate, bitData, bitStop,
%   parity)
%
% Description :
%   Connect the rs232 port on the host machine
%
% Can be used with :
%       argA parameter is required => device to connect
%                  (like 'ttyS0')
%       argB parameter is required => bauderate, the speed of the connection 
%                  (like '19200')
%       argC parameter is required => bitData, number of bit
%                  (like '8')
%       argD parameter is required => parity, the parity of the connection
%                  (like '0')
%       argE parameter is required => bitArret, the stop bit
%                  (like '1')
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name      = 'rs232_connect';
    msg.device    = device;
    msg.bauderate = bauderate;
    msg.bitData   = bitData;
    msg.parity    = parity;
    msg.bitArret  = bitStop;
    ret = remoteSendMessage(srv, msg);
end