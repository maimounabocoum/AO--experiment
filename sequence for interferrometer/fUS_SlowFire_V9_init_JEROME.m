% cette version peut être utilisée avec le beamformer pour GPU 3D des
% machines V9


 clearvars

%  clear all
% Sequence = usse.usse; Sequence = Sequence.selectProbe
%% Parameters definition

test = 0;

if test
    name = 'data_test' ; % nom pour la sauvegarde
    dir_save=['0/home/rubi/WorkFolder/' name '/'];
    UF.NbOfBlocs               = 5; 
else
    name = 'fUS_bebe' ; % nom pour la sauvegarde
    dir_save=['/home/rubi/WorkFolder/' name '/'];
    UF.NbOfBlocs               = 1200; 
end

% System parameters (parametres ajustables)
AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

ImagingVoltage = 50;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A] %%%% NE PAS MODIFIER %%%%%
% ============================================================================ %

% Image parameters (parametres modifiables)
ImgInfo.Depth(1)           = 4;   
ImgInfo.Depth(2)           = 30;   

UF.FlatAngles   = linspace(-5,5,3)  ;% linspace(-10,10,6);% [5] ;%[-6 -6 -4 -4 -2 -2 0 0 2 2 4 4 6 6];%   % 11 angles pour 300 frames/bloc, 17 pour 200 frames/bloc

% ===============================================1.0============================= %

% Ultrafast acquisition parameters

