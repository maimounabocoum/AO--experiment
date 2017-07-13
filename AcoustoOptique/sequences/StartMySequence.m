function [ SEQ ] = StartMySequence( SEQ )
% creation of a nex function without pop-up windows
% By Maimouna Bocoum - 13/07/2017

%% check is sequence is running :
    Msg    = struct('name', 'get_status');
    Status = remoteSendMessage(SEQ.Server, Msg) ;
%     
%     IsRunning = Status.rfsequencerunning 

%% Start the sequence

%Start loaded sequence
Msg = struct('name', 'start_stop_sequence', 'start', 1);
Status = remoteSendMessage(SEQ.Server, Msg);

% Sequence was not correctly started
if ~strcmpi(Status.type, 'ack')    
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE sequence could not be started.';
    error(ErrMsg);
    
end



end

