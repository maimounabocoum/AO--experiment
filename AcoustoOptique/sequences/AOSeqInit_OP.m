% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence
% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead
function [SEQ,Delay,MedElmtList,ActiveLIST,AlphaM] = AOSeqInit_OP(AixplorerIP, Volt , f0 , NbHemicycle , AlphaM , X0 , X1 ,Prof, NTrig,Master)
 clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ


 
% user defined parameters :

    ScanLength      = X1 - X0; % mm

%% System parameters import :
% ======================================================================= %
c           = common.constants.SoundSpeed ; % [m/s]
SampFreq    = system.hardware.ClockFreq;   % NE PAS MODIFIER % emitted signal sampling = 180 in [MHz]
NbElemts    = system.probe.NbElemts ; 
pitch       = system.probe.Pitch ;          % in mm
MinNoop     = system.hardware.MinNoop;

NoOp       = 1000;             % µs minimum time between two US pulses

% ======================================================================= %

PropagationTime        = Prof/c*1e3 ;   % 1 / pulse frequency repetition [us]
TrigOut                = 30;            % µs
Pause                  = max( NoOp - ceil(PropagationTime) , MinNoop ); % pause duration in µs

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
dt_s          = 1/(SampFreq);  % unit us
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us




% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
% shooting elements 
ElmtBorns   = [min(NbElemts,max(1,round(X0/pitch))),max(1,min(NbElemts,round(X1/pitch)))];
ElmtBorns   = sort(ElmtBorns) ; % in case X0 and X1 are mixed up


Nbtot = ElmtBorns(2) - ElmtBorns(1) + 1 ;


Delay = zeros(NbElemts,length(AlphaM)); %(µs)


for i = 1:length(AlphaM)
      
    Delay(:,i) = 1000*(1/c)*sin(AlphaM(i))*(1:NbElemts)'*(pitch); %s
    Delay(:,i) = Delay(:,i) - min(Delay(:,i));
    
end
%  
% for i = 1:length(AlphaM)
%     % setting absolute maximum delay for as reference for 0 angle ..?
%     Delay(:,i) = Delay(:,i) - max(Delay(:,i)); 
%     Delay(:,i) = Delay(:,i) + max(Delay(:));
%     
% end


% waveform
T_Wf = 0:dt_s:pulseDuration;
Wf = sin(2*pi*f0*T_Wf);
N_T = length(Wf) ;
    
WF_mat      = repmat(Wf,Nbtot,1);
WF_mat_sign =  sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]


% ======================================================================= %
%% Arbitrary definition of US events
FC = remote.fc('Bandwidth', 90 , 0); %FIR receiving bandwidth [%] - center frequency = f0 : 90
RX = remote.rx('fcId', 1, 'RxFreq', 60 , 'QFilter', 2, 'RxElemts', 0, 0);



MedElmtList = 1:length(AlphaM); % list of shot ordering for angle scan (used to reconstruct image)
% define boolean matrix with the index of active actuators :
ActiveLIST = false(NbElemts,length(AlphaM));
ActiveLIST(ElmtBorns(1):ElmtBorns(2),:) = true ;

for nbs = 1:length(AlphaM)
    
    EvtDur   = ceil(pulseDuration + max(max(Delay)) + PropagationTime);   
       
    % Flat TX, other parameters : 
    % 'tof2Focus': time of flight to focal point from the time origin of transmit [us]
    % 'TxElemts' : 'id of the TX channels' [1 system.probe.NbElemts]
    % % Delays for each tx elements
    
    
    TXList{nbs} = remote.tx_arbitrary(...
               'txClock180MHz', 1 ,...   % sampling rate = { 0 ,1 } = > {'90 MHz', '180 MHz'}
               'twId',1,...              % {0 [1 Inf]} = {'no waveform', 'id of the waveform'},
               'Delays',Delay(:,nbs),...
               0);                      
    
    % Arbitrary TW

    TWList{nbs} = remote.tw_arbitrary( ...
        'Waveform',WF_mat_sign, ...
        'RepeatCH', 0, ...
        'repeat',1 , ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',ElmtBorns(1):ElmtBorns(2), ...
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
        switch Master
        case 'on'
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
            case 'off'

ELUSEV{nbs} = elusev.elusev( ...
    'tx',           TXList{nbs}, ...
    'tw',           TWList{nbs}, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList{nbs}, ...
    'TrigOut',      0, ... 0,...
    'TrigIn',       1,...
    'TrigAll',      1, ...
    'TrigOutDelay', 0, ...
    0);
        end
end

% ======================================================================= %
%% ELUSEV and ACMO definition
% duration : sets the TGC duration [us] [0 inf] (default = 0)
% fastTGC : enables the fast TGC mode [0 1] (default = 0)
% Mode ('NbHostBuffer' = 2 , 'ModeRx' = 0)
% TGC ('Duration'= 0, 'ControlPts' = 900, 'fastTGC' = 0)
% DMA ('localBuffer'=0)

ACMO = acmo.acmo( ...
    'elusev',           ELUSEV, ...
    'Ordering',         0, ...   % 'sets the ELUSEV execution order', {0 [1 Inf]} {'chronological ordering', 'customed ordering'}
    'Repeat' ,          1, ...   % ACMO repetition [1 Inf]
    'NbHostBuffer',     1, ...   % (default = 1) , [1 common.legHAL.RemoteMaxNbHostBuffers]
    'NbLocalBuffer',    1, ...   % sets the number of host buffers {0 [1 20]} , (default = 0 : automatic)
    'ControlPts',       900, ... % sets the value of TGC control points [0 960], default = 900
    'RepeatElusev',     1, ...   % sets the number of times all ELUSEV are repeated before data transfer [1 Inf] (default = 1)
    0);

ACMOList{1} = ACMO;

% ======================================================================= %
%% Build sequence

% Probe Param
% pushVoltage : sets maximum push voltage (8 80]
% pushCurrent : sets maximum push current [0 20]
TPC = remote.tpc( ...
    'imgVoltage', Volt, ... % sets maximum imaging voltage [8 80]
    'imgCurrent', 1, ...    % security limit for imaging current [0 2] [A]
    0);

% USSE for the sequence
% Ordering : ACMO execution order during the USSE {0 [1 Inf]}
SEQ = usse.usse( ...
    'USSE', 'Plane Wave waveforms',...% first argument is the name of the object
    'TPC', TPC, ... 
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', NTrig+1, ...  % sets the repetition number of USSE  [1 Inf].
    'DropFrames', 0, ...    % enables error message if acquisition were dropped : {0,1}
    'Loop', 0, ...          % 0 : sequence executed once, 1 : sequence looped
    'DataFormat', 'FF', ... % format output data : {'RF' 'BF' 'FF'}
    'Popup', 0, ...         % enables the popups to control the sequence execution : {0,1}
    0);                     % debugg parameter

[SEQ NbAcq] = SEQ.buildRemote();
 display('Build OK')
 
%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems
 SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
 %SEQ.Server
 %SEQ.InfoStruct.event
 
% remoteGetUserSequence(SEQ.Server)
% remoteGetStatus(SEQ.Server)

% convert Delay matrix to us -> s
Delay = Delay*1e-6;

 
 display('Remote OK');

 % status :
 display('Loading sequence to Hardware');
 SEQ = SEQ.loadSequence();
 disp('-------------Ready to use-------------------- ')
 

end



