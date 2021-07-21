% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc) modified by
% Maïmouna Bocoum 26 - 02 -2017
%% Init program
function [SEQ,MedElmtList] = AOSeqInit_OF(AixplorerIP, Volt , f0 , NbHemicycle , Foc, PosOFscan, X0 , X1 , Prof ,NTrig,frep ,Master,USemissionDelay)

clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ


 
 % get loaded sequence :
 %srv = remoteDefineServer('extern',AixplorerIP, 9999);
 %SEQ = remoteGetUserSequence(srv)
 
 
 %srv = remoteDefineServer('extern', '192.168.1.125', 9999)
% status :
 display('Initializing remote control')


% user defined parameters :

    ScanLength      = X1 - X0; % mm


%% System parameters import :
% ======================================================================= %
c =           common.constants.SoundSpeed ; %[m/s]
SampFreq   =  system.hardware.ClockFreq; %NE PAS MODIFIER % emitted signal sampling = 180 in [MHz]
NbElemts =    system.probe.NbElemts ; 
pitch =       system.probe.Pitch ; % in mm
MinNoop =     system.hardware.MinNoop ;

%% Focusing parameters
% ======================================================================= %
TxWidth         = Foc/2;           % mm : effective width for focus line
PropagationTime = (Prof)/(c)*1e3 ; % duration for one line in \mu s


NoOp       = 1e6/frep;                      % µs minimum time between two US pulses
TrigOut    = 50;           % trigger duration µs
Pause      = max( NoOp - ceil(PropagationTime) , MinNoop ); % pause duration in µs

% ======================================================================= %
%% Codage en arbitrary : DelayLaw matrix and waveform
dt_s = 1/(SampFreq);      % unit us
pulseDuration = NbHemicycle*(0.5/f0); % US inital pulse duration in us


%% DelayLaw Law [us]
% ======================================================================= %
% c[m/s] -> [mm/us] ; eg factor 1e-3 in the above expression
DelayLaw = sqrt(Foc^2+(TxWidth/2)^2)/(c*1e-3) ...
        - 1/(c*1e-3)*sqrt(Foc^2+((0:pitch:TxWidth)-TxWidth/2).^2);
     
%   figure;
%   plot(DelayLaw,'r')
%   xlabel('actuator')
%   ylabel('DelayLaws (\mu s)')

% number of steps offset dt_s for each actuators position : 
 DlySmpl = round(DelayLaw/dt_s); 

 % common waveform for emission, square envoppe - non apodized:
 t_Wf = 0:dt_s:pulseDuration;
 Wf = sin(2*pi*f0*t_Wf); 
 
 % number of time-points necessary = points in waveform + maximum DelayLaw
 % offset necessary for DelayLaw law
 N_T = length(Wf) + max(DlySmpl); 

%%% construction of a DelayLaw matrix : one column / actuator
 WF_mat = zeros(N_T,length(DelayLaw));

 for j = 1:length(DelayLaw)
     % offset for each actuator + normal waveform init
     WF_mat( DlySmpl(j)+(1:length(Wf)) , j ) = Wf;
 end
 
 WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]

% figure(470);
% imagesc((0:pitch:TxWidth)-TxWidth/2,1:N_T, WF_mat);
% grid on
% title('input waveform');
% xlabel('position x');
% ylabel('offset num ??');

% ======================================================================= %
%% Arbitrary definition of US events

 FC = remote.fc('Bandwidth', 90 , 0);
 % FIRBandwidth : FIR receiving bandwidth [%] - center frequency = UF.TwFreq

 RX = remote.rx('fcId', 1, 'RxFreq', f0 , 'QFilter', 2, 'RxElemts', 0, 0);

    if round((X0+ScanLength)/pitch) > NbElemts
        warning('Scan length too long, set to maximum value');
        ScanLength = NbElemts*pitch-X0;

    end
    
    
% EvDur = exciting pulse duration + law law + scan line duration
% PropagationTime , in \mu s    
EvtDur   = ceil( pulseDuration + max(DelayLaw) + PropagationTime );    
% index of element used for the scan :    


ElmtBorns   = [min(NbElemts,max(1,round(X0/pitch))),max(1,min(NbElemts,round(X1/pitch)))];
ElmtBorns   = sort(ElmtBorns); % in case X0 and X1 are mixed up
MedElmtList = ElmtBorns(1):ElmtBorns(2)  ;
%MedElmtList = randperm(round(ScanLength/pitch)) ;  

