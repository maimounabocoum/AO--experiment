%REMOTEGETSHMRFDATA get raw data from the remote server
%
% Usage :
%   REMOTEGETSHMRFDATA(srv, buffer[,functionToCall])
%
% Description :
%   Get in buffer the remote server raw data. Data are
%   retrieved from the HAL module.
%
%   functionToCall : string function name to call every 50 mS in wait case
%     the specified function must return a logical value
%
%           function example:
%
%               function ret = fctToCall()
%                   ret = logical(0);
%               end
%
%   !!!In priority, use the RemoteTransferData which set the buffer before
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteDefineServer, RemoteTransferData (for buffer definition)
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%Mex-File function