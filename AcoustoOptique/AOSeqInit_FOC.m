function varargout = AOSeqInit_FOC(A0)
% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc)
% INITIALIZATION of the US Sequence

% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
%
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

 addpath('..\legHAL')
 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 
% status :
 display('Initializing sequence parameters')
 
 


% parameter input :
    Volt            = A0.Volt(A0.val);
    FreqSonde       = A0.FreqSonde(A0.val);
    NbHemicycle     = A0.NbHemicycle(A0.val);
    X0              = A0.X0(A0.val);
    Foc             = A0.Foc ;
    ScanLength      = A0.ScanLength(A0.val);
    NTrig           = A0.NTrig(A0.val);
    Prof            = A0.Prof(A0.val);

NoOp       = 500;             % µs minimum time between two US pulses

%% Probe parameters
CP.ImgVoltage = Volt;             % imaging voltage [V]
CP.ImgCurrent = 1;                % security limit for imaging current [A]
% ======================================================================= %
CP.TwFreq     = FreqSonde;       % MHz
CP.NbHcycle   = NbHemicycle;     %
CP.PosX       = X0;              % mm
CP.PosZ       = Foc;             % mm
CP.TxWidth    = Foc/2;           % mm
CP.Prof       = Prof;            % mm
CP.ScanLength = ScanLength;      % mm

c = 1540 ;% common.constants.SoundSpeed ; % unit ??

CP.SampFreq   = 10;%system.hardware.ClockFreq ; % NE PAS MODIFIER % emitted signal sampling
CP.PRF        = common.constants.SoundSpeed*1e-3/CP.Prof ;  % pulse frequency repetition [MHz]

CP.FIRBandwidth = 90;            % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
CP.DutyCycle  = 1;               % duty cycle [0, 1]

CP.TrigOut    = 10; %ceil(CP.Prof/(common.constants.SoundSpeed*1e-3));  %µs ??
CP.Repeat     = NTrig ;              % a voir
CP.NoOp       = NoOp ;             % µs minimum time between two US pulses
CP.Pause      = max(CP.NoOp-ceil(1/CP.PRF),system.hardware.MinNoop); % pause duration in µs
CP.RxFreq     = 60;              % Receiving center frequency MHz , ??

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform

%actuator pitch :
pitch = system.probe.Pitch 
dt_s = 1/(CP.SampFreq); % unit ??

Delay = sqrt(CP.PosZ^2+(CP.TxWidth/2)^2)/(c*1e-3) ...
        - 1/(c*1e-3)*sqrt(CP.PosZ^2+((0:pitch:CP.TxWidth)-CP.TxWidth/2).^2);
      
%  figure;
%  plot(Delay,'r')

% number of steps offset dt_s for each actuators position : 
 DlySmpl = round(Delay/dt_s); 

 % common waveform for emission:
 T_Wf = 0:dt_s:0.5*CP.NbHcycle/CP.TwFreq;
 Wf = sin(2*pi*CP.TwFreq*T_Wf); 
 
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

figure(470)
imagesc((0:pitch:CP.TxWidth)-CP.TxWidth/2,1:N_T, WF_mat)
grid on
title('input waveform')
xlabel('position x')
ylabel('offset num ??')

% ======================================================================= %
%% Arbitrary definition of US events
% 
% % Elusev
 clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ
% 
 FC = remote.fc('Bandwidth', CP.FIRBandwidth , 0);
 RX = remote.rx('fcId', 1, 'RxFreq', CP.RxFreq, 'QFilter', 2, 'RxElemts', 0, 0);

    if round((CP.PosX+CP.ScanLength)/system.probe.Pitch)>system.probe.NbElemts

        warning('Scan length too long, set to maximum value')
        CP.ScanLength=system.probe.NbElemts*system.probe.Pitch-CP.PosX;

    end

for nbs = 1:round(CP.ScanLength/system.probe.Pitch)
    
    PosX     = CP.PosX + (nbs-1)*system.probe.Pitch; % center position for the line
    EvtDur   = ceil(0.5*CP.NbHcycle/CP.TwFreq + max(Delay) + 1/CP.PRF);

    MedElmt  = round(PosX/system.probe.Pitch);
    
    TxElemts = MedElmt-round(CP.TxWidth/(2*system.probe.Pitch)):...
        MedElmt+floor(CP.TxWidth/(2*system.probe.Pitch));
    
    WFtmp    = WF_mat_sign( : , ( TxElemts>0 & TxElemts<=system.probe.NbElemts ) );
    
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
        'TxElemts',TxElemts( TxElemts>0 & TxElemts<=system.probe.NbElemts ), ...
        'DutyCycle', CP.DutyCycle, ...
        0);
    
    
    % Event
    EVENTList{nbs} = remote.event( ...
        'txId', nbs, ...
        'rxId', 1, ...
        'noop', CP.Pause, ...
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
    'TrigOut',      CP.TrigOut, ... 0,...
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
    'imgVoltage', CP.ImgVoltage, ...
    'imgCurrent', CP.ImgCurrent, ...
    0);
% 
% % USSE for the sequence
SEQ = usse.usse( ...
    'TPC', TPC, ...
    'acmo', ACMOList, ...    'Loopidx',1, ...
    'Repeat', CP.Repeat+1, ...    'Popup',0, ...
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
 display('Remote OK')

 % status :
 display('Loading sequence to Hardware')
 %SEQ = SEQ.loadSequence();
 display('Load OK')
 
 
% % Set output variables
% 
% to be erased :


  varargout{1}   = SEQ;  % loaded sequence 
  varargout{2}   = CP;   % Structure containing the Parameters

  
% % ======================================================================= %
% %% Save the Sequence
% % ======================================================================= %

SEQfilename=['D:\Codes Matlab\AcoustoOptique\SEQdir\SEQ' ...
    '_Foc_'    num2str(CP.PosZ) ...
    '_Volt_'   num2str(CP.ImgVoltage) ...
    '_Freq_'   num2str(CP.TwFreq) ...
    '_NbHem_'  num2str(CP.NbHcycle) ...
    '_X0_'     num2str(fix(CP.PosX)) 'p' num2str(round(abs(CP.PosX-fix(CP.PosX))*100)) ...
    '_Length_' num2str(fix(CP.ScanLength)) 'p' num2str(round(abs(CP.ScanLength-fix(CP.ScanLength))*100)) ...
    '_Prof_'   num2str(fix(CP.Prof)) 'p' num2str(round(abs(CP.Prof-fix(CP.Prof))*100)) ...
    '_NTrig_'  num2str(CP.Repeat) ...
    '_NoOp_'   num2str(CP.NoOp) ...
    '.mat'];


if ~exist(SEQfilename,'file');
    save(SEQfilename,'CP', 'SEQ')
    display('Sequence saved')
end

disp('-------------Ready to use-------------------- ')