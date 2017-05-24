%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : maimouna bocoum

% ============================== Init program ======================

%  clear all; close all; clc
%  w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%  clear all;

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

Volt        = 50; % V
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
    
for k = 1:Nloop
  tic      
    switch AIXPLORER_Active
    case 'on'
    SEQ = SEQ.startSequence('Wait',0);
    close;
    end
    
    filecount = filecount * ds.ChannelCount;
    CsMl_StartDiskStream(Hgage);
    while (0 == CsMl_GetDiskStreamStatus(Hgage, 500))
		% The following code can be used to moniter the acquisition and write status
		% of the driver.  To optimize performance you would probably want to remove the
		% lines of code below.  Because the acquisition and write routines are 
		% seperate threads, the counts will often appear to jump instead of increment by
		% one each time.
        ac = CsMl_GetDiskStreamAcqCount(Hgage);
        wc = CsMl_GetDiskStreamWriteCount(Hgage);
        s = sprintf('Acq Count: %d out of %d \tWrite Count: %d out of %d',...
                                ac, ds.AcqCount, wc, filecount);
        disp(s);
    end;
   
    CsMl_StopDiskStream(Hgage); 
    ret = CsMl_GetDiskStreamError(Hgage);
    if ret ~= 1
	    if  ret == -9999
	        disp('File or directory error. See event log more more details.');
        else
            disp(CsMl_GetErrorString(errmsg));
        end;
    end;
    %[ret,upData] = Mex_StartStreaming(Hgage,false);  
    %CsMl_ErrorHandler(ret, 1, Hgage);
    

    % Transfer data to Matlab
    % loop over segment counts:

%     for LineNumber = 1:acqInfo.SegmentCount
%         
%         transfer.Segment       = LineNumber ;                       % number of the memory segment to be read
%         [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
%                                                                     % actual contains the actual length of the acquisition that may be
%                                                                     % different from the requested one.
%        MyMeasurement.Lines((1+actual.ActualStart):actual.ActualLength,LineNumber) = datatmp' ;
%         
%     end

   %MyMeasurement.ScreenAquisition();
   
   switch AIXPLORER_Active
   case 'on'
   SEQ = SEQ.stopSequence('Wait', 0);  
   end
   
% if MyMeasurement.IsRunning == 0
%     break;
% end
   
    
toc
end

%% command line to force a trigger on Gage :



% saving datas:
%MyMeasurement.saveobj(['','ms.mat'])
clear MyMeasurement
%SEQ = SEQ.quitRemote();
