function varargout=AOSeqInit_STRUCT(varargin)
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
        Nphase      = varargin{6}; %N-phases
        freqx       = varargin{7}; %half period in nb. of el.
        NTrig       = varargin{8};
        Prof        = varargin{9};
    end
else
    Volt            = varargin{1}.Volt(varargin{1}.val);
    FreqSonde       = varargin{1}.FreqSonde(varargin{1}.val);
    NbHemicycle     = varargin{1}.NbHemicycle(varargin{1}.val);
    AlphaM          = varargin{1}.AlphaM(varargin{1}.val) ;
    dA              = varargin{1}.dA(varargin{1}.val);
    Nphase          = varargin{1}.Nphase; %N-phases
    freqx           = varargin{1}.freqx; %half period in nb. of el.
    NTrig           = varargin{1}.NTrig(varargin{1}.val);
    Prof            = varargin{1}.Prof(varargin{1}.val);
end

NoOp       = 500;             % µs minimum time between two US pulses

%% Probe parameters

US.ImgVoltage = Volt;             % imaging voltage [V]
US.ImgCurrent = 1;                % security limit for imaging current [A]

% ======================================================================= %
US.AlphaM     = AlphaM;
US.dA         = dA;

if dA > 0
    US.FlatAngles = sort(-abs(US.AlphaM):US.dA:abs(US.AlphaM));   % Planes waves angles (deg)
    US.freqx      = freqx;%3*Nphase;
else
    US.FlatAngles = US.AlphaM;
    US.freqx      = Nphase:Nphase:system.probe.NbElemts; % vector with the number of elements in a half period
end

US.Nphase     = Nphase;          % N-phase (3 or 4)
US.TwFreq     = FreqSonde;       % MHz
US.NbHcycle   = NbHemicycle;     %
US.Prof       = Prof;            % mm

US.SampFreq   = system.hardware.ClockFreq; % NE PAS MODIFIER % emitted signal sampling
US.PRF        = common.constants.SoundSpeed*1e-3/US.Prof;  % pulse frequency repetition [MHz]
US.FIRBandwidth = 90;            % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
US.DutyCycle  = 1;               % duty cycle [0, 1]

US.TrigOut    = 10; %ceil(CP.Prof/(common.constants.SoundSpeed*1e-3));  %µs

US.Repeat     = NTrig ;              % a voir

US.NoOp       = NoOp ;             % µs minimum time between two US pulses
US.Pause      = max(US.NoOp-ceil(1/US.PRF),system.hardware.MinNoop); % pause duration in µs
US.RxFreq     = 60;              % Receiving center frequency

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform

%Delay law for steering angle

Delay = zeros(system.probe.NbElemts,length(US.FlatAngles)); %(µs)

for i = 1:length(US.FlatAngles)
    
    Delay(:,i) = tan(pi/180*US.FlatAngles(i))*...
        (1:size(Delay,1))*system.probe.Pitch/(common.constants.SoundSpeed/1000);
    
    Delay(:,i) = Delay(:,i) - min(Delay(:,i));
    
end

for i = 1:length(US.FlatAngles)
    
    Delay(:,i) = Delay(:,i) + max(max(Delay(:,:)))-max(Delay(:,i));
    
end

DlySmpl=round(Delay*US.SampFreq);

T_Wf = 0:1/US.SampFreq:0.5*US.NbHcycle/US.TwFreq;
Wf = sin(2*pi*US.TwFreq*T_Wf);

N_T = length(Wf) + max(max(DlySmpl));

WF_mat = zeros(US.Nphase,size(Delay,2),length(US.freqx),N_T,system.probe.NbElemts);

for ii = 1:length(US.FlatAngles)
    for kk = 1:length(US.freqx)
        
        for ll = 1:US.Nphase
            
            for mm = 1:system.probe.NbElemts
                WF_mat(ll,ii,kk, DlySmpl(mm,ii) + (1:length(Wf)) ,mm) =...
                    (1-2*rem(ceil((mm+(ll-1)*US.freqx(kk)/US.Nphase)/US.freqx(kk)),2))*Wf;
                
            end
            
            figure(256+ll)
            % ll : phase
            % ii : angle
            % kk :
            imagesc(squeeze(WF_mat(ll,ii,kk,:,:))) % matrix emission for all elements
            drawnow
            pause(0.1)
            
        end
        
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

FC = remote.fc('Bandwidth', US.FIRBandwidth , 0);
RX = remote.rx('fcId', 1, 'RxFreq', US.RxFreq, 'QFilter', 2, 'RxElemts', 0, 0);

for nt = 1:length(US.FlatAngles)
    for np = 1:US.Nphase
        for nbs = 1:length(US.freqx)
            
            EvtDur   = ceil(0.5*US.NbHcycle/US.TwFreq + max(max(Delay)) + 1/US.PRF);
            
            WFtmp    = squeeze( WF_mat_sign(np, nt, nbs, :, :) );
            %
            %         figure(471)
            %         imagesc(WFtmp)
            %         drawnow
            %
            % Flat TX
            TXList{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs} =...
                remote.tx_arbitrary('txClock180MHz', 1,'twId',1,'Delays',0);
            
            % Arbitrary TW
            TWList{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs} = remote.tw_arbitrary( ...
                'Waveform',WFtmp', ...
                'RepeatCH', 0, ...
                'repeat',0 , ...
                'repeat256', 0, ...
                'ApodFct', 'none', ...
                'TxElemts',1:system.probe.NbElemts, ...
                'DutyCycle', US.DutyCycle, ...
                0);
            
            
            % Event
            EVENTList{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs} = remote.event( ...
                'txId', 1, ...
                'rxId', 1, ...
                'noop', US.Pause, ...
                'numSamples', 128, ...
                'skipSamples', 0, ... 128, ...
                'duration', EvtDur, ...
                0);
            
            %ELUSEV
            ELUSEV{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs} = elusev.elusev( ...
                'tx',           TXList{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs}, ...
                'tw',           TWList{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs}, ...
                'rx',           RX,...
                'fc',           FC,...
                'event',        EVENTList{(nt-1)*length(US.freqx)*US.Nphase+(np-1)*length(US.freqx)+nbs}, ...
                'TrigOut',      US.TrigOut, ... 0,...
                'TrigIn',       0,...
                'TrigAll',      1, ...
                'TrigOutDelay', 0, ...
                0);
            
        end
    end
    
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
    'imgVoltage', US.ImgVoltage, ...
    'imgCurrent', US.ImgCurrent, ...
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', US.Repeat+1, ...    'Popup',0, ...
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
varargout{2}   = US;

%% Save SEQ file
SEQfilename=['D:\AcoustoOptique\SEQdir\SEQ' ...
    '_STR', ...
    '_Volt_'   num2str(US.ImgVoltage) ...
    '_Freq_'   num2str(US.TwFreq) ...
    '_NbHem_'  num2str(US.NbHcycle) ...
    '_Nphase_' num2str(US.Nphase) ...
    '_Prof_'   num2str(fix(US.Prof )) 'p' num2str(round(abs(Prof-fix(US.Prof ))*100)) ...
    '_NTrig_'  num2str(US.Repeat) ...
    '_NoOp_'   num2str(US.NoOp) ...
    '.mat'];


if ~exist(SEQfilename,'file');
    save(SEQfilename,'US', 'SEQ')
    display('Sequence saved')
end

disp('-------------Sequence loaded, ready to use-------------------- ')