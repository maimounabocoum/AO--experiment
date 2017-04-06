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

%% Acquire data
for k = 1:Nloop
    ret = CsMl_Capture(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
    SEQ = SEQ.startSequence();
    
    status = CsMl_QueryStatus(handle);
    
    while status ~= 0
        status = CsMl_QueryStatus(handle);
    end

    % Transfer data to Matlab
    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    data  = zeros(acqInfo.Depth,1);
    Z     = linspace(0,Prof,acqInfo.Depth);
    
    transfer.Channel = 1;
    for ii = 1:acqInfo.SegmentCount
        transfer.Segment = ii; % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(handle, transfer); % transfer
        % actual contains the actual length of the acquisition that may be
        % different from the requested one.
        CsMl_ErrorHandler(ret, 1, handle);
        
        data = data + (1/NTrig)*datatmp';
        raw(:,ii) = datatmp';
        
    end
    
    SEQ = SEQ.stopSequence('Wait', 0);
    
    % plot singal 1D and its S/N:
    
    
    figure (42) %
    plot(Z,data)
    xlabel ('Depth (mm)')
    ylabel ('Signal (V)')
    title('Raw data')
    
    hold on 
    plot(Z,smooth(data,10),'color','red')
    xlabel ('Depth (mm)')
    ylabel ('Signal (V)')
    title('Smoothed data')
%     data_end(:,k)=data;
    fullDate = datestr(now,'yyyy-mm-dd_MM_ss');

     if(Sauvegarde == 1)
        mkdir([path '\' Date]);
        save([path '\' Date '\' Name '-' fullDate '.mat'],'Z','data','raw', 'Volt','FreqSonde',...
                    'NbHemicycle', 'X0', 'Foc', 'NTrig', 'Prof', 'Range', 'SampleRate');
     end
    hold off
end


SEQ = SEQ.quitRemote();