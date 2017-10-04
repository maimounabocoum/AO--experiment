% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence
% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

function [SEQ,MedElmtList,NUX,NUZ] = AOSeqInit_OJM(AixplorerIP, Volt , f0 , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform);

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
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us

%% ==================== Codage en arbitrary : preparation des acmos ==============
% shooting elements 
ElmtBorns   = [min(NbElemts,max(1,round(X0/pitch))),max(1,min(NbElemts,round(X1/pitch)))];
ElmtBorns   = sort(ElmtBorns) ; % in case X0 and X1 are mixed up


Nbtot    = ElmtBorns(2) - ElmtBorns(1) + 1 ;
Xs        = (0:Nbtot-1)*pitch;             % Echelle de graduation en X

nuZ0 = 1/((c*1e3)*DurationWaveform*1e-6);  % Pas fréquence spatiale en Z (en mm-1)
nuX0 = 1.0/(Nbtot*pitch);                  % Pas fréquence spatiale en X (en mm-1)

[NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
% initialization of empty frequency matrix
NUX = zeros('like',NBX); 
NUZ = zeros('like',NBZ); 

Nfrequencymodes = length(NBX(:));
MedElmtList = 1:Nfrequencymodes ;
%% Arbitrary definition of US events
FC = remote.fc('Bandwidth', 90 , 0); %FIR receiving bandwidth [%] - center frequency = f0 : 90
RX = remote.rx('fcId', 1, 'RxFreq', 60 , 'QFilter', 2, 'RxElemts', 1:128, 0);

for nbs = 1:Nfrequencymodes
    
        nuZ  = NBZ(nbs)*nuZ0; % fréquence de modulation de phase (en Hz) 
        nuX  = NBX(nbs)*nuX0;  % fréquence spatiale (en mm-1)
        
        % f0 : MHz
        % nuZ : en mm-1
        % nuX : en mm-1
        [nuX,nuZ,~,Waveform] = CalcMatHole(f0,nuX,nuZ,Xs,SampFreq,c); % Calculer la matrice
        % upgrade frequency map : 
        NUX(nbs) = nuX ;
        NUZ(nbs) = nuZ ;
       
%       fprintf('waveform is lasting %4.2f us \n\r',size(Waveform,1)/SampFreq)
%       imagesc(Waveform);
%       pause(0.1);
        
    EvtDur   = ceil(pulseDuration + PropagationTime);   
    
    % Flat TX
    TXList{nbs} = remote.tx_arbitrary(...
                    'txClock180MHz', 1,...
                    'twId',1,...
                    'Delays',0);
    
    % Arbitrary TW
    TWList{nbs} = remote.tw_arbitrary( ...
                    'Waveform',Waveform', ...
                    'RepeatCH', 0, ...
                    'repeat',4 , ...
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
ELUSEV{nbs} = elusev.elusev( ...
                    'tx',           TXList{nbs}, ...
                    'tw',           TWList{nbs}, ...
                    'fc',           FC,...
                    'event',        EVENTList{nbs}, ...
                    'rx',           RX,...
                    'TrigOut',      TrigOut, ... 0,...
                    'TrigIn',       0,...
                    'TrigAll',      1, ...
                    'TrigOutDelay', 0, ...
                    0);

    %
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
    'Loop', 0 , ...
    'DataFormat', 'RF', ...
    'Popup', 0, ...
    0);

[SEQ NbAcq] = SEQ.buildRemote();
 display('Build OK')
 
%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems
 SEQ = SEQ.initializeRemote('IPaddress',AixplorerIP);
 display('Remote OK');

 % status :
 display('Begin loading sequence to Hardware');
     tic
     SEQ = SEQ.loadSequence();
     
     
     fprintf('Sequence has loaded in %f s \n\r',toc)
     display('--------ready to use -------------');
end



