function remoteSetOutputFormat(srv, format)
%REMOTESETOUTPUTFORMAT Define the output data format
%
% Usage :
%   REMOTESETOUTPUTFORMAT(srv, format)
%
% Description :
%    Define the output data format. where : 
%       - format = 'RF' : work only on the RF module. The client will send a RF
%       sequence and retrieve RF files.
%       - format = 'BF' : work up to the BF module. The client will send a RF
%       sequence + a BF sequence (a LUT). It will retrieve BF files.
%
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteDefineServer, remoteSetLevel
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.

    msg.name      = 'set_output_format';
    msg.format    = format;
    remoteSendMessage(srv, msg);
end