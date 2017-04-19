function  BFStruct = lutColor(seq,ModeId,ImgInfo,NThreads)
    % beamforming without synthetic summation

    % ============================================================================ %
    % =========================================================================
    % === %

    %% Retrieve parameters and control their value

    % Retrieve parameters

    NSamples  = double(unique(seq.InfoStruct.mode(ModeId).ModeRx(1,:)));
    SkipSamples = double(unique(seq.InfoStruct.mode(ModeId).ModeRx(2,:)));
    TxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(4,:));
    RxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(3,:));

    NbTx = length(TxIds);
    NumberLinesPerBox = ImgInfo.NumberLinesPerBox;
    NumberBoxes = round(NbTx/ImgInfo.EnsembleLength/NumberLinesPerBox);
    
    
    if NThreads ~= NumberBoxes
        NThreads = NumberBoxes;
        disp('Force NThreads = NumberBoxes.')
    end;
    
    
    % ============================================================================ %

    % Control NumSamples
    if ( length(NSamples) > 1 )
        error('BFSRIPT:BEAMFORMING', ['All acquisition events do not ' ...
            'correspond to the same number of acquired samples.']);
    end

    % ============================================================================ %

    % Control SkipSamples
    if ( length(SkipSamples) > 1 )
        error('BFSRIPT:BEAMFORMING', ['All acquisition events do not ' ...
            'correspond to the same number of skipped samples.']);
    end

    % ============================================================================ %

    % Control RxIds

    for k=2:length(RxIds)

        if ( seq.InfoStruct.rx(RxIds(1)).Bandwidth ...
                ~= seq.InfoStruct.rx(RxIds(k)).Bandwidth )

            error('BFSRIPT:BEAMFORMING', ['The acquisition decimation is ' ...
                'not the same for all the RX.']);

        elseif ( seq.InfoStruct.rx(RxIds(1)).Freq ...
                ~= seq.InfoStruct.rx(RxIds(k)).Freq )

            error('BFSRIPT:BEAMFORMING', ['The sampling frequency is not ' ...
                'the same for all the RX.']);

        end

    end
    % ============================================================================ %
    % ============================================================================ %

    %% Compile Luts

    [Lut,LutSizeArray] = ComputeLut(seq, ModeId, ImgInfo,NThreads);

    NPixLine = Lut(1).NPixLine;
    NLines = Lut(1).NLines;


    %% prepare BFStruct for execution

    NRecon = Lut(1).NRecon;
    BFStruct.Info.NThreads = NThreads ;
    BFStruct.Lut = Lut ;
    BFStruct.IQ = 1i*ones(NPixLine,NLines*NRecon*NThreads,'single');

    NReconTemp = 0;

    for i=1:length(Lut)

        BFStruct.Lut(i).RcvOffset = NReconTemp*NSamples; % skip samples (do not forget buffer offset)
        BFStruct.Lut(i).FrameId = 0 ;
        BFStruct.Lut(i).LineId = NReconTemp*NLines ; % the first beamformed line of each thread is the last of the previous +1

        NReconTemp = NReconTemp + Lut(i).NRecon ;
    end

    BFStruct.type = 'bfoc' ;
    BFStruct.ModeID = ModeId ;

end
% ============================================================================ %
% ============================================================================ %

