function  BFStruct = reconSynthFlat(BFStruct, buffer,NThreads)

if BFStruct.ModeID ~= (buffer.mode + 1)
    error('wrong mode ID in buffer');
end

if ~strcmpi(BFStruct.type,'synthetic')
    error('lut are not of type ''synthetic''');
end

Nexec = floor(BFStruct.Info.NImages/NThreads);% number of exec with NThreads
NbThread2 = BFStruct.Info.NImages - Nexec*NThreads ; % number of thread for the last images;


% assuming all those variable does not depend on angle
NPixLine = BFStruct.Lut(1).NPixLine;
NLines  = BFStruct.Lut(1).NLines;
NRecon = BFStruct.Lut(1).NRecon;

for idxAngle=1:BFStruct.Info.NbAngles
    
    % parsing luts
    for idxthread=1:NThreads
            
            lutrep(idxthread).data = zeros(1, BFStruct.Lut(idxAngle).LutSize/2, 'int16');
            lutrep(idxthread).data(1:(BFStruct.Lut(idxAngle).LutSize/2)) = BFStruct.Lut(idxAngle).data(1:(BFStruct.Lut(idxAngle).LutSize/2));
            
            % create a buffer for summation
            if(~isfield(lutrep(idxthread),'IQbuffer'))
                if(BFStruct.Lut(idxAngle).OutputType==13)
                    lutrep(idxthread).IQbuffer = zeros(1, 2*NPixLine*NLines*NRecon,'single');
                end
            elseif(length(lutrep(idxthread).IQbuffer) ~=2*NPixLine*NLines*NRecon)
                lutrep(idxthread).IQbuffer = zeros(1, 2*NPixLine*NLines*NRecon,'single');
            end
    end
    
    for idxExec=1:Nexec
        for idxthread=1:NThreads
            lutrep(idxthread).FrameId = double((idxExec-1)*NThreads + idxthread -1) ;
            lutrep(idxthread).LineId = 0 ;
            %lutrep(idxthread).RcvOffset = double(buffer.alignedOffset/2) + ((idxExec-1)*NThreads + idxthread -1)*BFStruct.Info.nbRFSamplesPerImage + (idxAngle -1)*BFStruct.Info.nbRFSamplesPerFlat;
            lutrep(idxthread).RcvOffset = ((idxExec-1)*NThreads + idxthread -1)*BFStruct.Info.nbRFSamplesPerImage + (idxAngle -1)*BFStruct.Info.nbRFSamplesPerFlat;
        end
        
        reconstructRubi(lutrep,buffer,BFStruct.IQ,BFStruct.Info.DebugMode);
        
    end

    % last images to process
    if(NbThread2>0)
        lutrep(NbThread2+1:end) = [] ; % free useless luts % rq : avoir si on clear ou pas : attention ici on suppose qu'on a les .data
        % update offsets
        for idxthread=1:NbThread2
            lutrep(idxthread).FrameId = double(Nexec*NThreads + idxthread -1) ;
            lutrep(idxthread).LineId = 0 ;
            %lutrep(idxthread).RcvOffset = double(buffer.alignedOffset/2) + (Nexec*NThreads + idxthread -1)*BFStruct.Info.nbRFSamplesPerImage + (idxAngle -1)*BFStruct.Info.nbRFSamplesPerFlat;
            lutrep(idxthread).RcvOffset = (Nexec*NThreads + idxthread -1)*BFStruct.Info.nbRFSamplesPerImage + (idxAngle -1)*BFStruct.Info.nbRFSamplesPerFlat;
        end
        reconstructRubi(lutrep,buffer,BFStruct.IQ,BFStruct.Info.DebugMode);
    end
end