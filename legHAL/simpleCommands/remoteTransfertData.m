function [buffer, status] = remoteTransfertData (srv, dataType)
%REMOTETRANSFERTDATA get data from the remote server
%
% Usage :
%   buffer = REMOTETRANSFERTDATA(srv, state)
%
% Description :
%   Get data from the remote server.Following the type, the data are
%   retrieved from a different location in the server
%       - dataType = 'RF' : get raw files from the HAL module
%       - dataType = 'BF' : get beamformed fiels from the SP module
%       - dataType = 'FF' : get final image screencast acquisition from Screen module
%       - dataType = 'SWE' : get SWE data from the SP module (user mode)
%
%   All the necessary fonctions to :
%       - Block in remote state
%       - load the correct(s) sequence(s) have to be perform before send a
%       start
%       - launch the sequence
%
%   must be previously performed
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%
% See also remoteDefineServer, remoteBlock, remoteLoadSequence,
% remoteStartStopSequence
%
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.

    if strcmp(dataType, 'RF')
        buffer.alignedOffset        = uint32(0);
        buffer.data                 = int16(0);
        buffer.mode                 = uint32(0);
        remoteGetRFData(srv,buffer);
    elseif strcmp(dataType, 'BF')
        buffer.data = int16(0);
        buffer.nline = uint32(0);
        buffer.nsample = uint32(0);
        buffer.bytesample = uint32(0);
        remoteGetBFData(srv,buffer);
    elseif strcmp(dataType, 'FF')
        buffer.data = int8(0);
        status = remoteGetFFData(srv,buffer);
    elseif strcmp(dataType, 'SWE')
        buffer.data = single(0);
        status = remoteGetSweData(srv,buffer);
    else
        error ('The asked dataType is not known!')
    end
end
