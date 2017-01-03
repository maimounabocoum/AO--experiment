% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc)
% INITIALISATION DE LA SEQUENCE D'ACQUISITION PAR BLOCS

addpath('C:\legHAL')
addPathLegHAL;

% System parameters (parametres ajustables)
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

%Param US
Volt = 50; %tension à envoyer dans la sonde en V (attention a la limite max)
FreqSonde = 6; %frequence de la sonde en MHz
NbHemicycle=8; %Nombre d'hémicycles a pulser

%Pour le scan 2D
UF.Prof=40; %UF.Profondeur à explorer dans la direction des US
aMax=20; %angle max
da=0.5;  %pas du scan
%% Probe parameters

ImgVoltage = Volt;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]

% ======================================================================= %

UF.TwFreq     = FreqSonde;       % MHz
UF.NbHcycle   = NbHemicycle;     %
UF.FlatAngles = -aMax:da:aMax;   % Planes waves angles (deg)
UF.Prof       = Prof;            % mm

UF.SampFreq   = system.hardware.ClockFreq; % NE PAS MODIFIER % emetted signal sampling
UF.PRF        = common.constants.SoundSpeed*1e-3/UF.Prof;  % pulse frequency repetition [MHz]

UF.DutyCycle  = 1;               % duty cycle [0, 1]

UF.TrigOut    = UF.Prof*common.constants.SoundSpeed*1e-3;

UF.Repeat     = NTrig ;              % a voir

UF.Pause      = max(100e-6-1/UF.PRF*1e-6,system.hardware.MinNoop*1e-6); % pause duration in s

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform

Delay = zeros(system.probe.NbElemts,length(UF.FlatAngles)); %(µs)

for i = 1:length(UF.FlatAngles)
    
    Delay(:,i) = tan(pi/180*UF.FlatAngles(i))*...
        (1:system.probe.NbElemts)*system.probe.Pitch/(common.constants.SoundSpeed/1000);
    
    Delay(:,i) = Delay(:,i) - min(Delay(:,i));
    
end

DlySmpl=round(Delay*UF.SampFreq);

T_Wf = 0:1/UF.SampFreq:0.5*UF.NbHcycle/UF.TwFreq;
Wf = sin(2*pi*UF.TwFreq*T_Wf);

N_T = length(Wf) + max(DlySmpl);
WF_mat = zeros(N_T,system.probe.NbElemts,length(UF.FlatAngles));

for kk = 1:length(UF.FlatAngles)
    for j = 1:system.probe.NbElemts
        WF_mat( DlySmpl(j,kk) + (1:length(Wf)),j,kk) = Wf;
    end
end

WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]

% ======================================================================= %
%% Arbitrary definition of US events

% Elusev
clear ELUSEV

if round((UF.PosX+ScanLength)/system.probe.Pitch)>system.probe.NbElemts
    
    warning('Scan length too long, set to maximum value')
    ScanLength=system.probe.NbElemts*system.probe.Pitch-UF.PosX;
    
end

for nbs = 1:length(UF.FlatAngles)
    
    EvtDur   = 1/UF.PRF + 0.5*UF.NbHcycle/UF.TwFreq + max(Delay) + UF.Pause*1e6;
    
    WFtmp    = squeeze( WF_mat_sign( :, :, nbs ) );
    
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',nbs);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary( ...
        'Waveform',WFtmp', ...
        'RepeatCH', 0, ...
        'repeat',0 , ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',1:system.probe.NbElemts, ...
        'DutyCycle', UF.DutyCycle, ...
        0);
    
    
    % Event
    EVENTList{nbs} = remote.event( ...
        'txId', nbs, ...
        'noop', system.hardware.MinNoop, ...
        'numSamples', 0, ...
        'skipSamples', 0, ...
        'duration', EvtDur, ...
        0);
    
end

% ======================================================================= %
%% ELUSEV and ACMO definition

%ELUSEV
ELUSEV = elusev.elusev( ...
    'tx',           TXList, ...
    'tw',           TWList, ...
    'event',        EVENTList, ...
    'TrigOut',      UF.TrigOut,...
    'TrigIn',       0,...
    'TrigAll',      1, ...
    'TrigOutDelay', 0, ...
    0);

%ACMO
ACMO = acmo.acmo( ...
    'elusev', ELUSEV, ...
    'Ordering', 0, ...
    'Repeat' , 1, ...
    'NbHostBuffer', 1, ...
    'NbLocalBuffer', 1, ...
    0);

% ======================================================================= %
%% Build sequence

% Probe Param
TPC = remote.tpc( ...
    'imgVoltage', ImgVoltage, ...
    'imgCurrent', ImgCurrent, ...
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMO, ...
    'Repeat', UF.Repeat+1, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();

%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
Sequence = Sequence.initializeRemote('IPaddress',AixplorerIP);

% Load sequ
Sequence = Sequence.loadSequence();

disp('-------------Sequence loaded, ready to use-------------------- ')