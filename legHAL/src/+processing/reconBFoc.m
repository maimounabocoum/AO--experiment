function BFStruct = reconBFoc(BFStruct, buffer)


if BFStruct.ModeID ~= ([buffer.mode] + 1)
    error('wrong mode ID in buffer');
end

if ~strcmpi(BFStruct.type,'bfoc')
    error('lut are not of type ''bfoc''');
end

% update RF offset (TODO:put that in reconstruct directly!)

NReconTemp = 0;
NSamples = processing.ExtractLutParam( BFStruct.Lut(1).data, 'NSamples' );
NLines = BFStruct.Lut(1).NLines;
for i=1:length(BFStruct.Lut)
    
    BFStruct.Lut(i).RcvOffset = NReconTemp*NSamples ; %+ double(buffer.alignedOffset/2) ; 
    BFStruct.Lut(i).FrameId = 0 ;
    BFStruct.Lut(i).LineId = NReconTemp*NLines ; % the first beamformed line of each thread is the last of the previous + 1
    
    NReconTemp = NReconTemp + BFStruct.Lut(i).NRecon ;
end

% beamforming
reconstructRubi( BFStruct.Lut, buffer, BFStruct.IQ, BFStruct.Info.DebugMode );

% for k = 1 : BFStruct.Info.NThreads
%     BFStruct.Lut(k).RcvOffset = BFStruct.Lut(k).RcvOffset - double(buffer.alignedOffset/2) ;
% end
