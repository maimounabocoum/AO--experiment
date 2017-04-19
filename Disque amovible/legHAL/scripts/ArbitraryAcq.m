% SCRIPTS.ARBITRARYACQ (PUBLIC)
%   Build and run a sequence with an ARBITRARY elusev.
%
%   Note - This function is defined as a script of SCRIPTS package. It cannot be
%   used without the legHAL package developed by SuperSonic Imagine and without
%   a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/25

%% Parameters definition

% System parameters
AixplorerIP    = '192.168.3.35'; % IP address of the Aixplorer device
ImagingVoltage = 20;             % imaging voltage [V]
ImagingCurrent = 1;              % security current limit [A]

% ============================================================================ %

% Build the arbitrary waveform

% Arbitrary variables
f0      = 7.5;     % MHz
NbCycle = 4;
Pause   = 1 / f0; % us
AcqDur  = 110; % us

% Create arbitrary waveform
SampFreq = system.hardware.ClockFreq;
NSamples = floor(SampFreq / (2*f0));

% 1st waveform
Wf1 = cos(ceil((1 : NSamples * 2* NbCycle) / NSamples) * pi);
Wf1 = [Wf1 zeros(1, round(Pause * SampFreq))];
Wf1 = - [Wf1 cos(ceil((1 : NSamples * 2) / NSamples) * pi)];

% 2nd waveform
Wf2 = 0 * cos(ceil((1 : NSamples * 2* NbCycle) / NSamples) * pi);
Wf2 = [Wf2 zeros(1, round(Pause * SampFreq))];
Wf2 = - [Wf2 cos(ceil((1 : NSamples * 2) / NSamples) * pi)];

% 3rd waveform
Wf3 = cos(ceil((1 : NSamples * 2* NbCycle) / NSamples) * pi);
Wf3 = [Wf3 zeros(1, round(Pause * SampFreq))];
Wf3 = - [Wf3 0 * cos(ceil((1 : NSamples * 2) / NSamples) * pi)];

% Set waveform
Arbitrary.Waveform(:,:,1) = Wf1;
% Arbitrary.Waveform(:,:,2) = Wf2;
% Arbitrary.Waveform(:,:,3) = Wf3;

% ============================================================================ %

% DORT parameters
Arbitrary.Delays(:,1)  = 0+0*(1:system.probe.NbElemts)'; % arbitrary delays [us]
% Arbitrary.Delays(:,2)  = 1+0*(1:system.probe.NbElemts)'; % arbitrary delays [us]
% Arbitrary.Delays(:,3)  = 2+0*(1:system.probe.NbElemts)'; % arbitrary delays [us]
Arbitrary.Pause        = 10;              % pause duration between events [us]
Arbitrary.PauseEnd     = 100;             % pause duration at the end of the elusev [us]
Arbitrary.ApodFct      = 'none';          % apodization function (none, bartlett, blackman,
                                          % connes, cosine, gaussian, hamming, hanning, welch)
Arbitrary.RxFreq       = 30;              % sampling frequency [MHz]
Arbitrary.RxDuration   = 98.2;            % acquisition duration [us]
Arbitrary.RxDelay      = 1;               % delay before acquisition [us]
Arbitrary.RxCenter     = 1;               % position of the receiving center [mm]
Arbitrary.RxWidth      = 1;               % width of the receiving window [mm]
Arbitrary.RxBandwidth  = 1;               % sampling mode (1 = 200%, 2 = 100%, 3 = 50%)
Arbitrary.FIRBandwidth = 90;              % FIR receiving bandwidth [%] - center frequency = UFTxFreq
Arbitrary.Repeat       = 1;               % repeat acquisitions
Arbitrary.TrigIn       = 0;               % enable trigger in
Arbitrary.TrigOut      = 0;               % duration of the trigger out [us]
Arbitrary.TrigOutDelay = 0;               % delay between the trigger out and the acquisition [us]
Arbitrary.TrigAll      = 0;               % enables triggers repeated for all events
Arbitrary.TGC          = 900 * ones(1,8); % TGC profile

% ============================================================================ %
% ============================================================================ %

%% DO NOT CHANGE - Create acquisition mode

try
    
    % Create the arbitrary elusev
    Elusev = elusev.arbitrary( ...
        'Waveform',     Arbitrary.Waveform, ...
        'Delays',       Arbitrary.Delays, ...
        'Pause',        Arbitrary.Pause, ...
        'PauseEnd',     Arbitrary.PauseEnd, ...
        'ApodFct',      Arbitrary.ApodFct, ...
        'RxFreq',       Arbitrary.RxFreq, ...
        'RxDuration',   Arbitrary.RxDuration, ...
        'RxDelay',      Arbitrary.RxDelay, ...
        'RxCenter',     Arbitrary.RxCenter, ...
        'RxWidth',      Arbitrary.RxWidth, ...
        'RxBandwidth',  Arbitrary.RxBandwidth, ...
        'FIRBandwidth', Arbitrary.FIRBandwidth, ...
        'TrigIn',       Arbitrary.TrigIn, ...
        'TrigOut',      Arbitrary.TrigOut, ...
        'TrigOutDelay', Arbitrary.TrigOutDelay, ...
        'TrigAll',      Arbitrary.TrigAll );

    % Create the ultrafast acquisition mode and add the arbitrary elusev
    Acmo = acmo.acmo( ...
        'ControlPts', Arbitrary.TGC, ...
        'elusev',     Elusev);

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
    Sequence           = usse.usse('TPC', TPC, 'acmo', Acmo);
    [Sequence NbAcqRx] = Sequence.buildRemote();
    
catch ErrorMsg
    errordlg(ErrorMsg.message, ErrorMsg.identifier);
end

% return

% ============================================================================ %
% ============================================================================ %

%% Do NOT CHANGE - Sequence execution

try

    % Initialize remote on systems
    Sequence = Sequence.initializeRemote('IPaddress', AixplorerIP);
    
    % Load sequence
    Sequence = Sequence.loadSequence();
    
    % Execute sequence
	clear buf;
    Sequence = Sequence.startSequence('Wait', 1);
    
    % Retrieve data
    for k = 1 : NbAcqRx
        buf(k) = Sequence.getData('Realign',1);
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
            20 * log10(single(abs(buf.data(:,:,k) + buf.data(:,:,k+1))));
    else
        TmpImg = 20 * log10(single(abs(buf.data(:,:,k))));
    end
    
    imagesc(TmpImg, [50 100]);
    pause(.1);
    
end

