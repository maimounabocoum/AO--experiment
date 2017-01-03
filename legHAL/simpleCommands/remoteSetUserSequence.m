function remoteSetUserSequence(srv, sequence)
%REMOTESETUSERSEQUENCE Set the frequency
%
% Usage :
%   REMOTESETUSERSEQUENCE(srv, sequence)
%
%   send user equivalent instructions to the system.
%   each instruction is a pair : action type + value.
%
%   The action type can be :
%       - none      : automatic value used for non filled parameters
%       - value     : use the associated value value
%       - increase  : increase the parameter, without use the value field
%       - decrease  : decrease the parameter, without use the value field
%       - next      : go to the next parameter value (often an increase
%       equivalent).
%
%   The usable parameters are :
%       - frequency_action
%       - frequency_value (res, gen or pen)
%
%       - framerate_action
%       - framerate_value (high, medium or framerate)
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteGetUserSequence
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/04/15$
%M-File function.

    msg = sequence;
    msg.name                = 'set_user_sequence';
    disp (msg)
    remoteSendMessage(srv, msg);
end