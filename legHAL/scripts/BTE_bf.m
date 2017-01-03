% 0 -5 -10
% -10:5:10
clear vars 

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

% all_bte_angles = [ 5 0 0 ; 0 5 0; 0 0 5 ];

% all_angul_Z = [ -40:1:0 ];
% all_angul_Y = [ -20:1:20 ];
% all_angul_X = [ -20:1:20 ];
% 
% all_angul_Z = [ -0:10:0 ];
% all_angul_Y = [ -20:10:20 ];
% all_angul_X = [ -20:10:20 ];

ang_dx = 20;
ang_lat = 20;
all_angul_Z = 0; %[-10 -5 0];
all_angul_Y = -ang_lat:ang_dx:ang_lat;
all_angul_X = -ang_lat:ang_dx:ang_lat;

cc = clock ;
clock_str = [ num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6))) ];

file_prefix = [ '/home/labo/manip_bf_' clock_str '_gel_mou_' ];

clear all_bte_angles
n_acq_zz = 1;
for az = all_angul_Z
    for ay = all_angul_Y
        for ax = all_angul_X
            all_bte_angles( n_acq_zz, : ) = [ az -ax -ay ];
            n_acq_zz = n_acq_zz + 1;
        end
    end
end
n_acq_zz

% all_bte_angles = 3*[ 0 0 0 ; -10 0 0; 10 0 0; 0 0 -10; 0 0 10];

% if 1 %0

    % clear all

    % SCRIPTS.ULTRAFAST (PUBLIC)
    %   Build and run a sequence with an ultrafast imaging.
    %
    %   Note - This function is defined as a script of SCRIPTS package. It cannot be
    %   used without the legHAL package developed by SuperSonic Imagine and without
    %   a system with a REMOTE server running.
    %
    %   Copyright 2010 Supersonic Imagine
    %   Revision: 1.00 - Date: 2010/03/25

    %% Parameters definition

%     global bte_angul;
%     bte_angul = [ -10 0 0 ];
    
