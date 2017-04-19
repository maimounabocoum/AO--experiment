% cd ../remote/
% addPathRemote
% cd ../src

%% Parameters 
%clear all; clear classes

debugMode = 0 ;
% System parameters
AixplorerIP = '192.168.3.1'; % IP address of Aixplorer
% AixplorerIP = '192.168.1.217';

f0 = 0.9;

HIFU_Duration_wanted = 5; % s

TR = 40;
TA_per_img = 4.7;
US_Duration = 25.65; % ms (Max affiche: 25.71)
US_Duration = 31.5; % ms
NB_img_tir = round( HIFU_Duration_wanted / TA_per_img );
HIFU_Duration = NB_img_tir*TA_per_img * 1e3; % ms

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

% steering
tof_dab = clelia_steer( 8, 0, 0, 1.5,  'tuccirm' )
phi_dab = mod(tof_dab, 1/f0)*1e-6 * f0*1e6 * 2*pi ;

phi_dab = 0; %( head_phases_dab - min(head_phases_dab) ) ;
max( phi_dab )

% try
    % Build the HIFU elusev (for help type: doc elusev.hifu)
    HIFU = elusev.hifu( ...
        'TwFreq', f0, ...
        'TwDuration', US_Duration * 1e3, ... µs 
        'TxElemts', [ 1:64 256:319 ], ... sort(ok_chans_dab), ...
        'Phase', 0*(0:127)/128*2*pi, ...phi_dab(sort(ok_chans_dab))*0, ...
        'DutyCycle', 1, ...
        'RxFreq', 1, ...
        'RxDuration', 0, ...
        'RxElemts', 0, ...
        'TrigIn', 0, ...
        'TrigOut', 1e-3, ...
        'TrigAll', 0, ...
        'Repeat', round( HIFU_Duration / US_Duration ), ... 64 * 8 * 2, ...
...        'Pause', 1e3, ...
        debugMode );

    % Create ACMO object
    Acmo = acmo.acmo( ...
        'Duration', 0, ...
        'ControlPts', [1 1 1 1 1 1]*960, ...
        'Repeat', 1, ...
        'elusev', HIFU, ...
        debugMode );
    
    % Create  and build the sequence
    Sequence           = usse.usse( 'acmo', Acmo );
    [Sequence NbAcqRx] = Sequence.buildRemote( );
    
 
% catch ErrorMsgl
%     errordlg(ErrorMsg.message, ErrorMsg.identifier);
% end

% ============================================================================ %
% ============================================================================ %

%% Do NOT CHANGE - Sequence execution

try
    
    if(debugMode)
        buffer = test.CreateDebugBuff2(Sequence,NbAcqRx);
    else
        % Initialize remote on systems
        Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP);
        
        % Load sequence
        Sequence = Sequence.loadSequence();
        
        % Execute sequence
        clear buffer;
        disp( [ 'Total HIFU_Duration : ' num2str( HIFU_Duration/1e3 ) ' s' ] )
        disp( [ 'US_Duration / TR : ' num2str( US_Duration/TR ) ] )
        disp('Press a key to start sequence')
        pause
        Sequence = Sequence.startSequence('Wait', 0);
        
        % Retrieve data
%         buffer = Sequence.getData('Realign',0);
        
        % Stop sequence
        Sequence = Sequence.stopSequence('Wait', 1);
        
    end
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% ============================================================================ %
