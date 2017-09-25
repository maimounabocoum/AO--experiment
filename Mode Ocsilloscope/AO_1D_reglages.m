%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : maimouna bocoum

%============================== Init program ======================

%  clear all; close all; clc
%  w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%  clear all;
 
%   clear all; clc
%  w = instrfind; if ~isempty(w) delete(w); end
%  clear all;
 
 %=================== indicate location of LEGAL folder
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 %==================== indicate location for Gage Drivers
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 
 

%%====================== Set Aixplorer parameters
% adresse Bastille : '192.168.0.20'
% adresse Jussieu : '192.168.1.16'

AixplorerIP    = '192.168.0.20'; % IP address of the Aixplorer device
% SRV = remoteDefineServer( 'extern' ,AixplorerIP,'9999');
% SEQ = remoteGetUserSequence(SRV);
%=======================  US Parameters =====================

Volt        = 40; % V
FreqSonde   = 4;  % MHz
NbHemicycle = 4;
X0          = 18; % mm
Foc         = 45; % mm
NTrig       = 1000; %1000
Prof        = 80; % mm 800 gain

%%====================== Parameters loop
Nloop = 500;

%-----------------------------------------------------------
%% Gage Init parmaters
%----------------------------------------------------------------------
Range = 1; % V
SampleRate = 10; % MHz
GageActive = 'on'; % 'on' or 'off' 
AIXPLORER_Active = 'on'; % 'on' or 'off' 



[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig,Prof,SampleRate,Range,GageActive);
fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
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
MyMeasurement = oscilloTrace(acqInfo.SegmentSize,acqInfo.SegmentCount,acqInfo.SampleRate,c) ;
MyMeasurement =  MyMeasurement.InitGUI() ;
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
        % number of the memory segment to be read
        % transfer
        % actual contains the actual length of the acquisition that may be
        % different from the requested one.
        transfer.Segment       = LineNumber ;                       
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    
                                                                    
       
       actual                                                            
       MyMeasurement.Lines((1+actual.ActualStart):actual.ActualLength,LineNumber) = datatmp' ;
        
    end

%        y = sum(MyMeasurement.Lines')/NTrig;
%        n = round(length(y)*0.66);
%        Err= std(y(n:end))
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    
  MyMeasurement.ScreenAquisition();
   
   switch AIXPLORER_Active
   case 'on'
   SEQ = SEQ.stopSequence('Wait', 1);  
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






