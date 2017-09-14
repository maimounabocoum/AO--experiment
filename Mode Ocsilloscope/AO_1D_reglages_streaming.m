%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : maimouna bocoum

% ============================== Init program ======================

 clear all; close all; clc
 w = instrfind; if ~isempty(w) fclose(w); delete(w); end
 clear all;

 %=================== indicate location of LEGAL folder
 %addpath('D:\legHAL\')
 %addPathLegHAL;

 %==================== indicate location for Gage Drivers
 %addpath(genpath('D:\drivers\CompuScope MATLAB SDK\'))
 
 

%%====================== Set Aixplorer parameters
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
% SRV = remoteDefineServer( 'extern' ,AixplorerIP,'9999');
% SEQ = remoteGetUserSequence(SRV);
%=======================  US Parameters =====================

Volt        = 20; % V
FreqSonde   = 4;  % MHz
NbHemicycle = 10;
X0          = 15; % mm
Foc         = 25; % mm
NTrig       = 100; %1000
Prof        = 70; % mm

%%====================== Parameters loop
Nloop = 1;

%-----------------------------------------------------------
%% Gage Init parmaters
%----------------------------------------------------------------------
Range = 1; % V
SampleRate = 10; % MHz
GageActive = 'off'; % 'on' or 'off' 
AIXPLORER_Active = 'off'; % 'on' or 'off' 



[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig,Prof,SampleRate,Range,GageActive);

% the following are application specific. 
ds.ChannelCount     = 1;
ds.Timeout          = -1;
ds.TransferStart    = -acqInfo.TriggerHoldoff;
ds.TransferLength   = acqInfo.SegmentSize;
ds.RecordStart      = 1;
ds.RecordCount      = acqInfo.SegmentCount;
ds.AcqCount         = 1;

[ret, filecount] = CsMl_InitializeDiskStream(Hgage, 'Signal Files' , 1 , ds);
CsMl_ErrorHandler(ret, 1, Hgage);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = 0;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

%% Initialize Gage Acquisition card
% %% Sequence execution
% % ============================================================================ %
switch AIXPLORER_Active
    case 'on'
 SEQ = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 , NTrig);
 SEQ = SEQ.loadSequence();
end
 c = common.constants.SoundSpeed ; % sound velocity in m/s

%%========================================== Acquire data==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

clear MyMeasurement
%MyMeasurement = oscilloTrace(acqInfo.Depth,acqInfo.SegmentCount,acqInfo.SampleRate,c) ;
 
% % for k = 1:Nloop
% %  
% % end
% parfor i = 1:2
%     if i == 1
%       a = 1
%     else
%       b = 1
%     end
% end



%% command line to force a trigger on Gage :



% saving datas:
%MyMeasurement.saveobj(['','ms.mat'])
clear MyMeasurement
%SEQ = SEQ.quitRemote();
