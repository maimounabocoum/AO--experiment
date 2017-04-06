% Sequence AO Foc JB 01-04-15 ( d'apres 03-03-2015 Marc) modified by
% Maïmouna Bocoum 26 - 02 -2017
clearvars
 clear ELUSEV EVENTList TWList TXList TRIG ACMO ACMOList SEQ

 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 
 % get loaded sequence :
 %srv = remoteDefineServer('extern',AixplorerIP, 9999);
 %SEQ = remoteGetUserSequence(srv)
 %srv = remoteDefineServer('extern', '192.168.1.16', 9999)
 % status :
 display('Initializing remote control')


% user defined parameters :
    Volt            = 20; % Volts
    f0              = 6;  % MHz
    NbHemicycle     = 8;  % number of have cycles
    X0              = 0;  % mm : position of min actuator for the scan
    Foc             = 35; % mm
    ScanLength      = 15; % mm
    NTrig           = 2; % number of repetition
    
    Z1              = 1;  % mm
    Z2            = 70; % mm



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
PropagationTime = (Z2)/(c)*1e3 ; % duration for one line in \mu s


NoOp       = 100;             % µs minimum time between two US pulses, (5 by default ??)
FIRBandwidth = 2;            % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
RxFreq    = 60;                % Receiving center frequency MHz , ??

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

% figure(470);
% imagesc((0:pitch:TxWidth)-TxWidth/2,1:N_T, WF_mat);
% grid on
% title('input waveform');
% xlabel('position x');
% ylabel('offset num ??');

% ======================================================================= %
%% Arbitrary definition of US events 
 FC = remote.fc('Bandwidth', FIRBandwidth , 0);

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
%     
%         figure(471)
%         imagesc(WFtmp)
%         drawnow
    
    % Flat TX
    TXList{Nloop} = remote.tx_arbitrary('txClock180MHz', 1,'twId',Nloop,'Delays',0);
    RXList{Nloop} = remote.rx('fcId',1, 'RxFreq', RxFreq, 'QFilter', 2, 'RxElemts', 0, 1);
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
        'rxId',Nloop, ...
        'noop', Pause, ...
        'numSamples', 128, ...
        'skipSamples', 0, ... 128, ...
        'duration', EvtDur, ... %
        0);
    

end

% % ======================================================================= %
% %% ELUSEV and ACMO definition
% % ======================================================================= %

ELUSEV = elusev.elusev( ...
    'tx',           TXList, ...
    'tw',           TWList, ...
    'rx',           RXList,...
    'fc',           FC,...
    'event',        EVENTList, ...
    'TrigOut',      TrigOut, ... 
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
    'Popup', 0, ...
    0);

 display('Building sequence to controllor')
 
 [SEQ NbAcqRx] = SEQ.buildRemote();

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
 disp('-------------Ready to use-------------------- ')
 
 SEQ = SEQ.startSequence();

clear buffer;
        disp('Getting buffer');

        for k = 1:NbAcqRx
        buf(k) = SEQ.getData('Realign', 2, 'Timeout',5);
        end
        
        %------- initialize retreiving process for focused waves -----

% %-------------------------------- retreive data ------
% % retreived Image infos :PROBLEM : seqUENCE NOT COMBPATOIBLE WHEN NOT
% DEFINED AS bfoc
            %  ImgInfo.TxPolarity      = [ 0 ]; % [ 0 1 ] : 0: Standard polarity, 1:Inverted polarity
            %  ImgInfo.TxElemsPattern  = [ 0 ]; % [ 0 2 ] : 0: All elements, 1: Odd elements, 2: Even elements
            %  ImgInfo.SteeringAngle   = 0; % steering angle [not implemented yet]
            %  ImgInfo.XOrigin         = 0 ; % xmin [mm]
            %  ImgInfo.FirstLinePos    = 1 ; % position of the first line in elt [>=1]
            %  ImgInfo.txPitch         = 1 ; % txpitch [elements] : entire value corresponding to constant spacing (min = 1)
            %  ImgInfo.nbTx            = 128 ; % txpitch [elements] 128 number of element shooting from element 1
            %  ImgInfo.RxLinesPerTx    = 1;  % number of received line per tx (beamforming) ????????????
            %  ImgInfo.PitchPix        = 0.5;  % dz / lambda
            %  ImgInfo.Depth(1)        = Z1;   % initial depth [mm]
            %  ImgInfo.Depth(2)        = Z2;  % final depth [mm]
            %  ImgInfo.RxApod(1)       = 0.4; % RxApodOne
            %  ImgInfo.RxApod(2)       = 0.6; % RxApodZero    
            %  
            % disp('LUT computation');
            % NThreads = 1; %%%%??
            % bfocId = 1; %%%%%????
            % BFStruct = processing.lutBfoc( SEQ, bfocId, ImgInfo, NThreads );
            % 
            % if system.probe.Radius > 0
            % Data = processing.lutScanConvertImage( BFStruct, ImgInfo, 1024, 1024 ); % TODO: remove hardcoded size
            % end


for k = 1 : length(SEQ.InfoStruct.event)
    
    TmpImg = 20 * log10(single(abs(buf.RFdata(:,:,k))));

    
    imagesc(TmpImg, [50 100]);
    drawnow
    pause(0.1)
    
end

figure;
imagesc(log(double(abs(sum(buf.RFdata,3)))))
 SEQ = SEQ.stopSequence();
 
 %SEQ = SEQ.quitRemote();
 