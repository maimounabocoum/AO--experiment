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

Volt        = 50; % V
FreqSonde   = 2;  % MHz
NbHemicycle = 10;
X0          = 15; % mm
Foc         = 28; % mm
NTrig       = 5000; %1000
Prof        = 50; % mm

%%====================== Parameters loop
Nloop = 1000;

%-----------------------------------------------------------
%% Gage Init parmaters
%----------------------------------------------------------------------
Range = 1; % V
SampleRate = 10; % MHz
GageActive = 'on'; % 'on' or 'off' 
AIXPLORER_Active = 'on'; % 'on' or 'off' 



[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig,Prof,SampleRate,Range,GageActive);

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

%% ========================================== Acquire data==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

clear MyMeasurement
MyMeasurement = oscilloTrace(acqInfo.Depth,acqInfo.SegmentCount,acqInfo.SampleRate,c) ;
    
for k = 1:Nloop
  tic    
     ret = CsMl_Capture(Hgage);
     CsMl_ErrorHandler(ret, 1, Hgage);
   
    switch AIXPLORER_Active
    case 'on'
    SEQ = SEQ.startSequence('Wait',0);
    close;
    end
  
    
    status = CsMl_QueryStatus(Hgage);
    
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end

    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:

    for LineNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = LineNumber ;                       % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
       MyMeasurement.Lines((1+actual.ActualStart):actual.ActualLength,LineNumber) = datatmp' ;
        
    end

%        y = sum(MyMeasurement.Lines')/NTrig;
%        n = round(length(y)*0.66);
%        Err= std(y(n:end))
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    
  MyMeasurement.ScreenAquisition();
   
   switch AIXPLORER_Active
   case 'on'
   SEQ = SEQ.stopSequence('Wait', 0);  
   end
   
if MyMeasurement.IsRunning == 0
    break;
end
   
    
toc
end

%% command line to force a trigger on Gage :



 %% ================================ saving datas:========================================%%
%save('foldername','MyMeasurement');
clear MyMeasurement

%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote();






