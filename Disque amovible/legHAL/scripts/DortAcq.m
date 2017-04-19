% SCRIPTS.DORTACQ (PUBLIC)
%   Build and run a sequence with a DORT elusev.
%
%   Note - This function is defined as a script of SCRIPTS package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/25

%% Parameters definition

% System parameters
AixplorerIP    = '192.168.1.31'; % IP address of the Aixplorer device
ImagingVoltage = 20;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Build the arbitrary waveform
Wf.f0      = 7.5;     % MHz
Wf.NbCycle = 4;
Wf.Pause   = 1 / Wf.f0; % us

% Create arbitrary waveform
Wf.SampFreq = system.hardware.ClockFreq;
Wf.NSamples = floor(Wf.SampFreq / (2*Wf.f0));

% Waveform
Wf.waveform = cos(ceil((1 : Wf.NSamples * 2* Wf.NbCycle) / Wf.NSamples) * pi);
Wf.waveform = [Wf.waveform zeros(1, round(Wf.Pause * Wf.SampFreq))];
Wf.waveform = - [Wf.waveform cos(ceil((1 : Wf.NSamples * 2) / Wf.NSamples) * pi)];

% ============================================================================ %

% DORT parameters
Dort.Waveform     = Wf.waveform;     % arbitrary waveform
Dort.Pause        = 10;              % pause duration [us]
Dort.PauseEnd     = 100;             % pause duration [us]
Dort.DutyCycle    = 0.5;             % duty cycle [0, 1]
Dort.RxFreq       = 30;              % sampling frequency [MHz]
Dort.RxDuration   = 8.5;             % acquisition duration [us]
Dort.RxDelay      = 1;               % delay before acquisition [us]
Dort.RxBandwidth  = 1;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
Dort.FIRBandwidth = 90;              % FIR receiving bandwidth [%] - center frequency = UFTxFreq
Dort.Repeat       = 1;               % repeat acquisitions
Dort.TrigIn       = 0;               % enable trigger in
Dort.TrigOut      = 0;               % duration of the trigger out
Dort.TrigOutDelay = 0;               % delay between the trigger out and the acquisition
Dort.TrigAll      = 0;               % enables triggers repeated for all events
Dort.TGC          = 900 * ones(1,8); % TGC profile

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Create acquisition mode

try
    
    % Create the DORT elusev
    Elusev = elusev.dort( ...
        'Waveform',     Dort.Waveform, ...
        'Pause',        Dort.Pause, ...
        'PauseEnd',     Dort.PauseEnd, ...
        'DutyCycle',    Dort.DutyCycle, ...
        'RxFreq',       Dort.RxFreq, ...
        'RxDuration',   Dort.RxDuration, ...
        'RxDelay',      Dort.RxDelay, ...
        'RxBandwidth',  Dort.RxBandwidth, ...
        'FIRBandwidth', Dort.FIRBandwidth, ...
        'TrigIn',       Dort.TrigIn, ...
        'TrigOutDelay', Dort.TrigOut, ...
        'TrigOutDelay', Dort.TrigOutDelay, ...
        'TrigAll',      Dort.TrigAll, ...
        'Repeat',       Dort.Repeat);
    
    % Create the generic acquisition mode and add the DORT elusev
    Acmo = acmo.acmo( ...
        'ControlPts', Dort.TGC, ...
        'Elusev',     Elusev);

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
    
    % Create and build the sequence
    Sequence           = usse.usse('TPC', TPC, 'ACMO', Acmo);
    [Sequence NbAcqRx] = Sequence.buildRemote();
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% ============================================================================ %

%% Do NOT CHANGE - Sequence execution

try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP);
    
    % Load sequence
    Sequence = Sequence.loadSequence();
    
    % Execute sequence
    clear buffer;
    Sequence = Sequence.startSequence('Wait', 0);
    
    % Retrieve data
    for k = 1 : NbAcqRx
        buffer(k) = Sequence.getData('Realign',1);
    end
    
    % Stop sequence
    Sequence = Sequence.stopSequence('Wait', 1);
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% ============================================================================ %
% ============================================================================ %

%% Do NOT CHANGE - RF data display

if ( length(Sequence.InfoStruct.rx) == 2 )
    dk = 2;
else
    dk = 1;
end

for k = 1 : dk : length(Sequence.InfoStruct.event)
    
    if ( dk == 2 )
        TmpImg = ...
            20 * log10(single(abs(buffer.data(:,:,k) + buffer.data(:,:,k+1))));
    else
        TmpImg = 20 * log10(single(abs(buffer.data(:,:,k))));
    end
    
    imagesc(TmpImg, [50 100]);
    pause(.1);
    
end