% fondamental (NE PAS MODIFIER)
UF.TxPolarity     = [ 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
UF.TxElemsPattern = [ 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
UF.PulseInversion = length( unique( UF.TxPolarity ) ) - 1 ;

% Parametres ajustables : 
UF.TwFreq       = 6.42;              % emission frequency [MHz]
UF.NbCycle      = 2;               % # of emitted cycles
UF.FlatAngles   = sort(UF.FlatAngles);
UF.DutyCycle    = 1;               % duty cycle [0, 1]
UF.ApodFct      = 'none';          % emission apodization function (none, hanning)
UF.RxBandwidth  = 2;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
UF.FIRBandwidth = 80;              % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
UF.NbFrames     = 370;             % # of acquired images per block. (after compound)
UF.FrameRateUF  = 650;             % final framerate of compounded image
UF.PRF          = UF.FrameRateUF*length(UF.FlatAngles);  % pulse frequency repetition [Hz], between 2 different flats images (0 for greatest possible)
UF.FrameRate    = 0;
UF.RepeatFrequency = 1;          %  1/3 ou 1/4 primate, 1/2 rat, Repetition frequency for blocs acquisition -> time between two blocs acquisitions (Example : 1/2 -> acquire one bloc every 2s)
UF.TGC          = 900 * ones(1,8); % TGC profile
UF.TrigIn       = 0;              %____________ 0 : no trig in / 1 : trig in__________________          
UF.TrigOut      = 700;             % Trig out duration, microsecond. 0 if no trigout is needed /!\ TrigIn and TrigOut BNC port of aixplorer are not well isolated. a ~50ns per 2V parasite spike is sent on TrigOut when a TrigIn is recieved.
UF.TrigAll      = 1 ;
UF.Repeat       = 1 ;               %NE PAS MODIFIER
UF.NbLocalBuffer= 2 ;               %NE PAS MODIFIER   % Buffer sur carte d'acquisition
UF.NbHostBuffer = 16 ;               %NE PAS MODIFIER   % Buffer sur ordinateur (RAM)
UF.Repeat_sequence = UF.NbOfBlocs/UF.Repeat ; % 
UF.PauseDuration = 1*(1/UF.RepeatFrequency - UF.NbFrames/UF.FrameRateUF); % Pause duration after one bloc acquisition for having one acquisition every 2s


UF.SampFreq =system.hardware.ClockFreq; %NE PAS MODIFIER % emetted signal sampling

% Emitting and receiving elts. Must have same length (128)
UF.FiringElts =  1:128;         %[33:160];%[65:128];% 65:192;%
UF.ReceivingElts =  1:128;      %[33:160];65:192;%65:192;%  

% Beamforming mask enabling, if 'on' draw a mask in the _start.m file
CP.MaskOn = 'off'; % 'init' for initialization, 'on' for using a beamforming mask, 'off', if no mask is needed

%Parametres .CP utilises par le beamformer NE PAS MODIFIER
CP.FlatAngles = UF.FlatAngles;
CP.NbFrames = UF.NbFrames;
CP.Depth(1)= ImgInfo.Depth(1) ;
CP.Depth(2)=ImgInfo.Depth(2) ;
CP.RF = 0 ; %0 pour IQ et 1 pour RF
CP.Decalage=UF.FlatAngles.*0; %Different de zero qd on fait du hadamard
CP.FirstChannel = UF.ReceivingElts(1); % premiere voie utilisee par le beamformer (la premiere voie est le numero 1) 
CP.synthAcq  = 0;
CP.Acmo = 0; % 0 si code en arbitrary, 1 si code avec acmo
CP.NAccum = 1;      % 2 si accumulation, 1 sinon
CP.Interp = 1;   % 1 si Beamforming avec interpolation, 0 sinon

% ============================================================================ %
%% Codage en arbitrary : delay matrix and waveform

% Delay matrix
Delay_mat = zeros(length(UF.FiringElts),length(UF.FlatAngles)); %(µs)

UF.TxFreq = UF.TwFreq;
for i = 1:length(UF.FlatAngles)
    
    Delay_mat(:,i) = tan(pi/180*UF.FlatAngles(i))*...
        [1:length(UF.FiringElts)]*system.probe.Pitch/(common.constants.SoundSpeed/1000);
    
    Delay_mat(:,i) = Delay_mat(:,i) - min(Delay_mat(:,i));
    
end

CP.Delay_mat_tot = Delay_mat;

% Waveform
T_Wf = [0:1/UF.SampFreq:UF.NbCycle/UF.TxFreq];
Wf = sin(2*pi*UF.TxFreq*T_Wf);

N_T = length(Wf) + round(max(Delay_mat(:))*UF.SampFreq);
WF_mat = zeros(N_T,length(UF.FiringElts),length(UF.FlatAngles));

for kk = 1:length(UF.FlatAngles)   
    for j = 1:length(UF.FiringElts)        
        WF_mat( round(Delay_mat(j,kk)*UF.SampFreq) + [1:length(Wf)],j,kk) = Wf;
    end    
end
WF_mat_sign = sign(WF_mat);
%% DO NOT CHANGE - Additional parameters

% Additional parameters for ultrafast acquisition
UF.RxFreq = min(60,4 * UF.TwFreq); % sampling frequency [MHz]
% Estimate RxDelay for ultrafast acquisition
UF.RxDelay = .75 * ImgInfo.Depth(1) * 1e3  / common.constants.SoundSpeed ;
UF.RxDuration = 2*(ImgInfo.Depth(2)) * 1e3 / common.constants.SoundSpeed*1.4;
UF.numSamples =  ceil( ( (UF.RxDuration-UF.RxDelay)*UF.RxFreq/UF.RxBandwidth)/length(UF.FiringElts) ) *length(UF.FiringElts);
UF.skipSamples = floor( UF.RxDelay*UF.RxFreq);
UF.DutyCycle=1;
CP.numSamples = UF.numSamples;
CP.skipSamples = UF.skipSamples;


%% Codage en arbitrary : preparation des acmos

% Elusev
clear ELUSEV

FC = remote.fc('Bandwidth', UF.FIRBandwidth , 0);
RX = remote.rx('fcId', 1, 'RxFreq', UF.RxFreq, 'QFilter', UF.RxBandwidth, 'RxElemts', UF.ReceivingElts, 0); %pas possible de décaler les 128 voies ailleurs en arbitrary ?

for nbs = 1:length(UF.FlatAngles)
    
    AcqDur =UF.RxDuration + UF.RxDelay + system.hardware.MinNoop +  N_T/UF.SampFreq  
    
    if AcqDur > 1/UF.PRF*1e6
        disp(['PRF too high max frame rate = ' num2str(1/AcqDur*1e6/length(UF.FlatAngles)) 'Hz'])
        return;
    else
        AcqDur = single(round(1/UF.PRF*1e6)-system.hardware.MinNoop);
    end
    
    % Flat TX    
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',nbs);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary('Waveform',squeeze(WF_mat_sign(:,:,nbs))', 'RepeatCH', 0, 'repeat',0 , ...
        'repeat256', 0, 'ApodFct', 'none', 'TxElemts',UF.FiringElts, ...
        'DutyCycle', UF.DutyCycle, 0);
        
    
    % Event
    EVENTList{nbs} = remote.event('txId', nbs, 'rxId', 1, 'noop', system.hardware.MinNoop, ...
        'numSamples', UF.numSamples, 'skipSamples', UF.skipSamples, 'duration', AcqDur, 0);  
    
end

%trig EVENT
EVENT{1} = remote.event(...
    'noop',         system.hardware.MinNoop, ...
    'duration',     system.hardware.MinNoop,... %    'waitExtTrig',   1,...
     0);
EVENT{2} = remote.event(...
    'noop',         system.hardware.MinNoop, ...
    'duration',     system.hardware.MinNoop,... % micro-s%     'genExtTrig',    1,...
    1);

% ELUSEV
% trig in
ELUSEV{1} = elusev.elusev( ...
    'event',        EVENT(1), ...
    'TrigIn',       UF.TrigIn,...
    'TrigOut',      0, ... 
    'TrigAll',      0, ...
    'TrigOutDelay', 0, ...
    0);

% trig out at beginning of acquisition sequence
 ELUSEV{2} = elusev.elusev( ...
    'event',        EVENT(2), ...
    'TrigIn',       0,...
    'TrigOut',      UF.TrigOut, ... % trig out duration  microsecond 
    'TrigAll',      0, ...
    'TrigOutDelay', 0, ...
    0);

% elusev ultrafast
ELUSEV{3} = elusev.elusev( ...
        'tx', TXList, ...
        'tw', TWList, ...
        'rx', RX, ...
        'fc', FC, ...
        'event', EVENTList, ...
        'TrigOut',   UF.TrigOut, ...
        'TrigIn',       0 ,...
        'TrigAll',      UF.TrigAll, ...
        'TrigOutDelay'  , 0, ...
                0);
            
if  UF.PauseDuration ~= 0
    ELUSEV{4} = elusev.pause( ...
        'TrigIn',        0, ...
        'TrigOut',       0, ...
        'TrigOutDelay',  0, ...
        'TrigAll',       0, ...
        'Pause',         UF.PauseDuration, ...  % in s
        0);
    
    % ACMOs
    ACMO1 = acmo.acmo( ...
        'elusev', ELUSEV, ...
        'Ordering', [1 2 repmat(3, [1 UF.NbFrames]) 4 ], ... %repmat(4, [1 round(UF.PauseDuration/0.1)])], ...
        'Repeat' ,UF.Repeat, ...
        'NbHostBuffer', UF.NbHostBuffer, ...
        'NbLocalBuffer', UF.NbLocalBuffer, ...
        'ControlPts',   UF.TGC,...
        0);    
