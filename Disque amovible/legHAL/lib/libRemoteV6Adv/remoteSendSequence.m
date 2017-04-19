%REMOTESENDSEQUENCE send a sequence to the remote server
%
% Usage :
%   REMOTESENDSEQUENCE(srv, sequence)
%
% Description :
%   Send a sequence to the remote server. The sequence is composed of many
%   parts where the principals are :    
%       - RF
%           - event
%           - tx
%           - tw
%           - rx
%           - fc
%           - mode
%           - dmaControl
%           - tgc
%           - tpc
%       - BF
%           - acqInfo
%           - reconInfo
%           - reconDelay
%           - reconMux
%           - reconAbsc
%       - ...
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also the SyntheticaloneV2.m reference sequence
% See also the user's guide
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%Mex-File function