function [raw,data,tsdata]=AcqGage(handle,AO)
% multi-trigger acousto-optic signal acquisition synch with an Aixplorer

SEQ = AO.SEQ;
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

% SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
SEQ = SEQ.stopSequence('Wait', 0);

%% Initialize Gage
[ret, acqInfo] = CsMl_QueryAcquisition(handle);
CsMl_ErrorHandler(ret, 1, handle);
[ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
CsMl_ErrorHandler(ret, 1, handle);

CsMl_ResetTimeStamp(handle);

%% Acquire data
ret = CsMl_Capture(handle);
CsMl_ErrorHandler(ret, 1, handle);

tic
SEQ = SEQ.startSequence();

status = CsMl_QueryStatus(handle);
while status ~= 0
    status = CsMl_QueryStatus(handle);
end

toc

SEQ = SEQ.stopSequence('Wait', 0);

%% Prepare transfer to Matlab
% Get timestamp information
transfer.Channel        = 1;
transfer.Mode           = CsMl_Translate('TimeStamp', 'TxMode');
transfer.Length         = acqInfo.SegmentCount;
transfer.Segment        = 1;
[ret, tsdata, tickfr]   = CsMl_Transfer(handle, transfer);

% Get data
% Regardless  of the Acquisition mode, numbers are assigned to channels in a
% CompuScope system as if they all are in use. To calculate the index increment,
% user must determine the number of channels on one CompuScope board and then
% divide this number by the number of channels currently in use on one board.
% The latter number is lower 12 bits of acquisition mode.
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = 0;
transfer.Length         = acqInfo.SegmentSize;

% Prepares the channel numbers that will be transferred : if single mode,
% only chan 1 is used, if dual, chan 1 and 3 only are used, if quad,
% they all are.
MaskedMode              = bitand(acqInfo.Mode, 15); % Check acq. mode
ChannelsPerBoard        = sysinfo.ChannelCount / sysinfo.BoardCount; % get number of channels
ChannelSkip             = ChannelsPerBoard / MaskedMode; % number of channels that are skipped during
% the transfer step.

Nlignes                 = AO.Nlignes; % Number of lines of the scan
%Prof                   = ceil((AO.Prof*1e-3)/common.constants.SoundSpeed*acqInfo.SampleRate);
Prof                    = acqInfo.Depth;

MOD = @(x,y) x-(ceil(x./y)-1)*y; % redefines the matlab mod function so that
% % it is equal to y instead of 0 when x is a multiple of y

%% Transfer data to Matlab
display('Begin data transfer')
tic
data = zeros(Prof,Nlignes,2);
raw = zeros(Prof,Nlignes,AO.actNTrig,2);

chan = 1;
for channel = 1:ChannelSkip:sysinfo.ChannelCount
    transfer.Channel = channel; % Channel to be emptied
    
    for ii = 1:acqInfo.SegmentCount
        transfer.Segment = ii; % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(handle, transfer); % transfer
        % actual contains the actual length of the acquisition that may be
        % different from the requested one.
        CsMl_ErrorHandler(ret, 1, handle);
        
        data(:,MOD(ii,Nlignes),chan)=data(:,MOD(ii,Nlignes),chan)+(1/AO.actNTrig)*datatmp';
        raw(:,MOD(ii,Nlignes),ceil(ii./Nlignes),chan)=datatmp';
        
    end
    
    chan = chan +1;
end

toc

% chan = 1;
% for channel = 1:ChannelSkip:sysinfo.ChannelCount
%     transfer.Channel = channel; % Channel to be emptied
%     
%     for ii = 1:acqInfo.SegmentCount
%         transfer.Segment = ii; % number of the memory segment to be read
%         [ret, datatmp, actual] = CsMl_Transfer(handle, transfer); % transfer
%         % actual contains the actual length of the acquisition that may be
%         % different from the requested one.
%         CsMl_ErrorHandler(ret, 1, handle);
%         
%         data(:,MOD(ii,Nlignes),chan)=data(:,MOD(ii,Nlignes),chan)+(1/AO.actNTrig)*datatmp';
%         raw(:,MOD(ii,Nlignes),ceil(ii./Nlignes))=datatmp';
%         
%     end
%     
%     chan = chan +1;
% end
% 
% toc
% 
% for ii=1:Nlignes
%     data(:,ii,1)=data(:,ii,1)-mean(data(end-2*acqInfo.SampleRate*1e-6:end,ii,1));
%     data(:,ii,2)=data(:,ii,2)-mean(data(end-2*acqInfo.SampleRate*1e-6:end,ii,2));
% end
% 
% figure(32)
% plot(tsdata*1e-6)

%% Stop AO Remote and Release Gage
% SEQ = SEQ.quitRemote();
ret = CsMl_FreeSystem(handle);