else
        ACMO1 = acmo.acmo( ...
        'elusev', ELUSEV, ...
        'Ordering', [1 2 repmat(3, [1 UF.NbFrames])], ...
        'Repeat' ,UF.Repeat, ...
        'NbHostBuffer', UF.NbHostBuffer, ...
        'NbLocalBuffer', UF.NbLocalBuffer, ...
        'ControlPts',   UF.TGC,...
        0);
    
end

AcmoList{1}=ACMO1;

% USSE for the sequence
Sequence= usse.usse( ...
    'Loop',0,...
    'TPC', remote.tpc('imgVoltage', ImagingVoltage, 'imgCurrent', ImagingCurrent), ...
    'acmo', AcmoList,...
    'Popup',0,...
    'DropFrames',0,...
    'Repeat' ,UF.Repeat_sequence, ...
    0);

[Sequence NbAcqRx] = Sequence.buildRemote();


%% Do NOT CHANGE - Sequence execution

% Initialize remote on systems
Sequence = Sequence.initializeRemote('IPaddress',AixplorerIP, 'InitTGC',UF.TGC, 'InitRxFreq',UF.RxFreq );

% Load sequ
Sequence = Sequence.loadSequence();


heure = datestr(now, 'hh_MM_ss');

if exist('name','var')
mkdir(dir_save);
tic
save([dir_save name '_Sequence_param_' date '_' heure], '-v6', 'Sequence','CP','UF','ImgInfo');
toc 
end

disp('-------------Ready to start !-------------------- ')