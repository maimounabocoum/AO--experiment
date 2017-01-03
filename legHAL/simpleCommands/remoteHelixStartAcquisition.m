function ret = remoteHelixStartAcquisition (srv, volume_id, acquisition_id, nb_frames)
%REMOTEHELIXSTARTACQUISITION start the 3D acquisition for whole breast scan
%
% Usage :
%   srv = REMOTEHELIXSTARTACQUISITION(srv, volume_id, acquisition_id, nb_frames)
%
% Description :
%   start the 3D acquisition for whole breast scan
%
% Can be used with :
%       argA parameter is required =>volume_id, id of the volume
%                  (like '1')
%       argB parameter is required =>acquisition_id, id of the acquisition 
%                  (like '1')
%       argC parameter is required => nb_frames, number of frames to recard
%                  (like '133')
%
% Note : the remote Server used must be an AixPlorer with the remote
%   option enabled and activated!!!
%Copyright 2010 Supersonic Imagine
%$Revision: 1.00$  $Date: 2010/02/04$
%M-File function.
    msg.name            = 'helix_start_acquisition';
    msg.volume_id       = volume_id;
    msg.acquisition_id  = acquisition_id;
    msg.nb_frames       = nb_frames;
    ret = remoteSendMessage(srv, msg);
end