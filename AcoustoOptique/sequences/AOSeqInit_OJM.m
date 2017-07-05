% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence
% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

function SEQ = AOSeqInit_OJM(AixplorerIP, Volt , f0 , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform);


% user defined parameters :

    ScanLength      = X1 - X0; % mm
        


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
TrigOut                = 10;  %µs
Pause                  = max( NoOp-ceil(PropagationTime) , MinNoop ); % pause duration in µs

% ======================================================================= %
%% Codage en arbitrary : delay matrix and waveform
dt_s          = 1/(SampFreq);  % unit us
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us

%====================================================================== %
%% Arbitrary definition of US events
FC = remote.fc('Bandwidth', 90 , 0); %FIR receiving bandwidth [%] - center frequency = f0 : 90
RX = remote.rx('fcId', 1, 'RxFreq', 60 , 'QFilter', 2, 'RxElemts', 0, 0);

%% Codage en arbitrary : preparation des acmos

NbPixels = 128;                     % nombre de pixels
Xs       = (0:NbPixels-1)*pitch;    % Echelle de graduation en X
%u        = 1.54;                    % vitesse de propagation en mm/us


freq0 = 1e6/DurationWaveform;     % Pas fréquentiel de la modulation de phase (en Hz)
nuX0 = 1.0/(NbPixels*pitch);      % Pas fréquence spatiale en X (en mm-1)

[NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
Nfrequencymodes = length(NBX(:));

for nbs = 1:Nfrequencymodes
    
        fz   = NBZ(nbs)*freq0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % fz : 
        % nuX : en mm-1
        Waveform = CalcMatHole(f0,fz,nuX,Xs); % Calculer la matrice
       
%       fprintf('waveform is lasting %4.2f us \n\r',size(Waveform,1)/SampFreq)
%       imagesc(Waveform);
%       pause(0.1);
        
    EvtDur   = ceil(pulseDuration + PropagationTime);   
    
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',1,'Delays',0);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary( ...
        'Waveform',Waveform', ...
        'RepeatCH', 0, ...
        'repeat',4 , ...
        'repeat256', 0, ...
        'ApodFct', 'none', ...
        'TxElemts',1:NbPixels, ...
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
    'Repeat', NTrig, ...  'Popup',0, ...
    'DropFrames', 0, ...
    'Loop', 0, ...
    'DataFormat', 'FF', ...
    'Popup', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();
 display('Build OK')
 
%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems
 SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);

 display('Remote OK');

 % status :
 display('Loading sequence to Hardware');
 tic
 SEQ = SEQ.loadSequence();
 toc
 disp('-------------Ready to use-------------------- ')
end



