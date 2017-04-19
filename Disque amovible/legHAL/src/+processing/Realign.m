% TEST.REALIGN (PUBLIC)
%   Realign the buffer
%
%   BUFFER = TEST.REALIGN(SEQ, BUFFER) returns the realigned RF data using
%   the usse.usse variable SEQ and the buffer variable BUFFER.
%
%   Note - This function is defined as a global method of TEST package. It
%   cannot be used without the legHAL package developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/23

function PiezoBuffer = Realign(seq, buffer)

% Alignment constants
AlignOffset   = single(buffer.alignedOffset / 2);
ChannelOffset = single(seq.InfoStruct.mode(buffer.mode + 1).channelSize(1) / 2);
NbFirings     = length(seq.InfoStruct.mode(buffer.mode + 1).ModeRx(1,:));
MaxNsamples   = max(seq.InfoStruct.mode(buffer.mode + 1).ModeRx(1, :));

% Realigned buffer
Data = buffer.data(AlignOffset + 1 : AlignOffset ...
    + (ChannelOffset * system.hardware.NbRxChan));
buffer = rmfield(buffer, 'data');
Data = reshape(Data, [ChannelOffset system.hardware.NbRxChan]);

% Buffer of the realigned data
PiezoBuffer = zeros(MaxNsamples, system.probe.NbElemts, NbFirings, 'int16');

% Relignment of data regarding rx channels
Id0Samp = 0;
for k = 1 : NbFirings
    
    % Constant values
    NSamples = 1024; % number of acquired samples for event k
    NSamples = seq.InfoStruct.mode(buffer.mode + 1).ModeRx(1, k);
    RxId     = seq.InfoStruct.mode(buffer.mode + 1).ModeRx(3, k);
    RxChan   = seq.InfoStruct.rx(RxId).Channels;
    tmpIdx   = mod(RxChan - 1, system.hardware.NbRxChan) + 1;

    % Reshape data
    PiezoBuffer(1:NSamples, RxChan, k) = Data(Id0Samp + (1:NSamples), tmpIdx);
    Id0Samp  = Id0Samp + NSamples;
    
end

clear Data;

end

