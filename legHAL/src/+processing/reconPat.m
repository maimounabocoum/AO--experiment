function BFStruct = reconPat(BFStruct, buffer)

if(BFStruct.ModeID ~= (buffer.mode + 1) )
    error('wrong mode ID in buffer');
end

if(~strcmpi(BFStruct.type,'PAT'))
    error('lut are not of type ''PAT''');
end

for n = 1 : BFStruct.Info.Nexec % nb of pope execd
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start NThreads 
    for k = 1 : BFStruct.Info.NThreads
        
        %BFStruct.Lut(k).RcvOffset = double(buffer.alignedOffset/2) + (n-1)*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(k).RcvOffset = (n-1)*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(k).FrameId = k-1 + (n-1)*BFStruct.Info.NThreads ;
        BFStruct.Lut(k).LineId = 0 ;
    end
    
    % beamforming
    
    reconstructRubi(BFStruct.Lut,buffer,BFStruct.IQ,BFStruct.Info.DebugMode);
    
end

% last images

Nexec2 = BFStruct.Info.NImages - double(BFStruct.Info.Nexec*BFStruct.Info.NThreads);
if Nexec2 > 0
    
    for k = 1 : Nexec2
        
        %BFStruct.Lut(k).RcvOffset = double(buffer.alignedOffset/2) + Nexec*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(k).RcvOffset = Nexec2 * BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(k).FrameId = k -1 + Nexec2 * BFStruct.Info.Nexec * BFStruct.Info.NThreads ;
        BFStruct.Lut(k).LineId = 0 ;
    end
    
    % bf
    reconstructRubi(BFStruct.Lut(1:Nexec2),buffer,BFStruct.IQ,BFStruct.Info.DebugMode);
    
end