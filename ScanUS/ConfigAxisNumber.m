%%% configure axis number %%%%%%%

% up to 16 number can be configured in the serial network

%% Fermeture et nettoyage de la memoire
PolluxClose(Controller,COM_Port);
close all
clear all

COM_Port   = 3 ;
Controller = PolluxOpenAndInitialize(COM_Port) ;

%% get axis number 
fprintf(Controller,['getaxisno']);
y = str2double(fscanf(Controller,'%s'))


%% set axis number 
fprintf(Controller,['2' 'setaxisno']);
