%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : Clement 10/06/2015

addpath('..\legHAL\')

%% Parameters loop
Nloop = 1;
%% Set Aixplorer parameters
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
% SRV = remoteDefineServer( 'extern' ,AixplorerIP,'9999');
% SEQ = remoteGetUserSequence(SRV);

% US Parameters
Volt        = 20; % V
FreqSonde   = 6;  % MHz
NbHemicycle = 8;
X0          = 15; % mm
Foc         = 20; % mm
NTrig       = 1000; %1000
Prof        = 70; % mm

%-----------------------------------------------------------
%% Gage Init parmaters
%----------------------------------------------------------------------

[ret,handle] = InitOscilloGage(NTrig,Prof,SampleRate,Range);

[ret, acqInfo] = CsMl_QueryAcquisition(handle);
CsMl_ErrorHandler(ret, 1, handle);
[ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
CsMl_ErrorHandler(ret, 1, handle);

CsMl_ResetTimeStamp(handle);


% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = 0;
transfer.Length         = acqInfo.SegmentSize;

MaskedMode              = bitand(acqInfo.Mode, 15); % Check acq. mode
ChannelsPerBoard        = sysinfo.ChannelCount / sysinfo.BoardCount; % get number of channels
ChannelSkip             = ChannelsPerBoard / MaskedMode; % number of channels that are skipped during
% the transfer step.



%% Initialize Gage Acquisition card
% %% Sequence execution
% % ============================================================================ %
 SEQ = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 );
 SEQ = SEQ.loadSequence();

for loop = 1:Nloop

 SEQ = SEQ.startSequence();
 pause(1)
 SEQ = SEQ.stopSequence();
 close all

 
end
 

SEQ = SEQ.quitRemote();