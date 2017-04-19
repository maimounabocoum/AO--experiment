

% Cano.RxDuration = A{1}.getParam('RxDuration');
% Cano.RxDelay = A{1}.getParam('RxDelay');
% Cano.RxFreq = A{1}.getParam('RxFreq');
% Cano.TwFreq = A{1}.getParam('TwFreq');


Cano.RxDuration = 819;
Cano.RxDelay = 0;

% imag
Cano.RxDuration = 800;
Cano.RxDelay = 0;

Cano.RxFreq = 5;
Cano.TwFreq = .9;
NbHcycle = 2; %* round( (Cano.RxDuration*1.1) * Cano.TwFreq );
% NbHcycle = NbHcycle - mod(NbHcycle,2); % even

% TwFreq   = 9;     % MHz
% NbHcycle = 2;

Pause   = 1; % us
% AcqDur  = 95; % 2*40/1.5; % us
TGC = 900;
% voltage_measurement = 1; % 0 or 1

TxDelays = 0;

% RxElemts = 1; %:system.probe.NbElemts/2;
% RxFreq = TwFreq*4;
% RxDelay = 130; %2*130/1.5;

AixplorerIP    = '192.168.1.78'; 
AixplorerIP    = '192.168.3.1'; 

% load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat
% ok_chans = sort( ok_chans_dab(1:320) );
% TxElemts = ok_chans(1:256); %sort( ok_chans_dab(1:320/2) );
% TxElemts = 1:system.probe.NbElemts;

TxElemts = [ 1:64 257:256+64 ] + 3*64; % Zif par Zif
TxElemts = 1:256 %256; % 
% TxElemts = (1:256) +256; % 
% TxElemts = 1:system.probe.NbElemts; % all
% TxElemts = 8;

RxElemts = 1:system.probe.NbElemts;

