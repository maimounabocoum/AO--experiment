% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence
% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

 clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ
 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device


%% parameter for plane wave sequence :
% ======================================================================= %
        Volt        = 20;
        f0          = 6;
        NbHemicycle = 2;
        AlphaM      = 20;
        dA          = 1;
        X0          = 0;
        ScanLength  = 38.5;
        NTrig       = 1;
        Prof        = 40;
    
% creation of vector for scan:       
if dA > 0
    AlphaM = sort(-abs(AlphaM):dA:abs(AlphaM));   % Planes waves angles (deg) 
end

%% System parameters import :
% ======================================================================= %
c           = common.constants.SoundSpeed ; %[m/s]
SampFreq    = system.hardware.ClockFreq; %NE PAS MODIFIER % emitted signal sampling = 180 in [MHz]
NbElemts    = system.probe.NbElemts ; 
pitch       = system.probe.Pitch ; % in mm
MinNoop     = system.hardware.MinNoop;

NoOp       = 500;             % µs minimum time between two US pulses

% ======================================================================= %

PropagationTime        = Prof/c*1e3 ;  % 1 / pulse frequency repetition [us]
TrigOut                = ceil(Prof/(c*1e-3));  %µs
Repeat                 = NTrig ;              % a voir
Pause                  = max( NoOp-ceil(PropagationTime) , MinNoop ); % pause duration in µs

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
dt_s          = 1/(SampFreq);  % unit us
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us


% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
if ScanLength==0 || round(ScanLength/pitch)>=NbElemts    
    Nbtot = NbElemts;
else  
    Nbtot = round(ScanLength/pitch);    
end

Delay = zeros(Nbtot,length(AlphaM)); %(µs)

for i = 1:length(AlphaM)
    
    Delay(:,i) = sin(pi/180*AlphaM(i))*...
        (1:size(Delay,1))*pitch/(c/1000);
    
    Delay(:,i) = Delay(:,i) - min(Delay(:,i));
    
end

for i = 1:length(AlphaM)
    
    Delay(:,i) = Delay(:,i) + max(max(Delay(:,:)))-max(Delay(:,i));
    
end


DlySmpl = round(Delay/dt_s);

T_Wf = 0:dt_s:pulseDuration;
Wf = sin(2*pi*f0*T_Wf);

N_T = length(Wf) + max(max(DlySmpl));
WF_mat = zeros(N_T,size(Delay,1),size(Delay,2));

for kk = 1:length(AlphaM)
    for j = 1:size(Delay,1)
        WF_mat( DlySmpl(j,kk) + (1:length(Wf)),j,kk) = Wf;
    end
end

WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]


% ======================================================================= %
%% Arbitrary definition of US events
FC = remote.fc('Bandwidth', 90 , 0); %FIR receiving bandwidth [%] - center frequency = f0 : 90
RX = remote.rx('fcId', 1, 'RxFreq', 60 , 'QFilter', 2, 'RxElemts', 0, 0);



FirstElmt  = max( round(X0/pitch),1);

for nbs = 1:length(AlphaM)
    
    EvtDur   = ceil(pulseDuration + max(max(Delay)) + PropagationTime);   

    WFtmp    = squeeze( WF_mat_sign( :, :, nbs ) );
       
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
        'DutyCycle', 1, ...
        0);
    
    
    % Event
    EVENTList{nbs} = remote.event( ...
        'txId', 1, ...
        'rxId', 1, ...
        'noop', Pause, ...
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
    'TrigOut',      TrigOut, ... 0,...
    'TrigIn',       0,...
    'TrigAll',      1, ...
    'TrigOutDelay', 0, ...
    0);

    
end

% ======================================================================= %
%% ELUSEV and ACMO definition

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
    'imgVoltage', Volt, ...
    'imgCurrent', 1, ...    % security limit for imaging current [A]
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', Repeat+1, ...  'Popup',0, ...
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

% Load sequequence :
SEQ = SEQ.loadSequence();



