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

Volt        = 35; % V
FreqSonde   = 6;  % MHz
NbHemicycle = 8;
X0          = 15; % mm
Foc         = 35; % mm
NTrig       = 1; %1000
Prof        = 70; % mm

%%====================== Parameters loop
Nloop = 5;

%-----------------------------------------------------------
%% Gage Init parmaters
%----------------------------------------------------------------------
Range = 1; % V
SampleRate = 10; % MHz
TriggerSatus = 'off'; % 'on' or 'off' 




[ret,Hgage] = InitOscilloGage(NTrig,Prof,SampleRate,Range,TriggerSatus);

[ret, acqInfo] = CsMl_QueryAcquisition(Hgage);
CsMl_ErrorHandler(ret, 1, Hgage);

[ret, sysinfo] = CsMl_GetSystemInfo(Hgage); % Get card infos
CsMl_ErrorHandler(ret, 1, Hgage);

CsMl_ResetTimeStamp(Hgage);


% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = 0;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;
% sysinfo : uncomment to get board information
%MaskedMode              = bitand(acqInfo.Mode, 15); % Check acq. mode
%ChannelSkip             = ChannelsPerBoard / MaskedMode; % number of channels that are skipped during
% the transfer step.



%% Initialize Gage Acquisition card
% %% Sequence execution
% % ============================================================================ %
% SEQ = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 , NTrig);
% SEQ = SEQ.loadSequence();
c = common.constants.SoundSpeed ; % sound velocity in m/s

%%========================================== Acquire data==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

close all
Hfig = figure;

clear MyMeasurement
MyMeasurement = oscilloTrace(acqInfo.Depth,acqInfo.SegmentCount,SampleRate*1e6,c) ;
    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    data  = zeros(acqInfo.Depth,1);
    
for k = 1:Nloop
  tic    
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
    
   % SEQ = SEQ.startSequence();
    
    status = CsMl_QueryStatus(Hgage);
    
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end

    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:

    for LineNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = LineNumber;                        % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
        
       % MyMeasurement = MyMeasurement.Addline(actual.ActualStart,actual.ActualLength,datatmp,LineNumber);
       MyMeasurement.Lines((1+actual.ActualStart):actual.ActualLength,LineNumber) = datatmp' ;
       drawnow
%        data = data + (1/NTrig)*datatmp';
%        raw(:,ii) = datatmp';
        
    end

    
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    
   % MyMeasurement.SNR();
    MyMeasurement.ScreenAquisition(Hfig);
   % SEQ = SEQ.stopSequence('Wait', 0);
toc
end

% command line to force a trigger on Gage :
CsMl_ForceCapture(Hgage);


% saving datas:
%MyMeasurement.saveobj('D:\Data\Mai\2017-04-14\1D oscilloscope\G10dB_1000av_X010mm_Volt40_PasseHaut200kHzPasseBas1MHz_Ref')

%SEQ = SEQ.quitRemote();