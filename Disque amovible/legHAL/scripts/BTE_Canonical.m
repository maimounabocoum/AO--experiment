load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

TwFreq   = .9;     % MHz
NbHcycle = 2;
Pause   = 1; % us
AcqDur  = 128; %2*40/1.5; % us
TGC = 960;
% voltage_measurement = 1; % 0 or 1

TxDelays = 0;

% RxElemts = 1; %:system.probe.NbElemts/2;
RxFreq = 5;
RxDelay = 50 %80 * 2/1.5;
AcqDur = 200;

% AixplorerIP    = '192.168.1.26'; 
AixplorerIP    = '192.168.3.1'; 

% load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat
% ok_chans = sort( ok_chans_dab(1:320) );
% TxElemts = ok_chans(1:256); %sort( ok_chans_dab(1:320/2) );
TxElemts = ok_chans_dab;

RxElemts = 320;


% Create canonical elusev
% ELUSEV = elusev.hadamard( ...
ELUSEV = elusev.canonical( ...
    'TrigIn', 0, ...
    'TrigOut', 0, ...
    'TrigAll', 0, ...
    'TxElemts', TxElemts, ...
    'TxDelays', TxDelays, ... % scalar: all, vector: size of TxElemts
    'TwFreq', TwFreq, ...
    'NbHcycle', NbHcycle, ...
    'DutyCycle', 1, ...
    'RxElemts', RxElemts, ... % -1: emitting element, 0: all, [...]>0 only given elements
    'RxFreq', RxFreq, ...
    'RxDelay', RxDelay, ...
    'RxDuration', AcqDur, ...
    'VGAInputFilter', 0, ... 3, ... % 3*voltage_measurement, ...
    'QFilter', 1, ...
    'Bandwidth', 100, ...
    'Pause', 500, ...
    'Repeat', 1, ...
    'PauseEnd', 8, ...
    0);

% ACMO for the sequence
ACMO = acmo.acmo( ...
    'elusev', ELUSEV, ...
    'ControlPts', TGC, ...
    0);

% USSE for the sequence
SEQ = usse.usse( ...
    'acmo', ACMO, ...
    'TPC', remote.tpc('imgVoltage', 60, 'imgCurrent', 1), ...
    0);

% Build remote structure
[Sequence NbAcq] = SEQ.buildRemote();



% Sequence execution

% Initialize & load sequence remote
Sequence = Sequence.initializeRemote( 'IPaddress', AixplorerIP, 'InitTGC',TGC, 'InitRxFreq',RxFreq );
Sequence = Sequence.loadSequence();

% disp('press a key !')
% pause

% Start sequence
Sequence = Sequence.startSequence( 'Wait', 1 );

% Retrieve data
clear buffer
for k = 1 : NbAcq
    buffer(k) = Sequence.getData( 'Realign', 1 ); %, 'RxChans', RxElemts );
end

% Stop sequence
Sequence = Sequence.stopSequence( 'Wait', 0 );



%%

return

[B,A] = butter(4,0.5/Sequence.InfoStruct.rx(1).Freq*2,'high');
RF_filt = filter(B,A,single(buffer.data),[],3);

figure; 
imagesc(RF_filt(:,:,1))

% for n=1:128; imagesc( buffer.data(:,:,n) ); caxis( [-1 1]*5e3); pause( 0.1 ); end


%%
load ~/buffer_hadamard.mat

TxElemts = 1:128;
NbTx = length( TxElemts );
Hadamard_Matrix = hadamard( NbTx );
Hadamard_Matrix_inv = inv( Hadamard_Matrix );

data2 = zeros( size( buffer.data ), 'single' );
for n = 1:NbTx
    n
    for n2 = 1:NbTx
        n2_coef = Hadamard_Matrix_inv( n2, n );
        data2(:,:,n) = data2(:,:,n) + single(buffer.data(:,:,n2) ) * n2_coef; 
    end
end

%%
load ~/buffer_canonic.mat
data1 = buffer.data;

figure( 762362 )
for n = 1:NbTx
    subplot( 2,1, 1)
    imagesc( data1(:,:,n) ); caxis( [-1 1]*1e3 *8);

    subplot( 2,1, 2)    
    imagesc( data2(:,:,n) );
    caxis( [-1 1]*3 * 128 * 8 )
    title( num2str(n) )
    pause( 0.1 )
end





