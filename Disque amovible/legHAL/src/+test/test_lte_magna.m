clear all; clc; close all; clear classes;

cd /home/labo/Work/svn/trunk_new/us/legHAL/remote
addPathRemote
cd ../src

IPaddress = '192.168.1.217'; % IP address of Aixplorer

LTE = usse.lte();
LTE = LTE.initializeRemote('IPaddress', IPaddress);

Server = LTE.Server;
%%
%SEQ = usse.usse();

Server = LTE.Server;
LTE_Magna = system.lte_magna( Server, 'LTE Magna', 'LTE Magna power supply' );

%%
LTE_Magna.getIdn
%%
LTE_Magna.setLocal
%%
LTE_Magna.setRemote
%%
LTE_Magna.getVoltageLimitation
LTE_Magna.getVoltageLimitationMin
LTE_Magna.getVoltageLimitationMax
LTE_Magna.getVoltage
%%
LTE_Magna.getCurrentLimitation
LTE_Magna.getCurrentLimitationMin
LTE_Magna.getCurrentLimitationMax
LTE_Magna.getCurrent
%%
LTE_Magna.getStatus
%%
LTE_Magna.getMeasureVoltage
LTE_Magna.getMeasureCurrent

%%
LTE_Magna.setCurrent(100);
LTE_Magna.setVoltage(2);