% Create canonical elusev
% ELUSEV = elusev.hadamard( ...
ELUSEV = elusev.canonical( ...
    'TrigIn', 0, ...
    'TrigOut', 0, ...
    'TrigAll', 0, ...
    'TxElemts', TxElemts, ...
    'TxDelays', TxDelays, ... % scalar: all, vector: size of TxElemts
    'TwFreq', Cano.TwFreq, ...
    'NbHcycle', NbHcycle, ...
    'DutyCycle', 1, ...
    'RxElemts', RxElemts, ... % -1: emitting element, 0: all, [...]>0 only given elements
    'RxFreq', Cano.RxFreq, ...
    'RxDelay', Cano.RxDelay, ...
    'RxDuration', Cano.RxDuration, ...
    'VGAInputFilter', 3, ... 3=voltage, 0=impedance, ... % 3*voltage_measurement, ...
    'QFilter', 1, ...
    'Bandwidth', 100, ...    'Bandwidth', -1, ... -1 for imp
    'Pause', 5, ...
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

% return

% Sequence execution

% Initialize & load sequence remote
Sequence = Sequence.initializeRemote( 'IPaddress', AixplorerIP, 'InitTGC',TGC, 'InitRxFreq',Cano.RxFreq );
Sequence = Sequence.loadSequence();

% disp('press a key !')
% pause

%% Start sequence
Sequence = Sequence.startSequence( 'Wait', 1 );

% Retrieve data
disp( 'getting data' )
clear buf
tic
for k = 1 : NbAcq
    buf(k) = Sequence.getData( 'Realign', 1 ); %, 'RxChans', RxElemts );
end
toc

% Stop sequence
Sequence = Sequence.stopSequence( 'Wait', 1 );

%% imp
imp = zeros( [ size(buf.data,1)-128 system.probe.NbElemts ] );
for n = 1:length(TxElemts)
    imp(:,TxElemts(n)) = squeeze( sum( buf.data(1:end-128,TxElemts(n),[2*n-1 2*n] ), 3 ) );
end

figure; imagesc( imp ); caxis( [-1 1]*1e4 )
% figure;plot( imp(:,8) )

return

elec_HS_RX = [ 2 3 4 310  81 374   155 411  199 204 212  455 460 468 ] ;


%% BTE impedance
NFFT = 8192;
f0_id = round(Cano.TwFreq*NFFT/ELUSEV.getParam('RxFreq'))+1;

% ref
clear all_imp
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif1_60HC.mat
all_imp( :, [1:64 257:256+64] ) = imp( :, [1:64 257:256+64] ) ;
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif2_60HC.mat
all_imp( :, [1:64 257:256+64]+64 ) = imp( :, [1:64 257:256+64]+64 ) ;
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif3_60HC.mat
all_imp( :, [1:64 257:256+64]+64*2 ) = imp( :, [1:64 257:256+64]+64*2 ) ;
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif4_60HC.mat ; imp = imp(1:end-128,:);
all_imp( :, [1:64 257:256+64]+64*3 ) = imp( :, [1:64 257:256+64]+64*3 ) ;
I_fft = fft( all_imp, NFFT );
z = I_fft( f0_id, : );
A_ref = abs( z );
phi_ref = angle( z );

% probe
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif1_60HC_probe.mat
all_imp( :, [1:64 257:256+64] ) = imp( :, [1:64 257:256+64] ) ;
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif2_60HC_probe.mat
all_imp( :, [1:64 257:256+64]+64 ) = imp( :, [1:64 257:256+64]+64 ) ;
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif3_60HC_probe.mat
all_imp( :, [1:64 257:256+64]+64*2 ) = imp( :, [1:64 257:256+64]+64*2 ) ;
load /mnt/tmp/tmp/120924_impedance/U5V_F09_Zif4_60HC_probe.mat
all_imp( :, [1:64 257:256+64]+64*3 ) = imp( :, [1:64 257:256+64]+64*3 ) ;
I_fft = fft( all_imp, NFFT );
z = I_fft( f0_id, : );
A_probe = abs( z );
phi_probe = angle( z );

Z = A_probe ./ A_ref * 50 .* exp( 1i*(phi_probe-phi_ref) )

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat
figure; plot( abs(Z(sort(ok_chans_dab))) )

%%
NbTx = length(TxElemts);
NbRx = length(RxElemts);
NbSmp = size( buf.data, 1 )-128;
NbRF = size( buf.data, 3 );
RFmean = zeros( [ NbSmp NbTx NbRx ], 'single' );

for n=1:NbTx
    n
    RFmean(:,:,n) = mean( buf.data(1:end-128,:,[(2*n-1):2*NbRx:NbRF (2*n):2*NbRx:NbRF]), 3 ) ;
end


figure; imagesc( sum( RFmean, 3 ) ); caxis( [-1 1]*1e3 )

return

%%
figure
for n=1:NbTx
    imagesc( RFmean(:,:,n) )
    caxis( [-1 1]*1e3 )
    title(num2str(n))
    pause %(0.01)
end

%%


[B,A] = butter(4,0.5/Sequence.InfoStruct.rx(1).Freq*2,'high');
RF_filt = filter(B,A,single(buf.data),[],3);

figure; 
imagesc(RF_filt(:,:,1))

% for n=1:128; imagesc( buf.data(:,:,n) ); caxis( [-1 1]*5e3); pause( 0.1 ); end


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


%% 121108
probe_skull_01 = { '/mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_probe_skull_pos1_10V_long_zif_1_2.mat' ; ...
    '/mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_probe_skull_pos1_10V_long_zif_3_4.mat' } ;
probe_skull_02 = { '/mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_probe_skull_pos2_10V_long_zif_1_2.mat' ; ...
    '/mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_probe_skull_pos2_10V_long_zif_3_4.mat' } ;

for nzif = 1:2 % 1:4 or 1:2
    filename = [ '/mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_charge_10V_long_zif' num2str(nzif) ]; % ref
    filename = [ '/mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_probe_10V_long_zif' num2str(nzif) ]; % probe
    filename = probe_skull_02{nzif};
    
    load ( filename )

    A = Sequence.getParam('acmo' );
    E = A{1}.getParam('elusev');

    TxElemts = E{1}.getParam('TxElemts') 
    NbTx = length( TxElemts );
    NbRx = length( E{1}.getParam('RxElemts') );
    NbSmp = size( buf.data, 1 )-128;
    NbRF = size( buf.data, 3 );
    RFmean = zeros( [ NbSmp NbRx NbTx], 'single' );
    RF_chan = zeros( [ NbSmp NbTx], 'single' );

    for n=1:NbTx
        n
        RFmean(:,:,n) = mean( buf.data(1:end-128,:,[(2*n-1):2*NbRx:NbRF (2*n):2*NbRx:NbRF]), 3 ) ;

        n2 = TxElemts(n);
        RF_chan(:,n) = RFmean(:,n2,n);
    end

%     figure; imagesc( RF_chan )

    RF_chan_final( :, TxElemts ) = RF_chan ;
end

figure; imagesc( RF_chan_final )

Ref_HS = [ 1:4 155 199 404 212 320 411 455 460 468 ] ;



%%
load /mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_charge_10V_long_zif_all.mat
load /mnt/tmp/tmp/121111_echo_and_imp_skull/121111_imp_probe_10V_long_zif_all.mat

NFFT = 8192;
all_f = (0:NFFT-1)/NFFT * E{1}.getParam('RxFreq') ;
[ tmp f_id ] = min( abs(all_f-0.9) )

s_ref = RF_imp_chan_ref;
S_ref = fft( s_ref, NFFT ) ;
S_ref_f = S_ref( f_id, : );
A_ref = abs( S_ref_f );
P_ref = angle( S_ref_f );

s_probe = RF_imp_chan_probe;
S_probe = fft( s_probe, NFFT ) ;
S_probe_f = S_probe( f_id, : );
A_probe = abs( S_probe_f );
P_probe = angle( S_probe_f );

Z = A_probe ./ A_ref * 50 .* exp( 1i*(P_probe-P_ref) );

%figure; imagesc( 1:size(S,2), all_f, abs(S) ) ;

%%
    s = double( buffer(1).data );
    figure(32235); subplot(2,1,1); plot( s ); %xlim( [ 0 200 ]);
    %figure(32235); subplot(2,1,1); imagesc( s ); %xlim( [ 0 200 ]);
    title( num2str(n) )
    Sri = fft( s, 8192 ) ;
    S = abs( Sri );
    subplot(2,1,2); plot( (0:8191)/8192*ELUSEV.getParam('RxFreq'), S); xlim( [ 0 6 ] );
