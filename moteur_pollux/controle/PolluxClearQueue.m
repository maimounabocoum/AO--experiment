function PolluxClearQueue(Controller)

% PolluxClearQueue(Controller)
%
% last modifications 11 Juin  2008, Arik FUNKE


%clear return queue
if Controller.BytesAvailable > 0
    fscanf(Controller, '%s', Controller.BytesAvailable);
end

return