f0 = 0.9;

    global R_virt;
    
    % System parameters
    debugMode = 0 ;
    AixplorerIP    = '192.168.1.147'; % IP address of the Aixplorer device
    % AixplorerIP    = '192.168.1.26'; % IP address of the Aixplorer device
    AixplorerIP    = '192.168.3.1'; % IP address of the Aixplorer device
    ImagingVoltage = 10;             % imaging voltage [V]
    ImagingCurrent = 1;              % security current limit [A]

    % ============================================================================ %

    UF.RxFreq = 5; % sampling frequency [MHz]

    % Image parameters
    ImgInfo.Depth(1)           = 10; % initial depth [mm]
    ImgInfo.Depth(2)           = 180;  % image depth [mm]
    ImgInfo.NbColumnsPerPiezo  = 1;
    ImgInfo.NbRowsPerLambda    = 1;

    % ============================================================================ %

    % Ultrafast acquisition parameters    
    UF.PulseInversion = 0; % 1 or 0
    UF.TxPolarity     = [ 0 ];
    UF.TwFreq       = f0/(UF.PulseInversion+1) ; % emission frequency [MHz]
    UF.NbHcycle     = 2;               % # of half cycles
    UF.BTE_steering = all_bte_angles; % Z -X -Y
    UF.DutyCycle    = 1;               % duty cycle [0, 1]
    UF.TxCenter     = system.probe.Pitch*system.probe.NbElemts * 1/2;            % emission center [mm]
    UF.TxWidth      = system.probe.Pitch*system.probe.NbElemts /1 ;            % emission width [mm]
    UF.ApodFct      = 'none';          % emission apodization function (none, hanning)
    UF.RxCenter     = system.probe.Pitch*system.probe.NbElemts * 1/2;     % reception center [mm]
    UF.RxWidth      = system.probe.Pitch*system.probe.NbElemts /1;      % reception width [mm]
    UF.RxBandwidth  = 1;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
    UF.FIRBandwidth = 100;              % FIR receiving bandwidth [%] - center frequency = UF.TwFreq
    UF.NbFrames     = 75;               % # of acquired images
    UF.FrameRateUF  = 100;
    UF.PRF          = UF.FrameRateUF*size(all_bte_angles,1);            % pulse frequency repetition [Hz] (0 for greatest possible)
    UF.TGC          = 960 * ones(1,8); % TGC profile
    UF.TrigIn       = 0 ;
    UF.Repeat       = 1 ;
    UF.NbLocalBuffer= 2 ;
    UF.NbHostBuffer = 2 ;

    % ============================================================================ %
    %% DO NOT CHANGE - Additional parameters

    % Additional parameters for ultrafast acquisition

    % Estimate RxDelay for ultrafast acquisition
    UF.RxDelay = round(2 * ImgInfo.Depth(1) * 1e3 / common.constants.SoundSpeed) ;

    % Estimate RxDuration for ultrafast acquisition

    UF.RxDuration = 2*(ImgInfo.Depth(2) - ImgInfo.Depth(1)) *1e3 / common.constants.SoundSpeed;

    tof_dab = clelia_steer( 0, 0, 0, 1.5,  'tuccirm' );
    phi_dab = mod(tof_dab, 1/f0)*1e-6 * f0*1e6 * 2*pi ;

    %% DO NOT CHANGE -  acquisition mode

    % 2012_8_16_16_18_37 1ms 20V, petite bulle
    % 2012_8_16_16_26_30 3ms 20V, bulle ok
    % 2012_8_16_16_41_23 3ms 20V, angul 15 0 0, rien d'evident
    % 2012_8_16_16_45_47 3ms 20V, angul 15 0 0, rien d'evident
    % 2012_8_16_16_52_20 3ms 20V, bulle ok
    % 2012_8_16_16_53_47 3ms 20V, angul 1.5 0 0, 2 bulles
    % 2012_8_16_16_54_48 3ms 20V, angul 3 0 0, 1 bulle
    % 2012_8_16_16_54_48 3ms 20V, angul 4.5 0 0, 1 bulle
    % 2012_8_16_16_56_50 3ms 20V, angul 6 0 0, 0 bulle
    % 2012_8_16_16_58_33 3ms 20V, angul 6 0 0, .8 MHz, 0 bulle
    % 2012_8_16_17_11_19 -1.5 1 bulle
    % -3, 10 ms, bulle au fond ?
    % gel dec
    % 2012_8_16_17_18_34 3 mm
    
    
    try

        % Create the ultrafast acquisition mode and add the push elusev
        clear AcmoList
        
        HifuAcmoID = 1 ;
        HIFU = elusev.hifu( ...
            'TwFreq', f0, ...
            'TwDuration', 1, ... 10e3, ...
            'TxElemts', ok_chans_dab, ...
            'Phase', phi_dab(ok_chans_dab), ...
            'DutyCycle', 0, ...
            'RxFreq', UF.RxFreq, ...
            'RxDuration', 0, ...
            'RxElemts', 0, ...
            'TrigIn', 0, ...
            'TrigOut', 1e-3, ...
            'TrigAll', 0, ...
            'Repeat', 1, ... 64 * 8 * 2, ...
    ...        'Pause', 1e3, ...
            debugMode );
        % Create ACMO object
        Acmo_HIFU = acmo.acmo( ...
            'Duration', 0, ...
            'ControlPts', UF.TGC, ...
            'Repeat', 1, ...
            'elusev', HIFU, ...
            debugMode );
    
        UltrafastAcmoID = 2 ;
        Acmo_UF = acmo.ultrafast_bte( ...
            'TwFreq',       UF.TwFreq, ...
            'NbHcycle',     UF.NbHcycle, ...
            'BTE_steering', UF.BTE_steering, ...
            'DutyCycle',    UF.DutyCycle, ...
            'TxCenter',     UF.TxCenter, ...
            'TxWidth',      UF.TxWidth, ...
            'TxPolarity',   UF.TxPolarity, ...
            'ApodFct',      UF.ApodFct, ...
            'RxFreq',       UF.RxFreq, ...
            'RxDuration',   UF.RxDuration, ...
            'RxDelay',      UF.RxDelay, ...
            'RxCenter',     UF.RxCenter, ...
            'RxWidth',      UF.RxWidth, ...
            'RxBandwidth',  UF.RxBandwidth, ...
            'FIRBandwidth', UF.FIRBandwidth, ...
            'RepeatFlat',   UF.NbFrames, ...
            'PRF',          UF.PRF, ...
            'FrameRate',    0, ...
            'FrameRateUF',  UF.FrameRateUF, ...
            'ControlPts',   UF.TGC,...
            'TrigIn',       UF.TrigIn,...
            'Repeat',       UF.Repeat, ...
            'NbLocalBuffer',UF.NbLocalBuffer, ...
            'NbHostBuffer' ,UF.NbHostBuffer );

