
%% include path
 addpath('commands');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 %addpath('subfunctions');


%%  ========================================== initialization of Pollux  ==

COM_Port   = 3 ;
Controller = PolluxOpenAndInitialize(COM_Port);
fprintf(Controller,['1' 'gnv']);
%% set current position as 0

GetPitch(Controller,'2');
GetMotionDirection(Controller,'1');
GetPosition(Controller,'1')
GetVelocity(Controller,'1');
GetAccelerationRamp(Controller,'1');
SetVelocity(Controller,4,'1'); % not working ??

% redefine zero position at current position :
SetZeroHere(Controller,'1')

% moving function
PolluxDepAbs(Controller,0,'1')

% move to calibrated limit switch (position 0 and redefines 0 as absolute reference)
% note : this motion does not account for software limit switches
PolluxMoveCal(Controller,'2')

% move to Range measurement (position 151mm )
% note : this motion does not account for software limit switches
PolluxRangeCal(Controller,'1')

GetSwitchStatus(Controller,'1')% not working, suppose to return  [0 , 0] format

% software limit switches 
% this function is overwritten after running PolluxMoveCal
% this function is not updated if one is outside of the limit range
Limits = GetSoftwareLim(Controller,'1')
SetLimitRange(Controller,10,20,'1')







% get last error
code = GetLastError(Controller,'2')

%% Fermeture et nettoyage de la memoire
PolluxClose(Controller,COM_Port);
close all
clear all

%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote()      ;
%               ret = CsMl_FreeAllSystems   ;
%               restoredefaultpath 