%% Script for AO setup optimization. To be used with Aixplorer and Gage
%% acquisition card.
% Display and refresh an acousto-optic line
%
% Created by Clement on 10/06/2015
% Last modified : Clement 10/06/2015


%% Parameters

% US Parameters
    Volt            = 8;
    FreqSonde       = 2.3;
    NbHemicycle     = 2;
    AlphaM          = 0;
    dA              = 0;
    X0              = 0;
    ScanLength      = 0;
    NTrig           = 7680; %repetition du tir us
    Prof            = 300; %gage

%Acquisition parameters
Range = 1; % V
SampleRate = 10; % MHz

%% Security check
if FreqSonde ==15 && Volt>25
    Volt=25;
    warning('Tension max dépassée ! Limite 25 V');
end
% if NbHemicycle > 10 && Volt > 10
%     Volt = 8;
%     warning('Tension max dépassée pour cette longueur de burst. Tension fixée à 8V');
% end


%% Set Aixplorer parameters
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

NoOp       = 5;   % µs minimum time between two US pulses

%% Probe parameters

UF.ImgVoltage = Volt;             % imaging voltage [V]
UF.ImgCurrent = 1;                % security limit for imaging current [A]

% ======================================================================= %
UF.AlphaM     = AlphaM;
UF.dA         = dA;
UF.TwFreq     = FreqSonde;       % MHz
UF.NbHcycle   = NbHemicycle;     %

if dA > 0
    UF.FlatAngles = sort(-abs(UF.AlphaM):UF.dA:abs(UF.AlphaM));   % Planes waves angles (deg)
else
    UF.FlatAngles = UF.AlphaM; 
end

UF.Prof       = Prof;            % mm
UF.PosX       = X0;              % mm
UF.ScanLength = ScanLength;      % mm

UF.SampFreq   = system.hardware.ClockFreq; % NE PAS MODIFIER % emitted signal sampling
UF.PRF        = common.constants.SoundSpeed*1e-3/UF.Prof;  % pulse frequency repetition [MHz]
UF.FIRBandwidth = 90;            % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
UF.DutyCycle  = 1;               % duty cycle [0, 1]

UF.TrigOut    = 10; %ceil(CP.Prof/(common.constants.SoundSpeed*1e-3));  %µs

UF.Repeat     = NTrig ;              % a voir

UF.NoOp       = NoOp ;             % µs minimum time between two US pulses
UF.Pause      = max(UF.NoOp-ceil(1/UF.PRF),system.hardware.MinNoop); % pause duration in µs
UF.RxFreq     = 60;              % Receiving center frequency

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
if UF.ScanLength==0 || round(UF.ScanLength/system.probe.Pitch)>=system.probe.NbElemts
    
    Nbtot = system.probe.NbElemts;
else
    
    Nbtot = round(ScanLength/system.probe.Pitch);    
end

Delay = zeros(Nbtot,length(UF.FlatAngles)); %(µs)

for i = 1:length(UF.FlatAngles)
    
    Delay(:,i) = sin(pi/180*UF.FlatAngles(i))*...
        (1:size(Delay,1))*system.probe.Pitch/(common.constants.SoundSpeed/1000);
    
    Delay(:,i) = Delay(:,i) - min(Delay(:,i));
    
end

for i = 1:length(UF.FlatAngles)
    
    Delay(:,i) = Delay(:,i) + max(max(Delay(:,:)))-max(Delay(:,i));
    
end


DlySmpl=round(Delay*UF.SampFreq);

T_Wf = 0:1/UF.SampFreq:0.5*UF.NbHcycle/UF.TwFreq;
Wf = sin(2*pi*UF.TwFreq*T_Wf);

N_T = length(Wf) + max(max(DlySmpl));
WF_mat = zeros(N_T,size(Delay,1),size(Delay,2));

for kk = 1:length(UF.FlatAngles)
    for j = 1:size(Delay,1)
        WF_mat( DlySmpl(j,kk) + (1:length(Wf)),j,kk) = Wf;
    end
end

WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]

% figure(470)
% for ii=1:size(WF_mat_sign,3)
%     imagesc(WF_mat_sign(:,:,ii))
%     drawnow
%     pause(0.1)
% end

% ======================================================================= %
%% Arbitrary definition of US events

% Elusev
clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ

FC = remote.fc('Bandwidth', UF.FIRBandwidth , 0);
RX = remote.rx('fcId', 1, 'RxFreq', UF.RxFreq, 'QFilter', 2, 'RxElemts', 0, 0);

if UF.PosX<system.probe.Pitch
    FirstElmt = 1;
else
    FirstElmt  = round(UF.PosX/system.probe.Pitch);
end

for nbs = 1:length(UF.FlatAngles)
    
    EvtDur   = ceil(0.5*UF.NbHcycle/UF.TwFreq + max(max(Delay)) + 1/UF.PRF);
    
    WFtmp    = squeeze( WF_mat_sign( :, :, nbs ) );
    
