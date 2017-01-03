% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc)
% INITIALISATION DE LA SEQUENCE D'ACQUISITION PAR BLOCS

addpath('C:\legHAL')
addPathLegHAL;

% System parameters (parametres ajustables)
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

% %Param US
% Foc = 20;%Profondeur de focalisation des US en mm; on définit D pour que f/D=1;
% Volt = 50; %tension à envoyer dans la sonde en V (attention a la limite max)
% FreqSonde = 6; %frequence de la sonde en MHz
% NbHemicycle=8; %Nombre d'hémicycles a pulser
% 
% %Pour le scan 2D
% X0 = 7; %position de départ du scan en X, mm
% ScanLength = 40; %longueur à explorer, mm
% Prof=40; %profondeur à explorer dans la direction des US
%% Probe parameters

ImgVoltage = Volt;             % imaging voltage [V]
ImgCurrent = 0.1;            % security limit for imaging current [A]

% ======================================================================= %

CP.TwFreq     = FreqSonde;       % MHz
CP.NbHcycle   = NbHemicycle;     %
CP.PosX       = X0;              % mm
CP.PosZ       = Foc;             % mm
CP.TxWidth    = Foc/2;           % mm

CP.SampFreq   = system.hardware.ClockFreq; % NE PAS MODIFIER % emetted signal sampling
CP.PRF        = common.constants.SoundSpeed*1e-3/Prof;  % pulse frequency repetition [MHz]

CP.DutyCycle  = 1;               % duty cycle [0, 1]

CP.TrigOut    = Prof*common.constants.SoundSpeed*1e-3;

CP.Repeat     = 1 ;              % a voir

CP.Pause      = min(100e-6-1/CP.PRF*1e-6,system.hardware.MinNoop*1e-6); % pause duration in s

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform

Delay = sqrt(CP.PosZ^2+(CP.TxWidth/2)^2)/(common.constants.SoundSpeed*1e-3) ...
    - 1/(common.constants.SoundSpeed*1e-3)*sqrt(CP.PosZ^2+((0:system.probe.Pitch:CP.TxWidth)-CP.TxWidth/2).^2);

DlySmpl=round(Delay*CP.SampFreq);

T_Wf = 0:1/CP.SampFreq:0.5*CP.NbHcycle/CP.TwFreq;
Wf = sin(2*pi*CP.TwFreq*T_Wf);

N_T = length(Wf) + max(DlySmpl);
WF_mat = zeros(N_T,length(Delay));

for j = 1:size(WF_mat,2)
    WF_mat(DlySmpl(j)+(1:length(Wf)),j) = Wf;
end

WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]

% ======================================================================= %
%% Arbitrary definition of US events

% Elusev
clear ELUSEV

if round((CP.PosX+ScanLength)/system.probe.Pitch)>system.probe.NbElemts
    
    warning('Scan length too long, set to maximum value')
    ScanLength=system.probe.NbElemts*system.probe.Pitch-CP.PosX;
    
end

for nbs = 1:round(ScanLength/system.probe.Pitch)
    
    PosX     = CP.PosX + (nbs-1)*system.probe.Pitch;
    
    EvtDur   = 1/CP.PRF + T_Wf + max(Delay) + CP.Pause*1e6;
    
    MedElmt  = round(PosX/system.probe.Pitch);
    
    TxElemts = MedElmt-round(CP.TxWidth/(2*system.probe.Pitch)):...
        MedElmt+floor(CP.TxWidth/(2*system.probe.Pitch));
    
    WFtmp    = WF_mat_sign( : , ( TxElemts>0 & TxElemts<=system.probe.NbElemts ) );
    
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',nbs);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary( ...
        'Waveform',WFtmp', ...
        'RepeatCH', 0, ...
        'repeat',0 , ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',TxElemts( TxElemts>0 & TxElemts<=system.probe.NbElemts ), ...
        'DutyCycle', CP.DutyCycle, ...
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
    'TrigOut',      CP.TrigOut,...
    'TrigIn',       0,...
    'TrigAll',      0, ...
    'TrigOutDelay', 0, ...
    0);

%ACMO
ACMO = acmo.acmo( ...
    'elusev', ELUSEV, ...
    'Ordering', 0, ...
    'Repeat' ,CP.Repeat, ...
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
    'Repeat', NbRun, ...
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