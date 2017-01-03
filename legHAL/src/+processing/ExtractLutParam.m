function param = ExtractLutParam(lut,paramName)

ProbeSize = 3;
AcqInfoSize = 11;
ReconInfoSize = 22;

lutdouble = typecast(lut(1:4*(ProbeSize+AcqInfoSize+ReconInfoSize)),'double');

if(isempty(paramName)) %% extract all parameters
    
    param.Probe(1).name = 'NPiezos';
    param.Probe(2).name = 'PiezoWidth';
    param.Probe(3).name = 'PiezoPitch';
    
    param.AcqInfo(1).name = 'SteerAngle' ;
    param.AcqInfo(2).name = 'BandWidth' ;
    param.AcqInfo(3).name = 'FrequDivider';
    param.AcqInfo(4).name = 'DemodFrequ';
    param.AcqInfo(5).name = 'SyntAcq' ;
    param.AcqInfo(6).name = 'ZOrigin' ;
    param.AcqInfo(7).name = 'Depth';
    param.AcqInfo(8).name = 'InitialTime';
    param.AcqInfo(9).name = 'FirstSample';
    param.AcqInfo(10).name = 'NSamples';
    
    param.ReconInfo(1).name = 'NRecon' ;
    param.ReconInfo(2).name = 'PlaneWave' ;
    param.ReconInfo(3).name = 'NLines' ;
    param.ReconInfo(4).name = 'XOrigin' ;
    param.ReconInfo(5).name = 'LinePitch' ;
    param.ReconInfo(6).name = 'PitchPix' ;
    param.ReconInfo(7).name = 'NPixLine' ;
    param.ReconInfo(8).name = 'PeakDelay' ;
    param.ReconInfo(9).name = 'PipeOffset' ;
    param.ReconInfo(10).name = 'NChannels' ;
    param.ReconInfo(11).name = 'MaxChannelsOneSide' ;
    param.ReconInfo(12).name = 'ChannelOffset' ;
    param.ReconInfo(13).name = 'TxAlongRx' ;
    param.ReconInfo(14).name = 'BandInterp' ;
    param.ReconInfo(15).name = 'FootInterp' ;
    param.ReconInfo(16).name = 'RXApodOne' ;
    param.ReconInfo(17).name = 'RXApodZero' ;
    param.ReconInfo(18).name = 'OutputType' ;
    param.ReconInfo(19).name = 'NPixSlice' ;
    param.ReconInfo(20).name = 'LutSizeBytes' ;
    param.ReconInfo(21).name = 'Mode' ;
    param.ReconInfo(22).name = 'SoundSpeed' ;
     
    
    for k=1:ProbeSize
        param.Probe(k).value = lutdouble(k);
    end
    for k=1:(AcqInfoSize-1)
        param.AcqInfo(k).value = lutdouble(ProbeSize+k);
    end
    for k=1:ReconInfoSize
        param.ReconInfo(k).value = lutdouble(ProbeSize+AcqInfoSize+k);
    end
    
else % try to find paramName
    
    seachParam = true ;
    
    paramNameList(1).name = 'NPiezos';
    paramNameList(2).name = 'PiezoWidth';
    paramNameList(3).name = 'PiezoPitch';
    
    paramNameList(ProbeSize+1).name = 'SteerAngle' ;
    paramNameList(ProbeSize+2).name = 'BandWidth' ;
    paramNameList(ProbeSize+3).name = 'FrequDivider';
    paramNameList(ProbeSize+4).name = 'DemodFrequ';
    paramNameList(ProbeSize+5).name = 'SyntAcq' ;
    paramNameList(ProbeSize+6).name = 'ZOrigin' ;
    paramNameList(ProbeSize+7).name = 'Depth';
    paramNameList(ProbeSize+8).name = 'InitialTime';
    paramNameList(ProbeSize+9).name = 'FirstSample';
    paramNameList(ProbeSize+10).name = 'NSamples';
    paramNameList(ProbeSize+11).name = '' ; % not a parameter    
    paramNameList(ProbeSize+AcqInfoSize+1).name = 'NRecon' ;
    paramNameList(ProbeSize+AcqInfoSize+2).name = 'PlaneWave' ;
    paramNameList(ProbeSize+AcqInfoSize+3).name = 'NLines' ;
    paramNameList(ProbeSize+AcqInfoSize+4).name = 'XOrigin' ;
    paramNameList(ProbeSize+AcqInfoSize+5).name = 'LinePitch' ;
    paramNameList(ProbeSize+AcqInfoSize+6).name = 'PitchPix' ;
    paramNameList(ProbeSize+AcqInfoSize+7).name = 'NPixLine' ;
    paramNameList(ProbeSize+AcqInfoSize+8).name = 'PeakDelay' ;
    paramNameList(ProbeSize+AcqInfoSize+9).name = 'PipeOffset' ;
    paramNameList(ProbeSize+AcqInfoSize+10).name = 'NChannels' ;
    paramNameList(ProbeSize+AcqInfoSize+11).name = 'MaxChannelsOneSide' ;
    paramNameList(ProbeSize+AcqInfoSize+12).name = 'ChannelOffset' ;
    paramNameList(ProbeSize+AcqInfoSize+13).name = 'TxAlongRx' ;
    paramNameList(ProbeSize+AcqInfoSize+14).name = 'BandInterp' ;
    paramNameList(ProbeSize+AcqInfoSize+15).name = 'FootInterp' ;
    paramNameList(ProbeSize+AcqInfoSize+16).name = 'RXApodOne' ;
    paramNameList(ProbeSize+AcqInfoSize+17).name = 'RXApodZero' ;
    paramNameList(ProbeSize+AcqInfoSize+18).name = 'OutputType' ;
    paramNameList(ProbeSize+AcqInfoSize+19).name = 'NPixSlice' ;
    paramNameList(ProbeSize+AcqInfoSize+20).name = 'LutSizeBytes' ;
    paramNameList(ProbeSize+AcqInfoSize+21).name = 'Mode' ;
    paramNameList(ProbeSize+AcqInfoSize+22).name = 'SoundSpeed' ;
    
    k= 0 ;
    while(seachParam && k<length(paramNameList))
        k = k+1 ;
        if(strcmpi(paramNameList(k).name,paramName))
            seachParam = false ;
            param = lutdouble(k);
        end
       
        
    end
    if(seachParam)
        s = ['parameter ''' paramName ''' not found'];
        error(s);
    end
    
end
  