%     
%         figure(471)
%         imagesc(WFtmp)
%         drawnow
%     
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',1,'Delays',0);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary( ...
        'Waveform',WFtmp', ...
        'RepeatCH', 0, ...
        'repeat', 300, ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',FirstElmt:FirstElmt+Nbtot-1, ...
        'DutyCycle', UF.DutyCycle, ...
        0);
    
    
    % Event
    EVENTList{nbs} = remote.event( ...
        'txId', 1, ...
        'rxId', 1, ...
        'noop', UF.Pause, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ...
        0);
    
    %ELUSEV
ELUSEV{nbs} = elusev.elusev( ...
    'tx',           TXList{nbs}, ...
    'tw',           TWList{nbs}, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList{nbs}, ...
    'TrigOut',      UF.TrigOut, ... 0,...
    'TrigIn',       0,...
    'TrigAll',      1, ...
    'TrigOutDelay', 0, ...
    0);

    
end
% % %trig EVENT
EVENT{1} = remote.event(...
    'noop',         5,... %system.hardware.MinNoop, ...   %  µs (5µs mini)
    'duration',     0,... 
     0);

%ELUSEV
%trig in
ELUSEV{2} = elusev.elusev( ...
    'event',        EVENT(1), ...
    'TrigIn',       1,...
    'TrigOut',     0, ... 
    'TrigAll',      0, ...
    'TrigOutDelay', 0, ...
    0);
% ======================================================================= %
%% ELUSEV and ACMO definition

% %ELUSEV
% ELUSEV = elusev.elusev( ...
%     'tx',           TXList, ...
%     'tw',           TWList, ...
%     'rx',           RX,...
%     'fc',           FC,...
%     'event',        EVENTList, ...
%     'TrigOut',      UF.TrigOut, ... 0,...
%     'TrigIn',       0,...
%     'TrigAll',      1, ...
%     'TrigOutDelay', 0, ...
%     0);

%ACMO
ACMO = acmo.acmo( ...
    'elusev',           ELUSEV, ...
    'Ordering',         [2,1], ...
    'Repeat' ,          1, ...
    'NbHostBuffer',     1, ...
    'NbLocalBuffer',    5, ...
    'ControlPts',       900, ...
    'RepeatElusev',     1, ...
    0);

ACMOList{1} = ACMO;

% ======================================================================= %
%% Build sequence

% Probe Param
TPC = remote.tpc( ...
    'imgVoltage', UF.ImgVoltage, ...
    'imgCurrent', UF.ImgCurrent, ...
    0);
%'pushVoltage', 16, ...
 %   'pushCurrent', 1, ...
  %  0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', UF.Repeat+1, ...    'Popup',0, ...
    'DropFrames', 0, ...
    'Loop', 0, ...
    'DataFormat', 'FF', ...
    'Popup', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();
display('Build OK')

%% Initialize Gage Acquisition card
% [ret,handle] = InitGage_1D_reglages(NTrig,Prof,SampleRate,Range);
% 
% [ret, acqInfo] = CsMl_QueryAcquisition(handle);
% CsMl_ErrorHandler(ret, 1, handle);
% [ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
% CsMl_ErrorHandler(ret, 1, handle);
% 
% CsMl_ResetTimeStamp(handle);
% 
% 
% % Set transfer parameters
% transfer.Mode           = CsMl_Translate('Default', 'TxMode');
% transfer.Start          = 0;
% transfer.Length         = acqInfo.SegmentSize;
% 
% MaskedMode              = bitand(acqInfo.Mode, 15); % Check acq. mode
% ChannelsPerBoard        = sysinfo.ChannelCount / sysinfo.BoardCount; % get number of channels
% ChannelSkip             = ChannelsPerBoard / MaskedMode; % number of channels that are skipped during
% % the transfer step.

%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
display('Remote OK')


% Load sequ
SEQ = SEQ.loadSequence();
display('Load OK')

% Start Sequence
% ret = CsMl_Capture(handle);
tic
SEQ = SEQ.startSequence();
% 
dlmwrite('\\192.168.0.10\Trig\yes.txt',[1]);
 pause(80)
%     status = CsMl_QueryStatus(handle);
%     while status ~= 0
%         status = CsMl_QueryStatus(handle);
% 
%     end

SEQ = SEQ.stopSequence('Wait', 0);
toc
% % Transfer data to Matlab
%     raw = zeros(acqInfo.Depth,acqInfo.SegmentCount);
%     data = zeros(acqInfo.Depth,1);
%     Z = linspace(0,Prof,acqInfo.Depth);
%     
%     transfer.Channel = 1;
%     for ii = 1:acqInfo.SegmentCount
%         transfer.Segment = ii; % number of the memory segment to be read
%         [ret, datatmp, actual] = CsMl_Transfer(handle, transfer); % transfer
%         % actual contains the actual length of the acquisition that may be
%         % different from the requested one.
%         CsMl_ErrorHandler(ret, 1, handle);
%         
%         data = data +(1/NTrig)*datatmp';
%         raw(:,ii) = datatmp';
%         
%     end
%     
%     figure (42)
%     plot(Z,smooth(data,20))
%     xlabel ('Depth (mm)')
%     ylabel ('Signal (V)')
% % 
% % % Quit Remote
% % SEQ = SEQ.quitRemote();