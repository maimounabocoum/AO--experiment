function Scp=InitTiePie(varargin)
% acousto-optic image with a TiePie HandyScope HS5 acq. card
% 03/04/2015 version

addpath('SampleCodes\');

%% Get parameters for acquisition

if isempty(varargin)
    % Default acquisition parameters
    SamplingRate    = 40e6;
    NTrig           = 1;
    NPoints         = 2000;
    Range           = 0.2;
    
elseif isstruct(varargin{1})
    % US acquisition parameters
    SamplingRate    = varargin{1}.SamplingRate*1e6;
    NPoints         = varargin{1}.Prof*1e-3/common.constants.SoundSpeed*SamplingRate;
    NTrig           = round(varargin{1}.ScanLength/system.probe.Pitch);
    Range           = varargin{1}.Range;
    
else
    %use as classical function
    if nargin<4
        error('Not enough parameters : AcqTiePie(NPoints,NTrig,SamplingRate,Range')
    else
        NPoints      =varargin{1};
        NTrig        =varargin{2};
        SamplingRate =varargin{3};
        Range        =varargin{4};
    end
    
end


% ======================================================================= %
%% Initializtion of the scope

if ~exist('LibTiePie','var')
    LibTiePieNeeded
end

LibTiePie.List.Update

if ~LibTiePie.List.Count
    error('No device detected')
else
    for k=0:LibTiePie.List.Count-1
        if LibTiePie.List.DeviceCanOpen(IDKIND.INDEX , 0, DEVICETYPE.OSCILLOSCOPE)
            Scp = LibTiePie.List.OpenOscilloscope( IDKIND.INDEX , 0 );
            break
        end
        error('No osc. device detected');
    end
end

% ======================================================================= %
%% Set Scope Parameters

% Set Acq Parameters
Scp.MeasureMode     = MM.BLOCK;
Scp.SampleFrequency = SamplingRate;
Scp.RecordLength    = NPoints;

if NTrig>Scp.SegmentCountMax
    warning(['Trigger count is too high !! => NTrig was set to max value : ' ...
        num2str(Scp.SegmentCountMax) ' trig'])
    Scp.SegmentCount    = Scp.SegmentCountMax;
else
    Scp.SegmentCount    = NTrig;
end

%Enable Scp chanels
for i=1:Scp.ChannelCount
    Scp.Channels(i).Enabled         = true;
    Scp.Channels(i).TriggerEnabled  = false;
    Scp.Channels(i).Coupling        = CK.ACV;
    Scp.Channels(i).Range           = Range;
end

Scp.TriggerTimeOut=100e-3;
Scp.Channels(2).TriggerEnabled = true;
Scp.Channels(2).TriggerKind = TK.RISING;