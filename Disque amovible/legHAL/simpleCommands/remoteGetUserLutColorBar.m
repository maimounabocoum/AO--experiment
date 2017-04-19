function lut = remoteGetUserLutColorBar(srv)
%remoteGetUserLutColorBar Get the user sequence current lut values
%
% Usage :
%   lut = remoteGetUserLutColorBar(srv)
% 
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteSetUserSequence
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg.name        = 'get_user_lut_color_bar';
    disp (msg)
    lut = remoteSendMessage(srv, msg);
end