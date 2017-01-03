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
        X0          = varargin{6};
        ScanLength  = varargin{7};
        NTrig       = varargin{8};
        Prof        = varargin{9};
    end
else
    Volt            = varargin{1}.Volt(varargin{1}.val);
    FreqSonde       = varargin{1}.FreqSonde(varargin{1}.val);
    NbHemicycle     = varargin{1}.NbHemicycle(varargin{1}.val);
    AlphaM          = varargin{1}.AlphaM(varargin{1}.val) ;
    dA              = varargin{1}.dA(varargin{1}.val);
    X0              = varargin{1}.X0(varargin{1}.val);
    ScanLength      = varargin{1}.ScanLength(varargin{1}.val);
    NTrig           = varargin{1}.NTrig(varargin{1}.val);
    Prof            = varargin{1}.Prof(varargin{1}.val);
end

NoOp       = 500;             % µs minimum time between two US pulses

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
        'repeat',0 , ...
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
    'Ordering',         0, ...
    'Repeat' ,          1, ...
    'NbHostBuffer',     1, ...
    'NbLocalBuffer',    1, ...
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
varargout{2}   = UF;

%% Save SEQ file
SEQfilename=['D:\Codes Matlab\AcoustoOptique\SEQdir\SEQ' ...
    '_OP_'    num2str(fix(UF.AlphaM)) 'p' num2str(round(abs(UF.AlphaM-fix(UF.AlphaM))*100)) ...
    '_Volt_'   num2str(UF.ImgVoltage) ...
    '_Freq_'   num2str(UF.TwFreq) ...
    '_NbHem_'  num2str(UF.NbHcycle) ...
    '_dA_'     num2str(fix(UF.dA)) 'p' num2str(round(abs(UF.dA-fix(UF.dA))*100)) ...
    '_X0_'     num2str(fix(UF.PosX)) 'p' num2str(round(abs(UF.PosX-fix(UF.PosX))*100)) ...
    '_Length_' num2str(fix(UF.ScanLength)) 'p' num2str(round(abs(UF.ScanLength-fix(UF.ScanLength))*100)) ...
    '_Prof_'   num2str(fix(UF.Prof )) 'p' num2str(round(abs(Prof-fix(UF.Prof ))*100)) ...
    '_NTrig_'  num2str(UF.Repeat) ...
    '_NoOp_'   num2str(UF.NoOp) ...
    '.mat'];


if ~exist(SEQfilename,'file');
    save(SEQfilename,'UF', 'SEQ')
    display('Sequence saved')
end

disp('-------------Sequence loaded, ready to use-------------------- ')