function [Lut,LutSizeArray] = ComputeLut(seq, ModeId, ImgInfo, NThreads)

    if ImgInfo.Depth(2) < ImgInfo.Depth(1)
        error( 'BFSRIPT:BEAMFORMINGFLAT', 'The depth must be increasing.' );
    end

    % retrieve parameters from structs

    RxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(3,:));
    TxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(4,:));
    SyntAcq     = 0 ; % bmode : we never use syntAcq in this mode (but we could)
    NumSamples  = unique(seq.InfoStruct.mode(ModeId).ModeRx(1,:));
    SkipSamples = unique(seq.InfoStruct.mode(ModeId).ModeRx(2,:));

    NbTxPerFocusedLine = max( [ length(ImgInfo.TxPolarity) length(ImgInfo.TxElemsPattern) ] );
    NbTx = length(TxIds);
    if mod( NbTx, NbTxPerFocusedLine ) ~= 0
        error('NbTx should be a multiple of NbTxPerFocusedLine')
    end
    
    NumberLinesPerBox = ImgInfo.NumberLinesPerBox;
    NumberBoxes = round(NbTx/ImgInfo.EnsembleLength/NumberLinesPerBox);
    


    
    NbReconTot = NbTx;

    Accum = 0;
    


    % ================================================================%
    % built the position of acoustic line
    JIndexBoxZero = repmat(0:(NumberLinesPerBox-1),[1 ImgInfo.EnsembleLength]);
    JIndex = [];
    for idxBox=0:(NumberBoxes-1)
        BoxOffsetLineNumber = idxBox * NumberLinesPerBox;
        JIndex = [JIndex (JIndexBoxZero + BoxOffsetLineNumber)];
    end;%idxBox
    
    
    ReconAbsc = int32(ImgInfo.FirstLinePos-1 + ImgInfo.txPitch*JIndex);
    if((max(ReconAbsc)>system.probe.NbElemts-1) || min(ReconAbsc) <0)
        error('acoustic lines are out of the probe');
    end

    % ================================================================%
    for txId = 1:length(seq.InfoStruct.tx)
        ReconDelay(txId) = double(seq.InfoStruct.tx(txId).tof2Focus);
    end

    % ================================================================%

    % ReconMux array for geometric position of different recons
    NRecon   = NbReconTot ;
    ReconMux = zeros(1, NRecon, 'int32');
    for idxRec=1:NRecon
        ReconMux(idxRec) = (min(seq.InfoStruct.rx(RxIds(idxRec)).Channels) - 1) ;
    end

    % ================================================================%

    % Set Probe structure
    Probe(1) = double(system.probe.NbElemts);
    Probe(2) = double(system.probe.Width);
    Probe(3) = double(system.probe.Pitch);
    Probe(4) = double(system.probe.Radius); % 0 == CompLutLinear // <0 == CompLutPhased // >0 CompLutCurvedSteering

    % Set AcqInfo Structure
    AcqInfo(1)  = ImgInfo.SteeringAngle;
    AcqInfo(2)  = seq.InfoStruct.rx(RxIds(1)).Bandwidth; % sampling decimation
    AcqInfo(3)  = double(system.hardware.ClockFreq) / seq.InfoStruct.rx(RxIds(1)).Freq;
    AcqInfo(4)  = seq.InfoStruct.rx(RxIds(1)).Freq / 4;
    AcqInfo(5)  = SyntAcq;
    AcqInfo(6)  = ImgInfo.Depth(1); % zorigin
    AcqInfo(7)  = ImgInfo.Depth(2); % depth (not used)
    AcqInfo(8)  = 99;       % initial time (not used)
    AcqInfo(9)  = SkipSamples;
    AcqInfo(10) = NumSamples;
    AcqInfo(11) = double(system.hardware.NbRxChan);

    % ============================================================================ %

    % Set ReconInfo structure
    ReconInfo( 1) = length(ReconAbsc);              % # reconstruction
    ReconInfo( 2) = 0;                              % planewave (0 for focalized)
    ReconInfo( 3) = ImgInfo.RxLinesPerTx ; % nb line per tx (NLines)
    ReconInfo( 4) = ImgInfo.XOrigin - (ImgInfo.txPitch-1)/2 ; % position of the first rec line for each transmit line
    ReconInfo( 5) = ImgInfo.txPitch / ImgInfo.RxLinesPerTx;               % (reconstruction line pitch per piezo)
    ReconInfo( 6) = ImgInfo.PitchPix;               % dz / lambda
    NPixLine = ( (ImgInfo.Depth(2) - ImgInfo.Depth(1)) ... % # pixels / ligne ?!
        / ReconInfo(6) / ( common.constants.SoundSpeed/1000 / AcqInfo(4) ) );
    ReconInfo( 7) = ceil(NPixLine/4)*4 ;
    ReconInfo( 8) = 0; % PeakDelay (1/2 taille pulse) ?!
    ReconInfo( 9) = 0; % PipeOffset
    ReconInfo(10) = AcqInfo(11);
    ReconInfo(11) = double(system.hardware.NbRxChan)/2; % MaxChannelsOneSide
    ReconInfo(12) = double(seq.InfoStruct.mode(ModeId).channelSize);
    ReconInfo(13) = 1;                 % TxAlongRx
    ReconInfo(14) = 97;                % coeff pour interpolation BP (par pope)
    ReconInfo(15) = 50;                % coeff pour interpolation foot (par pope)
    ReconInfo(16) = ImgInfo.RxApod(1); % aperture apodisation (par pope)
    ReconInfo(17) = ImgInfo.RxApod(2); % slope apodisation (par pope)
    ReconInfo(18) = 0;                       % output type

    if Accum == 0 
        ReconInfo(19) = 1;                 % NPixSlice
    else
        ReconInfo(19) = 0;                 % NPixSlice (automatic NPixSlice ?)
    end

    ReconInfo(20) = 0;                      % LutSizeBytes
    ReconInfo(21) = -NbTxPerFocusedLine + 1; % mode: 0: no accumulation, <0: accumulation, >0: it depends :p
    ReconInfo(22) = common.constants.SoundSpeed;
    ReconInfo(23) = 0; % arditty_slice treshold
    if(Probe(4)>0)
        ReconInfo(23) = 150; % mm
    end ;
    
    ReconInfo(24) = 0; % Sound speed layer
    ReconInfo(25) = 0; % layer_height
    ReconInfo(26) = 0; % MeanAngleSynthetic


    % ============================================================================ %
    % slip luts for multithread
    if NRecon < NThreads
        NThreads = NRecon;
    end

    NReconSingleLut = floor(NRecon/NThreads); % number of recon for the last NThreads-1 lut
    NReconLastLut = NRecon - NReconSingleLut*(NThreads-1) ; % nb recon for the first lut

    NReconSingleLut(1:NThreads-1) = NReconSingleLut ;
    NReconSingleLut(NThreads) = NReconLastLut ;

    LastIdxArray = int32(cumsum(double(NReconSingleLut)));
    FirstidxArray(1) = 1 ;
    FirstidxArray(2:NThreads) = LastIdxArray(1:(NThreads-1)) + 1 ;

    for idxThread=1:NThreads

        % update lut structs
        ReconInfo( 1) = NReconSingleLut(idxThread);
        ReconInfo(20) = 0 ;
        locReconAbsc = int32(ReconAbsc(FirstidxArray(idxThread):LastIdxArray(idxThread)));
        locReconDelay = ReconDelay(FirstidxArray(idxThread):LastIdxArray(idxThread));
        locReconMux = int32(ReconMux(FirstidxArray(idxThread):LastIdxArray(idxThread)));

        LutSize      = zeros(1, 1, 'int32');
        %     LutSizeBytes = 0;

        Status = complutRubi(Probe, AcqInfo, ReconInfo, locReconMux, locReconAbsc, ...
            locReconDelay, LutSize);
        if Status ~= 12;
            disp('Complut output status first pass')
            disp(Status)
            error('erreur de parametrage');
        end

        % Set correct Lut size in bytes.
        LutSizeBytes  = LutSize;
        ReconInfo(20) = LutSizeBytes;

        Lut(idxThread).data = zeros(1, LutSize/2, 'int16');

        % Compute LUT
        Status = complutRubi(Probe, AcqInfo, ReconInfo, locReconMux, locReconAbsc, ...
            locReconDelay, Lut(idxThread).data);

        if Status ~= 0;
            disp('Complut output status second pass')
            disp(Status)
            if Status == 12;
                LutSizeNeeded = typecast(Lut(1:2),'int32');
                disp('Needed Lut Size Bytes')
                disp(LutSizeNeeded)
            end
            error('erreur de parametrage');
        end
        
        Lut(idxThread).NRecon   = ReconInfo(1);
        Lut(idxThread).NLines   = ReconInfo(3);
        Lut(idxThread).NPixLine = ReconInfo(7);
        Lut(idxThread).OutputType = ReconInfo(18);
        LutSizeArray(idxThread) = LutSize ;
    end
end