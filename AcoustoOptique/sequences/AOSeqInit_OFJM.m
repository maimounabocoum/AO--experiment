% Sequence AO Plane Waves JB 30-04-15 ( d'apres 01-04-2015 JB)
% INITIALIZATION of the US Sequence
% ATTENTION !! Même si la séquence US n'écoute pas, il faut quand même
% définir les remote.fc et remote.rx, ainsi que les rxId des events.
% DO NOT USE CLEAR OR CLEAR ALL use clearvars instead

function [SEQ,MedElmtList,pitch,nuZ0,NUZ,ParamList] = AOSeqInit_OFJM(AixplorerIP, Volt , f0 , NbHemicycle , Foc , NbZ , X0 , X1 , step , NTrig, NU_low , Tau_cam , Phase , Master)


%% System parameters import :
% ======================================================================= %
c           = common.constants.SoundSpeed ; %[m/s]
SampFreq    = system.hardware.ClockFreq; %NE PAS MODIFIER % emitted signal sampling = 180 in [MHz]
SampFreq    = double(SampFreq);
NbElemts    = system.probe.NbElemts ; 
pitch       = system.probe.Pitch ; % in mm
MinNoop     = system.hardware.MinNoop;

NoOp       = 10000;             % µs minimum time between two US pulses


%% ======================================================================= %
n_rep = floor(Tau_cam*NU_low) ;
PropagationTime        = ( n_rep + 2 )/NU_low  ;  % 1 / pulse frequency repetition [us]38.96;%
Pause                  = max( NoOp-ceil(PropagationTime) , MinNoop ); % pause duration in µs

%% Focusing parameters
% ======================================================================= %
TxWidth         = Foc/2;           % mm : effective width for focus line

%% DelayLaw Law [us]
% ======================================================================= %
% c[m/s] -> [mm/us] ; eg factor 1e-3 in the above expression
DelayLaw = sqrt(Foc^2+(TxWidth/2)^2)/(c*1e-3) ...
        - 1/(c*1e-3)*sqrt(Foc^2+((0:pitch:TxWidth)-TxWidth/2).^2);
   
%% ===== Codage en arbitrary : delay matrix and waveform ===========
pulseDuration = NbHemicycle*(0.5/f0) ; % US inital pulse duration in us
Nphase        = max(1,length(Phase));

%DurationWaveform = 1/NU_low ;
%( n_rep + 2 ) : we chose 2 to make shure the full emission sequence will
% be issued (long overshoot in the beginning)


%% ==================== Codage en arbitrary : preparation des acmos ==============

% shooting elements 
ElmtBorns   = [min(NbElemts,max(1,round(X0/pitch))),max(1,min(NbElemts,round(X1/pitch)))];
ElmtBorns   = sort(ElmtBorns) ; % in case X0 and X1 are mixed up
% convert step in unit
step = max(1,step/pitch);
step = min(step,ElmtBorns(2)-ElmtBorns(1));
MedElmtList = ElmtBorns(1):step:ElmtBorns(2)  ;

%% modulation along z : fundamental frequency
nuZ0 = (NU_low*1e6)/(c*1e3);                 % Pas fréquence spatiale en Z (en mm-1)

[MEdElmtList,NBZ] = meshgrid(MedElmtList,NbZ);

% initialization of empty frequency matrix
NUZ = zeros('like',NBZ); 

%% adding an offset for first trigged elements:

Nfrequencymodes = length(NBZ(:));
MedElmtList = 1:Nfrequencymodes ;
%% Arbitrary definition of US events
FC = remote.fc('Bandwidth', 90 , 0); %FIR receiving bandwidth [%] - center frequency = f0 : 90
RX = remote.rx('fcId', 1, 'RxFreq', 60 , 'QFilter', 2, 'RxElemts', 1:128, 0);


%% add phase variable
PHASE = repmat(Phase(:),Nfrequencymodes,1);

%% updata log param struct
% data types : int,str,double,bool
ParamList = cell(Nfrequencymodes*Nphase + 2,4); % 1 line header + 1 line data type
ParamList(1,:) = {'Event','Xs','nbZ','phase'};
ParamList(2,:) = {'int','double','int','double'};
ParamList(3:end,4) = num2cell(PHASE); % fill in phase parameters


fprintf('Sequence is repeated %f times \n\r',n_rep)


% evaluation of empty waveform
% [~,~,~,Waveform] = CalcMatHole(f0,0,0,nuX0,nuZ0,Xs,SampFreq,c);  

for nbs = 1:Nfrequencymodes
    
        MedElmt  = MEdElmtList(nbs); % emission center index 
       
        % actual active element
        TxElemts = MedElmt-round(TxWidth/(2*pitch)):...
                   MedElmt+floor(TxWidth/(2*pitch));        
        % f0 : MHz
        % nuZ : en mm-1
        % nuX : en mm-1
        [nuZ,~,Waveform] = CalcMat_OFJM(f0,NBZ(nbs),nuZ0,SampFreq,c,DelayLaw); % Calculer la matrice
        % upgrade frequency map : 

        NUZ(nbs) = nuZ ;
       
       % save parameters in SI unit
       ParamBLOCK = repmat({sprintf('%i',nbs),...
                            sprintf('%i',pitch*MEdElmtList(nbs)),...
                            sprintf('%i',NBZ(nbs))}, Nphase , 1 );
 
                        
       ParamList((3 + (nbs-1)*Nphase): (2 + nbs*Nphase) ,1:3) = ParamBLOCK ;
                                                
                          
                          
%       fprintf('waveform is lasting %4.2f us \n\r',size(Waveform,1)/SampFreq)
%       imagesc(Waveform);
%       pause(0.1);
        
    EvtDur   = ceil(pulseDuration + PropagationTime);   
    
    % Flat TX{nbs}
    TXList{nbs} = remote.tx_arbitrary('txClock180MHz', 1,'twId',1,'Delays',0);
    
    % Arbitrary TW
    % RepeatCH = 1 : repeat singe waveform on all channels{nbs} 
    TWList{nbs}= remote.tw_arbitrary( ...
                    'Waveform',Waveform', ...
                    'RepeatCH', 0, ...
                    'repeat',n_rep, ... %nrep
                    'repeat256', 0, ...
                    'ApodFct', 'none', ...
                    'TxElemts',TxElemts( TxElemts>0 & TxElemts <= NbElemts ), ...
                    'DutyCycle', 1, ...
                    0);

    
    % Event
    switch Master
        case 'off'
    EVENTList{nbs} = remote.event( ...
                    'txId', 1, ...
                    'rxId', 1, ...
                    'noop', Pause, ...
                    'numSamples', 128, ...
                    'skipSamples', 0, ... 128, ...
                    'waitExtTrig',1,...
                    'genExtTrig',0,... % trigger duration in us
                    'duration', EvtDur, ...
                    0);
                
                    %ELUSEV
    ELUSEV{nbs} = elusev.elusev( ...
                        'tx',           TXList{nbs}, ...
                        'tw',           TWList{nbs}, ...
                        'fc',           FC,...
                        'event',        EVENTList{nbs}, ...
                        'rx',           RX,...
                        'TrigOut',      0, ... 10 in us
                        'TrigIn',       1,...
                        'TrigAll',      1, ...
                        'Repeat',       Nphase,...
                        'TrigOutDelay', 0, ...
                        0);

        case 'on'
    % Event
    EVENTList{nbs} = remote.event( ...
                    'txId', 1, ...
                    'rxId', 1, ...
                    'noop', Pause, ...
                    'numSamples', 128, ...
                    'skipSamples', 0, ... 128, ...
                    'duration', EvtDur, ...
                    0);
           
ELUSEV{nbs} = elusev.elusev( ...
                    'tx',           TXList{nbs}, ...
                    'tw',           TWList{nbs}, ...
                    'fc',           FC,...
                    'event',        EVENTList{nbs}, ...
                    'rx',           RX,...
                    'TrigOut',      10, ... 0,...
                    'TrigIn',       0,...
                    'TrigAll',      1, ...
                    'TrigOutDelay', 15, ...
                    'Repeat',       Nphase,...
                    0);            
            
    end

 
    
    
    
end

%% add empty sequence to previous ELUSEV list
% TXList{Nfrequencymodes+1} = TXList{Nfrequencymodes};
% TWList{Nfrequencymodes+1} = remote.tw_arbitrary( ...
%                         'Waveform',0*Waveform', ...
%                         'RepeatCH', 0, ...
%                         'repeat',n_rep, ... %nrep
%                         'repeat256', 0, ...
%                         'ApodFct', 'none', ...
%                         'TxElemts',ElmtBorns(1):ElmtBorns(2), ...
%                         'DutyCycle', 1, ...
%                         0);
% EVENTList{Nfrequencymodes+1}= EVENTList{Nfrequencymodes};
% ELUSEV{Nfrequencymodes+1} = elusev.elusev( ...
%                     'tx',           TXList{Nfrequencymodes+1}, ...
%                     'tw',           TWList{Nfrequencymodes+1}, ...
%                     'fc',           FC,...
%                     'event',        EVENTList{Nfrequencymodes+1}, ...
%                     'rx',           RX,...
%                     'TrigOut',      10, ... 0,...
%                     'TrigIn',       0,...
%                     'TrigAll',      1, ...
%                     'TrigOutDelay', 10, ...
%                     'Repeat',       10,...
%                     0);  

% ======================================================================= %
%% ELUSEV and ACMO definition

% we are implementing last the first ELUSEV emitted in order to lauch false
% triggers on camera and calibrated empty sequence noise
% ordering to test : [Nfrequencymodes+1,1:Nfrequencymodes]

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
    'acmo', ACMOList, ...    
    'Loopidx',1, ...     % index to which the loop goes back to
    'Repeat', max(NTrig-1,1), ...  'Popup',0, ...
    'DropFrames', 0, ...
    'Loop', 0, ...
    'DataFormat', 'RF', ...
    'Popup', 0, ...
    0);

[SEQ, ~] = SEQ.buildRemote();
 display('Build OK')
 
 
% convert to SI unit
nuZ0 = nuZ0*1e3;


%%%    Do NOT CHANGE - Sequence execution 
%%%    Initialize remote on systems
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



