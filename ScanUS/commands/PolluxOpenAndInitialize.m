function Controller = PolluxOpenAndInitialize(COM_Port)

% modifications 09 Juin  2008, Arik FUNKE
% last modifications 3 mars 2010, Amaury PROST
% last modifications 30 mars 2018, Maïmouna BOCOUM

delete(instrfind('Type','serial','Name',['Serial-COM',num2str(COM_Port)]));

Controller = serial(['COM',num2str(COM_Port)]);
Controller.BaudRate=19200;
Controller.Timeout=3;
% Controller.UserData=0;

%% initiate communication
fopen(Controller);

PolluxClearQueue(Controller)




return