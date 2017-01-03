function varargout=AOSeqInit_OP(varargin)
% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence

% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
%
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

display('Building sequence')

% System parameters (parametres ajustables)
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

if ~isstruct(varargin{1})
    if nargin<8
        errordlg(sprintf(['Not enough parameters to build a sequence :\n\n' ...
            'varagout=AOSeqInit_FOC(Volt,FreqSonde,NbHemicycle,AlphaM,dA,NTrig,Prof)']))
        return
        
    else
        Volt        = varargin{1};
        FreqSonde   = varargin{2};
        NbHemicycle = varargin{3};
        AlphaM      = varargin{4};
        dA          = varargin{5};
        NTrig       = varargin{6};
        Prof        = varargin{7};
    end
else
    Volt            = varargin{1}.Volt;
    FreqSonde       = varargin{1}.FreqSonde;
    NbHemicycle     = varargin{1}.NbHemicycle;
    AlphaM          = varargin{1}.AlphaM ;
    dA              = varargin{1}.dA;
    NTrig           = varargin{1}.NTrig;
    Prof            = varargin{1}.Prof;
end

NoOp       = 100;             % µs minimum time between two US pulses

%% Probe parameters

UF.ImgVoltage = Volt;             % imaging voltage [V]
UF.ImgCurrent = 1;                % security limit for imaging current [A]

% ======================================================================= %

UF.TwFreq     = FreqSonde;       % MHz
UF.NbHcycle   = NbHemicycle;     %
UF.FlatAngles = -AlphaM:dA:AlphaM;   % Planes waves angles (deg)
UF.Prof       = Prof;            % mm

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
WF_mat = zeros(N_T,length(Delay));

for kk = 1:length(UF.FlatAngles)
    for j = 1:system.probe.NbElemts
        WF_mat( DlySmpl(j,kk) + (1:length(Wf)),j,kk) = Wf;
    end
end

WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]

figure(470)
imagesc(WF_mat_sign)

% ======================================================================= %
%% Arbitrary definition of US events

% Elusev
clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ

FC = remote.fc('Bandwidth', UF.FIRBandwidth , 0);
RX = remote.rx('fcId', 1, 'RxFreq', UF.RxFreq, 'QFilter', 2, 'RxElemts', 0, 0);

for nbs = 1:length(UF.FlatAngles)
    
    EvtDur   = ceil(0.5*UF.NbHcycle/UF.TwFreq + max(Delay) + 1/UF.PRF);

    WFtmp    = squeeze( WF_mat_sign( :, :, nbs ) );
    
    %     figure(471)
    %     imagesc(WFtmp)
    %     drawnow
    
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',nbs,'Delays',0);
    
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
        'rxId', 1, ...
        'noop', UF.Pause, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ...
        0);
    
end

% ======================================================================= %
%% ELUSEV and ACMO definition

%ELUSEV
ELUSEV = elusev.elusev( ...
    'tx',           TXList, ...
    'tw',           TWList, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList, ...
    'TrigOut',      UF.TrigOut, ... 0,...
    'TrigIn',       0,...
    'TrigAll',      1, ...
    'TrigOutDelay', 0, ...
    0);

%ACMO
ACMO = acmo.acmo( ...
    'elusev',           ELUSEV, ...
    'Ordering',         1, ...
    'Repeat' ,          1, ...
    'NbHostBuffer',     1, ...
    'NbLocalBuffer',    1, ...
    'ControlPts',       900, ... [900 900],...
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

%% Save SEQ file
SEQfilename=['D:\AcoustoOptique\SEQdir\SEQ' ...
    '_OP_'    num2str(fix(AlphaM)) 'p' num2str(abs(AlphaM-fix(AlphaM))) ...
    '_Volt_'   num2str(Volt) ...
    '_Freq_'   num2str(FreqSonde) ...
    '_NbHem_'  num2str(NbHemicycle) ...
    '_dA_'     num2str(fix(dA)) 'p' num2str(abs(dA-fix(dA))) ...
    '_Prof_'   num2str(fix(Prof)) 'p' num2str(abs(Prof-fix(Prof))) ...
    '_NTrig_'  num2str(NTrig) ...
    '_NoOp_'   num2str(NoOp) ...
    '.mat'];


if exist(SEQfilename,'file');
    save(SEQfilename,'UF', 'SEQ')
end

%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
display('Remote OK')


% Load sequ
SEQ = SEQ.loadSequence();
display('Load OK')

% SEQ = SEQ.quitRemote();

% Set output variables
% varargout{1}   = ELUSEV;
% varargout{2}   = ACMO;
% varargout{3}   = TPC;
varargout{1}   = SEQ;

disp('-------------Sequence loaded, ready to use-------------------- ')