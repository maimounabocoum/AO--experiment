function varargout=AOSeqInit_FOCv2(varargin)
% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc)
% INITIALISATION DE LA SEQUENCE D'ACQUISITION PAR BLOCS

display('Building sequence')

addpath('C:\legHAL')
addPathLegHAL;

% System parameters (parametres ajustables)
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

if ~isstruct(varargin{1})
    if nargin<8
        errordlg(sprintf(['Not eough parameters to build a sequence :\n\n' ...
            'varagout=AOSeqInit_FOC(Volt,FreqSonde,NbHemicycle,X0,Foc,ScanLength,NTrig,Prof)']))
        return
        
    else
        Volt        = varargin{1};
        FreqSonde   = varargin{2};
        NbHemicycle = varargin{3};
        X0          = varargin{4};
        Foc         = varargin{5};
        ScanLength  = varargin{6};
        NTrig       = varargin{7};
        Prof        = varargin{8};
    end
else
    Volt        = varargin{1}.Volt;
    FreqSonde   = varargin{1}.FreqSonde;
    NbHemicycle = varargin{1}.NbHemicycle;
    X0          = varargin{1}.X0;
    Foc         = varargin{1}.Foc;
    ScanLength  = varargin{1}.ScanLength;
    NTrig       = varargin{1}.NTrig;
    Prof        = varargin{1}.Prof;
end

% %Param US
% Foc = 20;%CP.Profondeur de focalisation des US en mm; on définit D pour que f/D=1;
% Volt = 50; %tension à envoyer dans la sonde en V (attention a la limite max)
% FreqSonde = 6; %frequence de la sonde en MHz
% NbHemicycle=8; %Nombre d'hémicycles a pulser
% 
% %Pour le scan 2D
% X0 = 7; %position de départ du scan en X, mm
% CP.ScanLength = 40; %longueur à explorer, mm
% CP.Prof=40; %CP.Profondeur à explorer dans la direction des US
%% Probe parameters

CP.ImgVoltage = Volt;             % imaging voltage [V]
CP.ImgCurrent = 0.1;            % security limit for imaging current [A]

% ======================================================================= %

CP.TwFreq     = FreqSonde;       % MHz
CP.NbHcycle   = NbHemicycle;     %
CP.PosX       = X0;              % mm
CP.PosZ       = Foc;             % mm
CP.TxWidth    = Foc/2;           % mm
CP.Prof       = Prof;            % mm
CP.ScanLength = ScanLength;      % mm

CP.SampFreq   = system.hardware.ClockFreq; % NE PAS MODIFIER % emitted signal sampling
CP.PRF        = common.constants.SoundSpeed*1e-3/CP.Prof;  % pulse frequency repetition [MHz]

CP.DutyCycle  = 1;               % duty cycle [0, 1]

CP.TrigOut    = CP.Prof*common.constants.SoundSpeed*1e-3;

CP.Repeat     = NTrig ;              % a voir

CP.Pause      = max(100,1/CP.PRF); % pause duration in µs
CP.RxFreq     = 60;

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
%% ELUSEV

% Elusev
clear ELUSEV

if round((CP.PosX+CP.ScanLength)/system.probe.Pitch)>system.probe.NbElemts
    
    warning('Scan length too long, set to maximum value')
    CP.ScanLength=system.probe.NbElemts*system.probe.Pitch-CP.PosX;
    
end

for nbs = 1:round(CP.ScanLength/system.probe.Pitch)
    
    FOCUSED{nbs} = elusev.focused( ...
            'TwFreq',       CP.TwFreq, ...
            'NbHcycle',     CP.NbHcycle, ...
            'Polarity',     1, ...
            'SteerAngle',   0, ...
            'Focus',        CP.PosZ, ...    %en mm
            'Pause',        CP.Pause, ...       %en  µs
            'PauseEnd',     system.hardware.MinNoop, ...       %en µs
            'DutyCycle',    CP.DutyCycle, ...
            'TxCenter',     CP.PosX + (nbs-1)*system.probe.Pitch, ...
            'TxWidth',      CP.TxWidth, ...
            'RxFreq',       CP.RxFreq, ...
            'RxCenter',     CP.PosX + (nbs-1)*system.probe.Pitch, ...
            'RxDuration',   8.5333, ...
            'RxDelay',      0, ...
            'RxBandwidth',  2, ...
            'FIRBandwidth', 0, ...
            'PulseInv',     0, ...
            'TrigOut',      CP.TrigOut , ...    %en µs
            'TrigAll',      1, ...
            'Repeat',       1, ...
            'ApodFct',      'none', ...
            0);
        
        %ACMO
        ACMO{nbs} = acmo.acmo( ...
            'elusev',           FOCUSED{nbs}, ...
            'Ordering',         0, ...
            'Repeat' ,          1, ...
            'NbHostBuffer',     1, ...
            'NbLocalBuffer',    1, ...
            0);
        
end

% ======================================================================= %
%% Build sequence

% Probe Param
TPC = remote.tpc( ...
    'imgVoltage', CP.ImgVoltage, ...
    'imgCurrent', CP.ImgCurrent, ...
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMO, ...
    'Ordering', 0, ...
    'Repeat', CP.Repeat+1, ...
    'Loop', 0, ...
    'DropFrames', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();

%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);

% Load sequ
SEQ = SEQ.loadSequence();

filename=['C:\AcoustoOptique\SEQdir\SEQfoc_' ...
    datestr(now,'yyyy-mm-dd') '_' ...
    datestr(now,'hhMMss') '.mat'];

save(filename,'CP')

varargout{1}   = ELUSEV;
varargout{2}   = ACMO;
varargout{3}   = TPC;
varargout{4}   = SEQ;

disp('-------------Sequence loaded, ready to use-------------------- ')