%           AcmoList{HifuAcmoID} = Acmo_HIFU ;
%           AcmoList{UltrafastAcmoID} = Acmo_UF ;
          AcmoList{1} = Acmo_UF ;

    catch ErrorMsg
        errordlg(ErrorMsg.message, ErrorMsg.identifier);
    end

    % ============================================================================ %
    % ============================================================================ %

    %% DO NOT CHANGE - Create and build the ultrasound sequence

    try

        % Create the TPC object
        TPC = remote.tpc( ...
            'imgVoltage', ImagingVoltage, ...
            'imgCurrent', ImagingCurrent);

        % Create  and build the sequence
        Sequence = usse.usse('TPC', TPC, 'acmo', AcmoList, 'Popup',0 );
    %     Sequence = Sequence.selectProbe();
        [Sequence NbAcqRx] = Sequence.buildRemote();

    catch ErrorMsg
        errordlg(ErrorMsg.message, ErrorMsg.identifier);
        return
    end
% 
%     
% A = Sequence.getParam('acmo');
% Sequence.plot_diagram; xlim( [ 0 2/A{1}.getParam('FrameRate')*1e6 ] ); ylim( [ -1 2 ] ); hold on;
% plot( repmat( 1/A{1}.getParam('PRF')*1e6, 1, 2), [ -1e3 1e3 ], 'g' )
% plot( repmat( 1/A{1}.getParam('FrameRateUF')*1e6, 1, 2), [ -1e3 1e3 ], 'k' )
% plot( repmat( 1/A{1}.getParam('FrameRate')*1e6, 1, 2), [ -1e3 1e3 ], 'r' )

    %% Do NOT CHANGE - Sequence execution
% return
    try

        if(debugMode)
            buffer = test.CreateDebugBuff2(Sequence,NbAcqRx);
        else
            % Initialize remote on systems
            Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP, 'InitTGC',UF.TGC, 'InitRxFreq',UF.RxFreq );

            % Load sequence
            Sequence = Sequence.loadSequence();

            % Execute sequence
            clear buffer;
%             disp('PRESS A KEY !!!' )
%             pause
            tic
            Sequence = Sequence.startSequence('Wait', 0);
            toc

            tic
            % Retrieve data
            for k = 1 : NbAcqRx
                buffer(k) = Sequence.getData('Realign', 1);
            end
            transfer_time = toc

            % Stop sequence
            Sequence = Sequence.stopSequence('Wait', 1);

        end

    catch ErrorMsg
        errordlg(ErrorMsg.message, ErrorMsg.identifier);
        return
    end
    
%     return
    %% save
    cc = clock ;
    clock_str = [ num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6))) ];
    
    file_prefix = [ '/media/LA-PUBLIC/manip3D/manip_bf_' clock_str '_flow' ];
    
%     clear img_mean_co img_h img bf_3D_cuda RF RF_to_BF img_mean
    %save( [ file_prefix '.mat' ], 'all_bte_angles','Sequence','buffer','UF' );

%     treat_120607
    
%% treat
% 2012_8_16_12_8_4 big
% 2012_8_16_15_6_22 big avant mb 20V
% 2012_8_16_15_26_45 big avec mb, 4V
% 2012_8_16_15_35_56 big avec mb, 20V duty .2

% 2012_8_16_15_38_24 bulle 20V 100 us, img 20V, MB
% 2012_8_16_15_42_25 bulle 20V 5e3 us, img 20V, MB, belle

% 2012_8_16_15_50_29 bulle 20V 5e3 us, img 20V, MB, n vs end, bulle_ok

% 7V matching
% 2012_8_16_19_59_32 psf
% 2012_8_16_20_4_2 psf 20 / 10, best
% 2012_8_16_20_8_58 idem

% 2012_8_16_22_24_6 fuck 30/5

% 2012_8_16_22_30_34 psf 40/10
% 2012_8_16_22_38_16 psf 30/5, foireuf ?

% 2012_8_16_23_19_19 gel trou

% end

 % Execute sequence
% clear buffer;
% Sequence = Sequence.startSequence('Wait', 0);
% 
% % n_pos_bfo
% disp('OK')
% 
% % Retrieve data
% for k = 1 : NbAcqRx
%     buffer(k) = Sequence.getData('Realign', 1);
% end
% 
% % Stop sequence
% Sequence = Sequence.stopSequence('Wait', 1);

% save ( [ '~/110316_manip_echo_gel_cuve_refl_' num2str(n_pos_bfo) '.mat' ], 'buffer' );

% addpath /home/labo/Work/Thesis/Studies/BT_beamforming/
% treat_do_plot = 1;
% treat_120607
% 
% figure(7621532); plot( [ Sequence.InfoStruct.event(:).duration ] ) ; title(['PRF : ' num2str( 1e6/2/mean( [ Sequence.InfoStruct.event(3:end).duration ])) ] )

return

%%
fsamp = 5;

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

