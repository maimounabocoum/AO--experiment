function  BFStruct = lutBfocPhased(seq,ModeId,ImgInfo,NThreads)
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

    % ============================================================================ %

    % Control NumSamples
    if ( length(NSamples) > 1 )
        error('BFSRIPT:BEAMFORMINGFLAT', ['All acquisition events do not ' ...
            'correspond to the same number of acquired samples.']);
    end

    % ============================================================================ %

    % Control SkipSamples
    if ( length(SkipSamples) > 1 )
        error('BFSRIPT:BEAMFORMINGFLAT', ['All acquisition events do not ' ...
            'correspond to the same number of skipped samples.']);
    end

    % ============================================================================ %

    % Control RxIds

    for k=2:length(RxIds)

        if ( seq.InfoStruct.rx(RxIds(1)).Bandwidth ...
                ~= seq.InfoStruct.rx(RxIds(k)).Bandwidth )

            error('BFSRIPT:BEAMFORMINGFLAT', ['The acquisition decimation is ' ...
                'not the same for all the RX.']);

        elseif ( seq.InfoStruct.rx(RxIds(1)).Freq ...
                ~= seq.InfoStruct.rx(RxIds(k)).Freq )

            error('BFSRIPT:BEAMFORMINGFLAT', ['The sampling frequency is not ' ...
                'the same for all the RX.']);

        end

    end
    % ============================================================================ %
    % ============================================================================ %

    %% Compile Luts

    [Lut,LutSizeArray] = ComputeLut(seq, ModeId, ImgInfo);

    NPixLine = Lut(1).NPixLine;
    NLines = Lut(1).NLines;


    %% prepare BFStruct for execution

    NRecon = length(TxIds);
    BFStruct.Info.NThreads = NThreads ;
    BFStruct.Lut = Lut ;
    BFStruct.IQ = ones(NPixLine,NLines*NRecon,'single');

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

