function buf_out = serializeData( obj, buf )

PiezoBuffer = buf.RFdata;

% Alignment constants
AlignOffset   = int32( buf.alignedOffset / 2 );
ChannelOffset = ...
    int32( obj.RemoteStruct.mode(buf.mode + 1).channelSize(1) / 2 );
NbFirings     = ...
    length( obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1,:) );


Id0Samp = 0;
for k = 1 : NbFirings

    % Constant values
    NSamples = obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1, k);
    RxId     = obj.RemoteStruct.mode(buf.mode + 1).ModeRx(3, k);

    % Reshape data
    tmpIdx = mod( obj.InfoStruct.rx(RxId).Channels - 1, system.hardware.NbRxChan) + 1 ;
    Data( Id0Samp + (1:NSamples), tmpIdx ) = PiezoBuffer(1:NSamples, obj.InfoStruct.rx(RxId).Channels, k) ;
    Id0Samp  = Id0Samp + NSamples;

end

Data = [ Data ; zeros( [ ChannelOffset-size(Data,1) 128 ] ) ];
Data = reshape( Data, [1 ChannelOffset * system.hardware.NbRxChan] );

% todo: make it longer ?
buf_out.data ( AlignOffset + 1 : AlignOffset + (ChannelOffset * system.hardware.NbRxChan) ) = Data;
buf_out.data( end : size(buf.data,2) ) = 0;

buf_out.alignedOffset = buf.alignedOffset;
buf_out.mode = buf.mode;