% % ======================================================================= %
% %% EVENT INITIALISATION
% % ======================================================================= %

for Nloop = 1:length(PosOFscan)
    
    MedElmt  = round( PosOFscan(Nloop)/pitch ); %round(PosX/pitch);
       
    % actual active element
    TxElemts = MedElmt-round(TxWidth/(2*pitch)):...
               MedElmt+floor(TxWidth/(2*pitch));
    
    WFtmp    = WF_mat_sign( : , ( TxElemts>0 & TxElemts<= NbElemts ) );
    
    %     figure(471)
    %     imagesc(WFtmp)
    %     drawnow
    
    % Flat TX
    TXList{Nloop} = remote.tx_arbitrary('txClock180MHz', 1,'twId',Nloop,'Delays',0);
    
    % Arbitrary TW
    TWList{Nloop} = remote.tw_arbitrary( ...
        'Waveform',WFtmp', ...
        'RepeatCH', 0, ...
        'repeat',0 , ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',TxElemts( TxElemts>0 & TxElemts <= NbElemts ), ...
        'DutyCycle', 1, ... % duty cycle [0, 1]
        0);
    
    
    % Event
        switch Master
        case 'on'
    EVENTList{Nloop} = remote.event( ...
        'txId', Nloop, ...
        'rxId', 1, ...
        'noop', 5, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ...
        0);
            case 'off'
    EVENTList{Nloop} = remote.event( ...
        'txId', Nloop, ...
        'rxId', 1, ...
        'noop', Pause, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ...
        0);
        end
    
end

% % ======================================================================= %
% %% ELUSEV and ACMO definition
% % ======================================================================= %

% adding a pause event as in JB routine : dont know really why but
% necessary !
% ELUSEV{1} = elusev.pause( ...
%     'TrigOut',      0, ...  
%     'TrigIn',       0,...   % trigged sequence 
%     'TrigAll',      0, ...  % 0: sends output trigger at first emission 
%     'TrigOutDelay', 0, ...
%     'Pause',        5e-3,...% pause in seconds
%     0);
    switch Master
        case 'on'
ELUSEV = elusev.elusev( ...
    'tx',           TXList, ...
    'tw',           TWList, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList, ...
    'TrigOut',      TrigOut, ... 0,...
    'TrigIn',       0,... % trigged sequence 
    'TrigAll',      1, ...% 0: sends output trigger at first emission 
    'TrigOutDelay', USemissionDelay, ...
    0);
        case 'off'
ELUSEV = elusev.elusev( ...
    'tx',           TXList, ...
    'tw',           TWList, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList, ...
    'TrigOut',      0, ... 0,...
    'TrigIn',       1,... % trigged sequence 
    'TrigAll',      1, ...% 0: sends output trigger at first emission 
    'TrigOutDelay', USemissionDelay, ...
    0);

    end

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
 
% % ======================================================================= %
% %% Build sequence
% % ======================================================================= %
 
% % Probe Param
TPC = remote.tpc( ...
    'imgVoltage', Volt, ...
    'imgCurrent', 1, ...% security limit for imaging current [A]
    0);
% 
% % USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMOList, ...     'Loopidx',1, ...
    'Repeat', NTrig, ...    'Popup',0, ...
    'DropFrames', 0, ...
    'Loop', 0, ... %    'Loopidx', 2, ...
    'DataFormat', 'FF', ...
    'Popup', 0, ...
    0);

 display('Building sequence to controllor')
 
 [SEQ NbAcq] = SEQ.buildRemote();

 display('Build OK')
 
%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems
 %SEQ.Server
 %SEQ.InfoStruct.event
 
% remoteGetUserSequence(SEQ.Server)
% remoteGetStatus(SEQ.Server)
 %% initialize communation with remote aixplorer and load sequence
try
 SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
 display('============== Remote OK =============');
 display('Loading sequence to Hardware'); tic ;
 SEQ = SEQ.loadSequence();
 fprintf('Sequence has loaded in %f s \n\r',toc)
 display('--------ready to use -------------');
 
catch e
  fprintf(e.message);  
end
 
 
 
end