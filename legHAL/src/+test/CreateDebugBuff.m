function buffer = CreateDebugBuff(nbChannel,channelOffset,nbRFFrame,NbSamples,mode)

%% create debug buffer for beamforming
buffer.mode = mode ;
buffer.data = zeros(nbRFFrame*channelOffset,1,'int16');
buffer.alignedOffset = 0 ;

% bmode buffer

z0 = floor(20*NbSamples/100) +1 ;
z1 = floor(30*NbSamples/100) ;

for rfIdx = 1 : nbRFFrame
    
    if(mod(rfIdx,2)==0)
        for chan=1:nbChannel
            first = z0 + (chan-1)*channelOffset + NbSamples*(rfIdx-1);
            last = z1 + (chan-1)*channelOffset + NbSamples*(rfIdx-1);
            buffer.data(first:last) = int16(2048*(ones(last-first+1,1)-0.5)) ;
        end
    end
end



