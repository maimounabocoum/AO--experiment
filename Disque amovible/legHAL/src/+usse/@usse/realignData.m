function PiezoBuffer = realignData( obj, buf )

% Alignment constants
AlignOffset   = int32( buf.alignedOffset / 2 );
ChannelOffset = ...
    int32( obj.RemoteStruct.mode(buf.mode + 1).channelSize(1) / 2 );
NbFirings     = ...
    length( obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1,:) );

% Realigned buffer
Data = buf.data( AlignOffset + 1 ...
    : AlignOffset + (ChannelOffset * system.hardware.NbRxChan) );
buf = rmfield(buf, 'data');

Data = reshape( Data, [ChannelOffset system.hardware.NbRxChan] );

% Buffer of the realigned data
PiezoBuffer = zeros( ...
    max(obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1,:)), ...
    system.probe.NbElemts, NbFirings, 'int16' );

% Relignment of data regarding rx channels
Id0Samp = 0;
for k = 1 : NbFirings

    % Constant values
    NSamples = obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1, k);
    RxId     = obj.RemoteStruct.mode(buf.mode + 1).ModeRx(3, k);

    % Reshape data
    tmpIdx = mod( obj.InfoStruct.rx(RxId).Channels - 1, system.hardware.NbRxChan) + 1 ;
    PiezoBuffer(1:NSamples, obj.InfoStruct.rx(RxId).Channels, k) = ...
        Data( Id0Samp + (1:NSamples), tmpIdx );
    Id0Samp  = Id0Samp + NSamples;

end