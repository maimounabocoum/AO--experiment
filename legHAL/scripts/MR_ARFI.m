% cd ../remote/
% addPathRemote
% cd ../src

%% 11V
%% tir sur 18/19
%% 20/21 : decal vers F
%% 22/23: ref de 20/21

%% 13 V
%% 24/25: idem

%% 26/27: sag
%% 28/29: idem ref

%% 30/31: 15V
%% 32/33: ref




%%
% 3: loca cor
% 5: 13 V 
% 7: ref
% 9: 17 V 
% 11: 20 V
% 13: ref
% 15: loca 3D sag
% 16: 20 V, decal 7mm vers H / 11
% 18: idem ref
% 20: anat
% 22: 20 V, decal 7mm vers H / 11
% 24: idem ref
% 27: 20 V, decal 7mm vers P / 11
% 29: idem ref

%% 120803

% 4 arfi ref

%% 120817
% HTZ2, PTY3, PRY15, 
% 23 ref T2
% 11h50 bulles + US
% 11h55 dota
% 25 avec ballon
% 26 sans ballon (meilleur image)
% 
% 31 T2 *

%% 120829


%% Parameters 
%clear all; clear classes

debugMode = 0 ;
% System parameters
AixplorerIP = '192.168.3.1'; % IP address of Aixplorer

Repeat = 80*2;

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

f0 = 0.9;
addpath ~/svn/trunk/therapy/research/matlab_codes/functions/


%phi_dab = ( head_phases_dab - min(head_phases_dab) ) ;
% max( phi_dab )

load /home/labo/Desktop/Manips/ICM/110201/110201_ok_chans.mat

% try
    % Build the HIFU elusev (for help type: doc elusev.hifu)
    E_HIFU = elusev.hifu( ...
        'TwFreq', f0, ...
        'TwDuration', 8e3, ... 10e3, ...
        'TxElemts', ok_chans_dab, ...
        'Phase', 0, ...
        'DutyCycle', 0, ...
        'RxFreq', 1, ...
        'RxDuration', 0, ...
        'RxElemts', 0, ...
        'TrigIn', 1, ... 1, ...
        'TrigOut', 1e-3, ...
        'TrigAll', 0, ...
        'Repeat', Repeat, ... 80 * 2, ... 64 * 8 * 2, ...
...        'Pause', 1e3, ...
        debugMode );
    
%     E_Pause = elusev.pause( 'Pause', Pause_duration );

    % Create ACMO object
    Acmo = acmo.acmo( ...
        'Duration', 0, ...
        'ControlPts', [1 1 1 1 1 1]*960, ...
        'Repeat', 1, ...
        'elusev', E_HIFU, ...
        debugMode );
    
    % Create  and build the sequence
    Sequence           = usse.usse( 'acmo', Acmo, 'Popup',0 );
%     Sequence           = Sequence.selectHardware() 
    [Sequence NbAcqRx] = Sequence.buildRemote( );
    
%clear all_phi_zz ; for n=1:length( Sequence.InfoStruct.tx ); all_phi_zz(n,:) = Sequence.InfoStruct.tx(n).Delays + pi*n/2 ; end ; figure(7235262); plot( all_phi_zz' ); legend

%figure(124652); plot( [ Sequence.InfoStruct.event(:).duration ], 'o' )

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
        disp( [ 'US Emmission on ' num2str( length(ok_chans_dab) ) ' chans' ] )
        disp('Press a key to start sequence')
        pause
        Sequence = Sequence.startSequence('Wait', 1);
        
        % Retrieve data
%         buffer = Sequence.getData('Realign',0);
        
        % Stop sequence
        
        Sequence = Sequence.stopSequence('Wait', 0);
        
    end

catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% ============================================================================ %

% 27 push bord sag
% 29 ref
