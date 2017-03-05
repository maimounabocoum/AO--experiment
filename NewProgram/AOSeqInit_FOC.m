% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc) modified by
% Maïmouna Bocoum 26 - 02 -2017
 clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ

 AixplorerIP    = '192.168.0.20'; % IP address of the Aixplorer device
 
 % get loaded sequence :
 %srv = remoteDefineServer('extern',AixplorerIP, 9999);
 %SEQ = remoteGetUserSequence(srv)
 
 
 %srv = remoteDefineServer('extern', '192.168.1.125', 9999)
% status :
 display('Initializing remote control')


% user defined parameters :
    Volt            = 10; % Volts
    f0              = 6;  % MHz
    NbHemicycle     = 8;  % number of have cycles
    X0              = 0;  % mm : position of min actuator for the scan
    Foc             = 35; % mm
    ScanLength      = 30; % mm
    NTrig           = 10; % number of repetition
    Prof            = 70; % mm


%% System parameters import :
% ======================================================================= %
c =           common.constants.SoundSpeed ; %[m/s]
SampFreq   =  system.hardware.ClockFreq; %NE PAS MODIFIER % emitted signal sampling = 180 in [MHz]
NbElemts =    system.probe.NbElemts ; 
pitch =       system.probe.Pitch ; % in mm
MinNoop =     system.hardware.MinNoop ;

%% Focusing parameters
% ======================================================================= %
TxWidth       = Foc/2;           % mm : effective width for focus line
PropagationTime = (Prof)/(c)*1e3 ; % duration for one line in \mu s


NoOp       = 1000;             % µs minimum time between two US pulses, (5 by default ??)
FIRBandwidth = 90;            % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
RxFreq    = 6;                % Receiving center frequency MHz , ??

TrigOut    = ceil(PropagationTime);  % µs
Pause      = max( NoOp - ceil(PropagationTime) , MinNoop ); % pause duration in µs

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
dt_s = 1/(SampFreq);      % unit us
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us


%% Delay Law [us]
% ======================================================================= %
% c[m/s] -> [mm/us] ; eg factor 1e-3 in the above expression
Delay = sqrt(Foc^2+(TxWidth/2)^2)/(c*1e-3) ...
        - 1/(c*1e-3)*sqrt(Foc^2+((0:pitch:TxWidth)-TxWidth/2).^2);
     
%   figure;
%   plot(Delay,'r')
%   xlabel('actuator')
%   ylabel('delays (\mu s)')

% number of steps offset dt_s for each actuators position : 
 DlySmpl = round(Delay/dt_s); 

 % common waveform for emission, square envoppe - non apodized:
 T_Wf = 0:dt_s:0.5*NbHemicycle/f0;
 Wf = sin(2*pi*f0*T_Wf); 
 
 % number of time-points necessary = points in waveform + maximum delay
 % offset
 N_T = length(Wf) + max(DlySmpl); 

%%% construction of a delay matrix : one column / actuator
 WF_mat = zeros(N_T,length(Delay));

 for j = 1:length(Delay)
     % offset for each actuator + normal waveform init
     WF_mat(DlySmpl(j)+(1:length(Wf)),j) = Wf;
 end
 
 WF_mat_sign = sign(WF_mat); % l'aixplorer code sur 3 niveaux [-1,0,1]

figure(470);
imagesc((0:pitch:TxWidth)-TxWidth/2,1:N_T, WF_mat);
grid on
title('input waveform');
xlabel('position x');
ylabel('offset num ??');

% ======================================================================= %
%% Arbitrary definition of US events
% 
% % Elusev

% 
 FC = remote.fc('Bandwidth', FIRBandwidth , 0);
 RX = remote.rx('fcId', 1, 'RxFreq', RxFreq, 'QFilter', 2, 'RxElemts', 0, 0);

    if round((X0+ScanLength)/pitch) > NbElemts
        warning('Scan length too long, set to maximum value');
        ScanLength = NbElemts*pitch-X0;

    end

for Nloop = 1:round(ScanLength/pitch)
    
    PosX     = X0 + (Nloop-1)*pitch; % center position for the line in mm
    % EvDur = exciting pulse duration + law law + scan line duration
    % PropagationTime , in \mu s
    EvtDur   = ceil( pulseDuration + max(Delay) + PropagationTime );

    MedElmt  = round(PosX/pitch);
    
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
    EVENTList{Nloop} = remote.event( ...
        'txId', Nloop, ...
        'rxId', 1, ...
        'noop', Pause, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ...
        0);
    
end

% % ======================================================================= %
% %% ELUSEV and ACMO definition
% % ======================================================================= %

ELUSEV = elusev.elusev( ...
    'tx',           TXList, ...
    'tw',           TWList, ...
    'rx',           RX,...
    'fc',           FC,...
    'event',        EVENTList, ...
    'TrigOut',      TrigOut, ... 0,...
    'TrigIn',       0,...% trigged sequence 
    'TrigAll',      1, ...% 0: sends output trigger at first emission 
    'TrigOutDelay', 0, ...
    0);

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
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', NTrig, ...    'Popup',0, ...
    'DropFrames', 0, ...
    'Loop', 0, ...
    'DataFormat', 'FF', ...
    'Popup', 0, ...
    0);

 display('Building sequence to controllor')
 
 [SEQ NbAcq] = SEQ.buildRemote();

 display('Build OK')
 
%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems
 SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
 %SEQ.Server
 %SEQ.InfoStruct.event
 
% remoteGetUserSequence(SEQ.Server)
% remoteGetStatus(SEQ.Server)

 
 display('Remote OK');

 % status :
 display('Loading sequence to Hardware');
 SEQ = SEQ.loadSequence();
 display('Load OK');
  SEQ = SEQ.startSequence();
 
% % Set output variables
% Stop sequence
% SEQ = SEQ.stopSequence( 'Wait', 1 );

%SEQ = SEQ.quitRemote();
disp('-------------Ready to use-------------------- ')