ok_chans = sort( ok_chans_dab(1:320) );
RF = buffer.data(:,ok_chans,:);

%save ~/bfo_manip1_30.mat
% 
RF(:,93,:) = 0;
RF(:,127,:) = 0;
RF(:,133,:) = 0;
RF(:,122,:) = 0;
% RF(:,257:end,:) = 0;

T_foc = 2 * 150 / 1.50; %(µs)

N_foc = (T_foc - UF.RxDelay) * 5

mean_RF = mean(RF,3);

figure(123131);
plot(squeeze(mean(mean_RF,2)))


%
CAXIS_RF = 'auto';
RF = single(buffer.data);
mean_RF = mean(RF,3);


RF2 = RF;
btp = brain_therapy_probe.brain_therapy_probe('512-2');
pp = btp.convert( ok_chans, 'dab', 'planning' );


coords_dab = btp.geometry(pp,:);
ok_chans_2 = ok_chans ;

ok_chans_2 = 1:320;
RF2 = RF(:,ok_chans_2);
pp = btp.convert( ok_chans_2, 'dab', 'planning' );
coords_dab = btp.geometry(pp,:);

[B,A] = butter(4,[0.7 2]/8*2);
RF_filt = filter(B,A,RF2,[],1);
RF2 = RF_filt;

%%
figure_nb = 79451213+2;

for v=-50%-0:2:20 %0:20%0:.2:8
    c = 1.5;
    all_X = (-20:.5:25);
    all_Y = (-20:.5:25);
    % all_Z = -15:.2:0;
    all_Z = -3;

    all_Y = v;
    all_X = (-20:.5:25); all_X = (-6:.2:6);
    all_Z = (-30:1:30); all_Z = (-12:.4:0);
    % % C
    all_X = (-16:.1:16);
    all_Z = (-15:.1:15);

    % large
    % Y
    all_X = (-26:.3:20);
    all_Z = -(0:.3:20);
    
    % OK Z
    dx = .2;
    all_Z = v;
    all_X = (-40:dx:40);
    all_Y = (-40:dx:40);

    % OK X
    dx = .2; dx = .2;
    all_Z = (-50:.3:0);
    all_Z = (0:40);
%     all_Z = (0:.3:45);
    all_X = 0;
    all_Y = (-50:dx:50);

%     OK Y
%     dx = .2; dx = .2;
%     all_Z = (-20:.3:0);
%     all_Y = 0;
%     all_X = (-20:dx:20);

    
%     all_X = (-20:.3:20);
%     all_Z = (-20:.3:20)+10;

%     all_X = 0%v;
%     all_Y = 0%(-10:.3:10);
%     all_Z = 0%(-10:.3:10);

    % X
%     all_X = 0;
%     all_Y = (-26:.1:26);
%     all_Z = (-50:.1:50);

    % all_X = 0;
    % all_Y = (-6:.2:6);
    % all_Z = (-12:.4:0);
    % % C
    % all_Y = (-16:.1:16);
    % all_Z = (-22:.1:0);

    my_grid = geo_points.geo_points();
    my_grid = my_grid.set_geometry( 'type','grid', 'X',all_X, 'Y',all_Y, 'Z',all_Z );

    Fe = Sequence.InfoStruct.rx(1).Freq;
    FirstSample = double(Sequence.InfoStruct.event(1).skipSamples); % +1 ?
%     tmin = FirstSample / Fe;
%     tmax = tmin + Sequence.InfoStruct.event(1).numSamples / Fe;

    C1 = Fe/c;
    tic
    rf_sum = beamforming( single(RF2), single(my_grid.points)', single(coords_dab)', single([C1 FirstSample]) );

    % v1
%     rf_sum = zeros( 1, size( my_grid.points, 1 ) );
%   
%     R = 150;
%     for ng = 1:size( my_grid.points, 1 )
%         ng
%         p1 = my_grid.points(ng,:);
%         
%         d_A = R - norm(p1);
%         ti_A = d_A * C1;
%         
%         for ne = 1:length(ok_chans)
%         
%             p2 = coords_dab(ne,:);
% 
%             d_R = norm( p1 - p2 );
%             ti_R = d_R * C1;
%             
%             ti = ti_A + ti_R;
%             
%             smpl_i = ti - FirstSample;
%             smpl = round( smpl_i );
%             rf_sum(ng) = rf_sum(ng) + RF( smpl, ne );
% %             rf_sum(ng) = rf_sum(ng) + interp1( smpl-1:smpl+1,  RF( smpl-1:smpl+1, ne ), smpl_i );
%             
%         end
%     end

    toc

