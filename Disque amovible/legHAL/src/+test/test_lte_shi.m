clear all; clc; close all; clear classes;

% cd /home/labo/Work/svn/trunk_new/us/legHAL/remote
% addPathRemote
% cd ../src

% Sequence = usse.usse; Sequence = Sequence.selectHardware ; Sequence = Sequence.selectProbe

IPaddress = '192.168.1.217'; % IP address of Aixplorer

LTE = usse.lte();
LTE = LTE.initializeRemote('IPaddress', IPaddress);

Server = LTE.Server;

LTE_SHI = system.lte_shi( Server, 'LTE SHI', 'LTE SHI control' );

% 
LTE_SHI.analog_acq_display