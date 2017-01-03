addpath('C:\AcoustoOptique\AcqTiPie\SampleCodes');


if exist('Scp','var')
    clear Scp
end
if exist('LibTiePie','var')
    clear LibTiePie
end

LibTiePieNeeded
LibTiePie.List.Update

%Open communication
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

% Set Acq Parameters
Scp.MeasureMode=MM.BLOCK;
Scp.SampleFrequency=50e6;
Scp.RecordLength=4000000;
Scp.SegmentCount=1;

%Enable Scp chanels
for i=1:Scp.ChannelCount
    Scp.Channels(i).Enabled=true;
    Scp.Channels(i).TriggerEnabled=false;
    Scp.Channels(i).Coupling=CK.ACV;
    Scp.Channels(i).Range=0.8;
end

Scp.TriggerTimeOut=100e-3;

Scp.Channels(2).TriggerEnabled = true;
Scp.Channels(2).TriggerKind = TK.RISING;
%Scp.Channels(2).TriggerTime = 1;

Scp.Start;
for ii=1:Scp.SegmentCount
    while ~( Scp.IsDataReady || Scp.IsRemoved )
        pause( 1e-8 ) % 10 ns delay, try later.
    end
    tic
    arData = Scp.Data(:,1);
    toc
end

figure(3)
plot(arData)

% clear Scp
% clear LibTiePie