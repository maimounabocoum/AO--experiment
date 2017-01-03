function BFStruct = reconFlat(BFStruct, buffer)

if(BFStruct.ModeID ~= (buffer.mode + 1) )
    error('wrong mode ID in buffer');
end

if(~strcmpi(BFStruct.type,'flat'))
    error('lut are not of type ''flat''');
end

for n = 1 : BFStruct.Info.Nexec % nb of pope execd
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % start NThreads
    
    progression = ((n-1)*BFStruct.Info.NThreads)/BFStruct.Info.NbAngles ;
    firstAngle = round((progression-floor(progression))*BFStruct.Info.NbAngles +1)  ; % current angle
    
    for k = 1 : BFStruct.Info.NThreads
        
        progression = (k -1 + (n-1)*BFStruct.Info.NThreads)/BFStruct.Info.NbAngles ;
        currentImage = floor(progression)+1 ; % current synthetic image
        currentAngle = round((progression-floor(progression))*BFStruct.Info.NbAngles +1) ; % current angle
        
        %BFStruct.Lut(firstAngle+k-1).RcvOffset = double(buffer.alignedOffset/2) + (n-1)*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(firstAngle+k-1).RcvOffset = (n-1)*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(firstAngle+k-1).FrameId = double((currentImage-1)*BFStruct.Info.NbAngles + currentAngle-1) ;
        BFStruct.Lut(firstAngle+k-1).LineId = 0 ;
    end
    
    % beamforming
    
    reconstructRubi( BFStruct.Lut( firstAngle:(firstAngle+BFStruct.Info.NThreads-1)), buffer, BFStruct.IQ, BFStruct.Info.DebugMode );
    
end

% last images

Nexec2 = BFStruct.Info.NImages*BFStruct.Info.NbAngles - double(BFStruct.Info.Nexec*BFStruct.Info.NThreads);
if(Nexec2>0)
    progression = (BFStruct.Info.Nexec*BFStruct.Info.NThreads)/BFStruct.Info.NbAngles ;
    firstAngle = round((progression-floor(progression))*BFStruct.Info.NbAngles +1)  ;% current angle
    
    for k = 1 : Nexec2
        progression = (k -1 + BFStruct.Info.Nexec*BFStruct.Info.NThreads)/BFStruct.Info.NbAngles ;
        currentImage = floor(progression)+1 ; % current synthetic image
        currentAngle = round((progression-floor(progression))*BFStruct.Info.NbAngles +1) ; % current angle
        
        %BFStruct.Lut(firstAngle+k-1).RcvOffset = double(buffer.alignedOffset/2) + BFStruct.Info.Nexec*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(firstAngle+k-1).RcvOffset = BFStruct.Info.Nexec*BFStruct.Info.skipSamplePerExec + (k-1)*BFStruct.Info.nbRFSamplePerFlat ;
        BFStruct.Lut(firstAngle+k-1).FrameId = double((currentImage-1)*BFStruct.Info.NbAngles + currentAngle-1) ;
        BFStruct.Lut(firstAngle+k-1).LineId = 0 ;
    end
    
    % bf
    reconstructRubi(BFStruct.Lut(firstAngle:(firstAngle+Nexec2-1)),buffer,BFStruct.IQ,BFStruct.Info.DebugMode);
    
end