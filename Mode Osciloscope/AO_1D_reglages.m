%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : Clement 10/06/2015

addpath('..\legHAL\')

%% Parameters loop
Nloop = 5;
%% Set Aixplorer parameters
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
% SRV = remoteDefineServer( 'extern' ,AixplorerIP,'9999');
% SEQ = remoteGetUserSequence(SRV);

% US Parameters
Volt        = 40; % V
FreqSonde   = 6;  % MHz
NbHemicycle = 8;
X0          = 10; % mm
Foc         = 35; % mm
NTrig       = 1000; %1000
Prof        = 70; % mm

%-----------------------------------------------------------
%% Gage Init parmaters
%----------------------------------------------------------------------
Range = 1; % V
SampleRate = 10; % MHz
c = common.constants.SoundSpeed ; % sound velocity in m/s

[ret,Hgage] = InitOscilloGage(NTrig,Prof,SampleRate,Range);

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
 SEQ = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 , NTrig);
 SEQ = SEQ.loadSequence();

%% Acquire data
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
    
    SEQ = SEQ.startSequence();
    
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
%        data = data + (1/NTrig)*datatmp';
%        raw(:,ii) = datatmp';
        
    end

    
    CsMl_ErrorHandler(ret, 1, Hgage);
    SEQ = SEQ.stopSequence('Wait', 0);
    
   % MyMeasurement.SNR();
    MyMeasurement.ScreenAquisition(Hfig);
    
toc
end

% saving datas:
MyMeasurement.saveobj('D:\Data\Mai\2017-04-14\1D oscilloscope\G10dB_1000av_X010mm_Volt40_PasseHaut200kHzPasseBas1MHz_Ref')

SEQ = SEQ.quitRemote();