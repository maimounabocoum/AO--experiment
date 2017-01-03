function PolluxWaitToFinish(Controller,Axis)

% PolluxWaitToFinish(Controller)
%
% last modifications 11 Juin  2008, Arik FUNKE

PolluxClearQueue(Controller)

%wait until motor has executed the last command
fprintf(Controller, [num2str(Axis) ' nst']);
while(str2double(fscanf(Controller, '%s'))==1)
    pause(0.01)
    fprintf(Controller, [num2str(Axis) ' nst']);
end
