function buffer = CreateDebugBuff2(Sequence,NbAcqRx)

for k=1:NbAcqRx
    bufferSize = Sequence.InfoStruct.mode(k).channelSize*system.hardware.NbRxChan ;
    buffer(k).alignedOffset = 0 ;
    buffer(k).data = int16(2048*(rand(bufferSize,1)-0.5));
    buffer(k).mode = k-1;
end