function [Lut,LutSizeArray] = ComputeLut(seq, ModeId, ImgInfo)

    if ImgInfo.Depth(2) < ImgInfo.Depth(1)
        error( 'BFSRIPT:BEAMFORMINGFLAT', 'The depth must be increasing.' );
    end

    % retrieve parameters from structs

    RxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(3,:));
    TxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(4,:));
    SyntAcq     = 0 ; % bmode : we never use syntAcq in this mode (but we could)
    NumSamples  = unique(seq.InfoStruct.mode(ModeId).ModeRx(1,:));
    SkipSamples = unique(seq.InfoStruct.mode(ModeId).ModeRx(2,:));

    NbReconTot = length(TxIds);

    if(NbReconTot~=ImgInfo.nbTx)
        error('BFSRIPT:BEAMFORMINGFOC', ['ImgInfo and Sequence are not '...
            'compatible (ImgInfo.nbTx)']);
    end

    % ================================================================%

    % ReconMux array for geometric position of different recons

    ReconMux = int32(min(seq.InfoStruct.rx(RxIds(1)).Channels) - 1) ;

    % ================================================================%

    % Set Probe structure
    Probe(1) = double(system.probe.NbElemts);
    Probe(2) = double(system.probe.Width);
    Probe(3) = double(system.probe.Pitch);
    Probe(4) = double(system.probe.Radius); % 0 == CompLutLinear // <0 == CompLutPhased // >0 CompLutCurvedSteering

    % Set AcqInfo Structure
    AcqInfo(1)  = 0;
    AcqInfo(2)  = seq.InfoStruct.rx(RxIds(1)).Bandwidth; % sampling decimation
    AcqInfo(3)  = system.hardware.ClockFreq / seq.InfoStruct.rx(RxIds(1)).Freq;
    AcqInfo(4)  = seq.InfoStruct.rx(RxIds(1)).Freq / 4;
    AcqInfo(5)  = SyntAcq;
    AcqInfo(6)  = ImgInfo.Depth(1); % zorigin
    AcqInfo(7)  = ImgInfo.Depth(2); % depth (not used)
    AcqInfo(8)  = 99;       % initial time (not used)
    AcqInfo(9)  = SkipSamples;
    AcqInfo(10) = NumSamples;
    AcqInfo(11) = system.hardware.NbRxChan;

    % ============================================================================ %

    % Set ReconInfo structure
    ReconInfo( 1) = 1;              % # reconstruction
    ReconInfo( 2) = 0;                              % planewave (0 for focalized)
    ReconInfo( 3) = 1 ; % nb line per tx (NLines) % not the phased array beamformer yet
    ReconInfo( 4) = 0 ; % position of the first rec line for each transmit line
    ReconInfo( 5) = 1 ;
    ReconInfo( 6) = ImgInfo.PitchPix;               % dz / lambda
    NPixLine = ( (ImgInfo.Depth(2) - ImgInfo.Depth(1)) ... % # pixels / ligne ?!
        / ReconInfo(6) / ( common.constants.SoundSpeed/1000 / AcqInfo(4) ) );
    ReconInfo( 7) = ceil(NPixLine/4)*4 ;
    ReconInfo( 8) = 0; % PeakDelay (1/2 taille pulse) ?!
    ReconInfo( 9) = 0; % PipeOffset
    ReconInfo(10) = AcqInfo(11);
    ReconInfo(11) = system.hardware.NbRxChan/2; % MaxChannelsOneSide
    ReconInfo(12) = double(seq.InfoStruct.mode(ModeId).channelSize);
    ReconInfo(13) = 1;                 % TxAlongRx
    ReconInfo(14) = 97;                % coeff pour interpolation BP (par pope)
    ReconInfo(15) = 50;                % coeff pour interpolation foot (par pope)
    ReconInfo(16) = -1 ; %ImgInfo.RxApod(1); % aperture apodisation (par pope)
    ReconInfo(17) = -1 ; %ImgInfo.RxApod(2); % slope apodisation (par pope)
    ReconInfo(18) = 1;                       % output type

    ReconInfo(19) = 1;                 % NPixSlice
    ReconInfo(20) = 0;                 % LutSizeBytes
    ReconInfo(21) = 0;                 % do not change
    ReconInfo(22) = common.constants.SoundSpeed;
    if(Probe(4)>0)
        ReconInfo(23) = 150; % mm
    end ;


    ReconInfo(24:24+system.probe.NbElemts-1) = kaiser(system.probe.NbElemts,7);

    SteeringAngle = (ImgInfo.SteeringAngleStart + ImgInfo.txPitch*(0:(NbReconTot-1)))*pi/180 ;
    xOriginAbs = (ImgInfo.xApex + ImgInfo.zApex*tan(SteeringAngle))/system.probe.Pitch;
    ReconAbsc = floor(xOriginAbs);
    ReconAbsc = min(max(0,ReconAbsc),system.probe.NbElemts-1);
    xOrigin = double(xOriginAbs - ReconAbsc) ;

    for idxThread=1:NbReconTot
        % update lut structs
        AcqInfo(1)  = SteeringAngle(idxThread);
        AcqInfo(6)  = ImgInfo.Depth(1)*cos(SteeringAngle(idxThread)); % zorigin
        ReconInfo( 4) = xOrigin(idxThread); % xorigin
        ReconInfo(20) = 0 ; % lut size 
        locReconAbsc = int32(ReconAbsc(idxThread));
        locReconDelay = double(seq.InfoStruct.tx(idxThread).tof2Focus - ImgInfo.Focus/cos(SteeringAngle(idxThread))/common.constants.SoundSpeed*1e3);
        locReconMux = int32(ReconMux(1));

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

        Lut(idxThread).NRecon   = 1;
        Lut(idxThread).NLines   = ReconInfo(3);
        Lut(idxThread).NPixLine = ReconInfo(7);
        Lut(idxThread).OutputType = ReconInfo(18);
        LutSizeArray(idxThread) = LutSize ;
    end
end