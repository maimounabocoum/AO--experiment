clear all; clc; close all; clear classes;

cd /home/labo/Work/svn/trunk_new/us/legHAL/remote
addPathRemote
cd ../src

IPaddress = '192.168.1.217'; % IP address of Aixplorer

SEQ = usse.lte();
SEQ = SEQ.initializeRemote('IPaddress', IPaddress);

Server = SEQ.Server;

LTE = system.lte( Server, 'LTE', 'Liver Therapy System' );

%%
LTE.shi.init_mode(2)
LTE.shi.report_and_clear_alarms()
LTE.shi.analog_acq_display()

%%
LTE.shi.set_imaging_hv(25)

%%
LTE.magna.getIdn
%%
LTE.magna.setLocal
%%
LTE.magna.setRemote
%%
LTE.magna.getVoltageLimitation
LTE.magna.getVoltageLimitationMin
LTE.magna.getVoltageLimitationMax
LTE.magna.getVoltage
%%
LTE.magna.getCurrentLimitation
LTE.magna.getCurrentLimitationMin
LTE.magna.getCurrentLimitationMax
LTE.magna.getCurrent
%%
LTE.magna.getStatus
%%
LTE.magna.getMeasureVoltage
LTE.magna.getMeasureCurrent
%%
LTE.magna.setCurrent(100);
LTE.magna.setVoltage(2);

%%
% Msg = struct('name', 'set_level', 'level', 'system');
% Status = remoteSendMessage(Server, Msg);
%%
% Msg = struct('name', 'set_level', 'level', 'fine');
% Status = remoteSendMessage(Server, Msg);
    
% Msg    = struct('name', 'freeze', 'active', 0);
% Status = remoteSendMessage(Server, Msg);

%%
% remoteFreeze( Server, 0 );