%     figure
    figure(figure_nb);
    if length(all_Y) == 1 ; img = reshape( rf_sum, [ length(all_Z) length(all_X) ] ); end
    if length(all_X) == 1 ; img = reshape( rf_sum, [ length(all_Z) length(all_Y) ] ); end
    if length(all_Z) == 1 ; img = reshape( rf_sum, [ length(all_Y) length(all_X) ] ); end

%     img2 = 20*log10(abs(hilbert(img))/max(max(abs(hilbert(img)))));
    img2 = 20*log10(abs((img))/max(max(abs((img)))));

    if length(all_Y) == 1 ; imagesc( all_X, all_Z, img2 ); xlabel('X'); ylabel('Z'); axis equal; title(['Y = ' num2str(all_Y)]); end
    if length(all_X) == 1 ; 
%         a = hilbert(img)
%         img2 = 20*log10(abs((a))/max(max(abs((a)))));
        imagesc( all_Y, all_Z, img2 ); xlabel('Y'); ylabel('Z'); axis equal; title(['X = ' num2str(all_X)]); end
    if length(all_Z) == 1 ; imagesc( all_X, all_Y, img2 ); xlabel('X'); ylabel('Y'); axis equal; title(['Z = ' num2str(all_Z)]); end

    caxis( [ -20 0 ] );
    colormap gray
    colorbar
    pause(0.2)
    
end

return

%% FFT
fsamp = 5;

N_fft = 1024;
freq = [-N_fft/2:N_fft/2-1]/N_fft*fsamp;

fft_tmp = fft(RF2(350:500,:),N_fft,1);

fft_s = fftshift(sum(abs(fft_tmp),2));

figure();
plot(freq,fft_s)

%%

figure% (82362);
subplot(2,1,1)
imagesc(RF(:,:,3) + RF(:,:,4))
caxis(CAXIS_RF)
subplot(2,1,2)
imagesc(mean(RF,3))
caxis(CAXIS_RF)

%%
RFQ{1} = buffer.data(:,intersect(ids_L,ok_chans),:);
RFQ{2} = buffer.data(:,intersect(ids_R,ok_chans),:);
RFQ{3} = buffer.data(:,intersect(ids_A,ok_chans),:);
RFQ{4} = buffer.data(:,intersect(ids_P,ok_chans),:);

figure% (82362);
w = 300:400;
for n=1:4
    subplot(4,1,n)
    imagesc(RFQ{n}(w,:,3) + RFQ{n}(w,:,4))
end
for n=1:4
    subplot(4,1,n)
    imagesc(RFQ{n}(:,:,3) + RFQ{n}(:,:,4))
end
return

%% load & mean
all_RF = [];
for n=1:12
%     load( [ '~/110314_manip_echo_gel_' num2str(n) '.mat' ] )
    load( [ '~/110314_manip_echo_gel_6HC_' num2str(n) '.mat' ] )
    
    all_RF( :,:, n ) =  mean(RF,3); 
    
    mean_RF = mean(RF,3);

    figure(123131);
    plot(squeeze(mean(mean_RF,2)))
    b = squeeze(mean(mean_RF,2));
    a(:,n) = b/sqrt(sum(abs(b(200:450))));
    
    title( num2str(n) )
    
    pause()
    
end
%%
figure;
plot(a)
figure; plot(sum(abs(a),2))
figure;

tmp = mean(abs(all_RF), 3);

figure(123131);
plot( squeeze(mean(tmp,2)) )



%%

fsamp = 5;

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat
ok_chans = sort( ok_chans_dab(1:320) );
RF = buffer.data(:,ok_chans,:);


%save ~/bfo_manip1_30.mat
% 
RF(:,93,:) = 0;
RF(:,127,:) = 0;
RF(:,133,:) = 0;
RF(:,122,:) = 0;
% RF(:,257:end,:) = 0;

T_foc = 2 * 150 / 1.5; %(µs)

N_foc = (T_foc - UF.RxDelay) * 5

mean_RF = mean(RF,3);

figure;
plot(squeeze(mean(mean_RF,2)))



%%

fsamp = Sequence.InfoStruct.rx(1).Freq;

N_fft = 1024;
freq = [-N_fft/2:N_fft/2-1]/N_fft*fsamp;

fft_tmp = fft(mean(RF(:,:,:),3),N_fft,1);

fft_s = fftshift(sum(abs(fft_tmp),2));

figure();
plot(freq,fft_s)

%%


%%


c = 1.5;

Zfoc = 150;
N_T_foc = (2*Zfoc/c - 2*ImgInfo.Depth(1)/c)*fsamp






