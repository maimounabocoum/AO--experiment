function PolluxClose(Controller,COM_Port)

fclose(Controller);
delete(instrfind('Type','serial','Name',['Serial-COM',num2str(COM_Port)]));

return