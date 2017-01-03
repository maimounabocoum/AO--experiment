display('Building sequence')

addpath('D:\legHAL')
addPathLegHAL;

CP.TrigOut = 100;
CP.Repeat = 2;

% System parameters (parametres ajustables)
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

FC = remote.fc('Bandwidth', 100 , 1);
RX = remote.rx('fcId', 1, 'RxFreq', 60, 'QFilter', 2, 'RxElemts', 0, 1);

% Flat TX
TXList = remote.tx_arbitrary('txClock180MHz', 1,'twId',1);
%TXList = remote.tx_arbitrary('txClock180MHz', 1,'twId',nbs);

% Arbitrary TW
%TWList = remote.tw_arbitrary( ...
TWList = remote.tw_arbitrary( ...
    'RepeatCH', 0, ...
    'repeat',0 , ...
    'repeat256', 0, ...
    'ApodFct', 'none', ...
    'TxElemts',1, ...
    'DutyCycle', 1, ...
    0);


EVENT = remote.event(...
    'numSamples', 0, ...
    'skipSamples', 0, ...
    'noop',         system.hardware.MinNoop, ...
    'duration',     200,...    'genExtTrig',    CP.TrigOut,...
    1);

ELUSEV = elusev.elusev( ...
    'event',        EVENT, ...
    'TrigIn',       0,...
    'TrigOut',      CP.TrigOut, ... % trig out duration  microsecond
    'TrigAll',      0, ...
    'TrigOutDelay', 0, ...
    0);

ACMO = acmo.acmo( ...
    'elusev', ELUSEV, ...
    'Ordering', 0, ... %
    'Repeat' ,1, ...
    'NbHostBuffer', 1, ...
    'NbLocalBuffer', 1, ...
    'ControlPts',   900,...
    0);

% Probe Param
TPC = remote.tpc( ...
    'imgVoltage', 50, ...
    'imgCurrent', 1, ...
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMO, ...
    'Loopidx',1, ...
    'Ordering',1, ...
    'Repeat', CP.Repeat, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();
display('Build OK')

%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
display('Remote OK')

% Load sequ
SEQ = SEQ.loadSequence();
display('Load OK')


disp('-------------Sequence loaded, ready to use-------------------- ')