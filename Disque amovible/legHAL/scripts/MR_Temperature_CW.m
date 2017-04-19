% cd ../remote/
% addPathRemote
% cd ../src

%% Parameters 
%clear all; clear classes

debugMode = 0 ;
% System parameters
AixplorerIP = '192.168.3.1'; % IP address of Aixplorer

HIFU_Duration_wanted = 16; % s
TA_per_img = 3.4; % s
% TA_per_img = 4.7; % s
Trig_US = 'first'; % each | first

if strcmp( Trig_US, 'each' )
    US_Duration = TA_per_img*1e3; % ms
    NB_img_tir = round( HIFU_Duration_wanted / TA_per_img )
elseif strcmp( Trig_US, 'first' )
    US_Duration = HIFU_Duration_wanted * 1e3;
    NB_img_tir = 1
end
HIFU_Duration = NB_img_tir*US_Duration / 1e3 % s

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

% phi_dab = ( head_phases_dab - min(head_phases_dab) ) ;
% max( phi_dab )

% try
    % Build the HIFU elusev (for help type: doc elusev.hifu)
    HIFU = elusev.hifu( ...
        'TwFreq', 0.9, ...
        'TwDuration', US_Duration * 1e3, ... µs 
        'TxElemts', sort(ok_chans_dab), ...
        'Phase', 0, ... %phi_dab(sort(ok_chans_dab))*0, ...
        'DutyCycle', 1, ...
        'RxFreq', 1, ...
        'RxDuration', 0, ...
        'RxElemts', 0, ...
        'TrigIn', 1, ...
        'TrigOut', 1e-3, ...
        'TrigAll', 0, ...
        'Repeat', NB_img_tir, ... 64 * 8 * 2, ...
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
        disp( [ 'Total US_Duration : ' num2str( US_Duration/1e3 ) ' s' ] )
%         disp( [ 'US_Duration / TR : ' num2str( US_Duration/TR ) ] )
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
