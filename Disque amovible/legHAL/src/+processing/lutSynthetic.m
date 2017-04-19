function  BFStruct = lutSynthetic(seq,ModeId,ImgInfo)
    % Beamforming with summation

    % ============================================================================ %
    % ============================================================================ %

    %% Retrieve parameters and control their value

    % Retrieve parameters

    NSamples    = double( unique( seq.InfoStruct.mode(ModeId).ModeRx(1,:) ) );
    SkipSamples = double( unique( seq.InfoStruct.mode(ModeId).ModeRx(2,:) ) );
    TxIds       = unique( seq.InfoStruct.mode(ModeId).ModeRx(4,:) );
    RxIds       = unique( seq.InfoStruct.mode(ModeId).ModeRx(3,:) );

    % ============================================================================ %

    % Control NumSamples
    if length(NSamples) > 1
        error('BFSRIPT:BEAMFORMINGFLAT', ['All acquisition events do not ' ...
            'correspond to the same number of acquired samples.']);
    end

    % ============================================================================ %

    % Control SkipSamples
    if length(SkipSamples) > 1
        error('BFSRIPT:BEAMFORMINGFLAT', ['All acquisition events do not ' ...
            'correspond to the same number of skipped samples.']);
    end

    % ============================================================================ %

    % Control RxIds
    if length(RxIds) == 2

        if seq.InfoStruct.rx(RxIds(1)).Bandwidth ...
                ~= seq.InfoStruct.rx(RxIds(2)).Bandwidth

            error('BFSRIPT:BEAMFORMINGFLAT', ['The acquisition decimation is ' ...
                'not the same for the two RX.']);

        elseif seq.InfoStruct.rx(RxIds(1)).Freq ...
                ~= seq.InfoStruct.rx(RxIds(2)).Freq

            error('BFSRIPT:BEAMFORMINGFLAT', ['The sampling frequency is not ' ...
                'the same for the two RX.']);

        end

        SyntAcq = 1;

    elseif length(RxIds) == 1

        SyntAcq = 0;

    else

        error('BFSRIPT:BEAMFORMINGFLAT', ['There are more than two RX. The ' ...
            'beamformer is not designed for distinct acquisition strategies.']);

    end

    % ============================================================================ %
    % ============================================================================ %

    %% Compile Luts

    Lut = ComputeLut(seq, ModeId, ImgInfo);

    % ============================================================================ %
    % ============================================================================ %


    NbAngles = length(TxIds);

    % assuming all those variable does not depend on angle
    NPixLine = Lut(1).NPixLine;
    NLines  = Lut(1).NLines;
    NRecon = Lut(1).NRecon;

    if ( SyntAcq )
        NSamples = 2*NSamples ;
    end

    NImages = double(length(seq.InfoStruct.mode(ModeId).ModeRx(3,:)) ...
        / (length(TxIds) * (1 + SyntAcq)));


    % outputs of this function

    BFStruct.IQ = sqrt(-1)*ones(NPixLine,NLines*NRecon,NImages,'single'); % memory alloc

    BFStruct.type = 'synthetic' ;
    BFStruct.ModeID = ModeId ;
    BFStruct.Info.nbRFSamplesPerFlat = double(NSamples) ;
    BFStruct.Info.nbRFSamplesPerImage = double(NbAngles*NSamples) ;
    BFStruct.Info.NImages = double(NImages) ;
    BFStruct.Info.NbAngles = double(NbAngles);
    BFStruct.Lut = Lut ;

end
% ============================================================================ %
% ============================================================================ %

function [Lut,LutSizeArray] = ComputeLut( seq, ModeId, ImgInfo )

    if ImgInfo.Depth(2) < ImgInfo.Depth(1)
        error( 'BFSRIPT:BEAMFORMINGFLAT', 'The depth must be increasing.' );
    end
    
    RxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(3,:));
    TxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(4,:));
    SyntAcq     = ( length(RxIds) == 2 );
    NumSamples  = unique(seq.InfoStruct.mode(ModeId).ModeRx(1,:));
    SkipSamples = unique(seq.InfoStruct.mode(ModeId).ModeRx(2,:));

    for k = 1 : length(TxIds)

        txId      = TxIds(k);
        FlatAngle = double(mean(atan(diff(seq.InfoStruct.tx(txId).Delays * 1e-3) ...
            * common.constants.SoundSpeed / (system.probe.Pitch)))); % strange concept, TODO: get that from user input instead ?

        % Set Probe structure
        Probe(1) = double(system.probe.NbElemts);
        Probe(2) = double(system.probe.Width);
        Probe(3) = double(system.probe.Pitch);
        Probe(4) = double(system.probe.Radius); % 0 == CompLutLinear // <0 == CompLutPhased // >0 CompLutCurvedSteering

        % Set AcqInfo Structure
        AcqInfo(1)  = FlatAngle;
        AcqInfo(2)  = seq.InfoStruct.rx(RxIds(1)).Bandwidth; % sampling decimation
        AcqInfo(3)  = system.hardware.ClockFreq / seq.InfoStruct.rx(RxIds(1)).Freq;
        AcqInfo(4)  = seq.InfoStruct.rx(RxIds(1)).Freq / 4;
        AcqInfo(5)  = SyntAcq;
        AcqInfo(6)  = ImgInfo.Depth(1); % zorigin
        AcqInfo(7)  = ImgInfo.Depth(2); % depth (not used)
        AcqInfo(8)  = 0;       % initial time (not used)
        AcqInfo(9)  = SkipSamples;
        AcqInfo(10) = NumSamples;
        AcqInfo(11) = (1 + SyntAcq) * system.hardware.NbRxChan;

        % ============================================================================ %

        % Set ReconAbsc structure (position of points to be reconstructed)
        if SyntAcq
            ReconAbsc = int32( [seq.InfoStruct.rx(RxIds(1)).Channels ...
                seq.InfoStruct.rx(RxIds(2)).Channels] );
        else
            ReconAbsc = int32( seq.InfoStruct.rx(RxIds(1)).Channels );
        end
        ReconAbsc = ReconAbsc( ReconAbsc <= system.probe.NbElemts );
        ReconAbsc = unique( sort(ReconAbsc) ) - 1;

        if isfield( ImgInfo, 'FirstLine' ) && isfield( ImgInfo, 'LastLine' )
            DesiredReconAbsc = int32( (ImgInfo.FirstLine-1):(ImgInfo.LastLine-1) );
            ReconAbsc = int32( intersect(DesiredReconAbsc, ReconAbsc) );

            if isempty( ReconAbsc )
                error('FirstLine and LastLine are out of imaging area');
            end
        end
        ReconDelay = double( seq.InfoStruct.tx(txId).Delays(ReconAbsc + 1) );

        % ============================================================================ %

        % Set ReconInfo structure
        ReconInfo( 1) = length(ReconAbsc);              % # reconstruction
        ReconInfo( 2) = 1;                              % planewave (0 for focalized)
        ReconInfo( 3) = round(1 / ImgInfo.LinePitch);   % # lines in AcqInfo (1 for planewave)
        ReconInfo( 4) = 1 / (2 * ReconInfo(3));         % xorigin
        ReconInfo( 5) = 1 / ReconInfo(3);               % dx / PiezoPitch
        ReconInfo( 6) = ImgInfo.PitchPix;               % dz / lambda
        NPixLine = ( (ImgInfo.Depth(2) - ImgInfo.Depth(1)) ... % # pixels / ligne ?!
            / ReconInfo(6) / ( common.constants.SoundSpeed/1000 / AcqInfo(4) ) );
        ReconInfo( 7) = ceil(NPixLine/4)*4 ;
        ReconInfo( 8) = 0; % PeakDelay (1/2 taille pulse) ?!
        ReconInfo( 9) = 0; % PipeOffset
        ReconInfo(10) = AcqInfo(11);
        ReconInfo(11) = system.hardware.NbRxChan/2; % MaxChannelsOneSide
        ReconInfo(12) = double( seq.InfoStruct.mode(ModeId).channelSize );
        ReconInfo(13) = 10;                % TxAlongRx, TODO: put as parameter
        ReconInfo(14) = 97;                % coeff pour interpolation BP (par pope)
        ReconInfo(15) = 50;                % coeff pour interpolation foot (par pope)
        ReconInfo(16) = ImgInfo.RxApod(1); % aperture apodisation (par pope)
        ReconInfo(17) = ImgInfo.RxApod(2); % slope apodisation (par pope)
        ReconInfo(18) = 0;                       % output type
        if(k>1)
            ReconInfo(18) = ReconInfo(18) + 3 ; % IQ accumulation mode
        end
        ReconInfo(19) = 1;                 % NPixSlice
        ReconInfo(20) = 0;                 % LutSizeBytes
        ReconInfo(21) = 0;                 % do not change
        ReconInfo(22) = common.constants.SoundSpeed;
        if Probe(4) > 0 
            ReconInfo(23) = 150; % mm
        end

        ReconInfo(24) = 0; % Sound speed layer
        ReconInfo(25) = 0; % layer_height
        ReconInfo(26) = 0; % MeanAngleSynthetic

        % ============================================================================ %

        % ============================================================================ %

        % ReconMux array for geometric position of different recons
        NRecon   = ReconInfo( 1);
        if ( SyntAcq )
            ReconMux = zeros(1, NRecon, 'int32');
        else
            ReconMux = int32( min(seq.InfoStruct.rx(RxIds(1)).Channels) - 1 ) ...
                .* ones(1, NRecon, 'int32');
        end

    % ============================================================================= %

        LutSize      = zeros(1, 1, 'int32');
        %     LutSizeBytes = 0;

        Status = complutRubi( Probe, AcqInfo, ReconInfo, ReconMux, ReconAbsc, ...
            ReconDelay, LutSize );
        if Status ~= 12;
            disp('Complut output status first pass')
            disp(Status)
            error('erreur de parametrage');
        end

        % Set correct Lut size in bytes.
        LutSizeBytes  = LutSize;
        ReconInfo(20) = LutSizeBytes;

        Lut(k).data = zeros(1, LutSize/2, 'int16');

        % Compute LUT
        Status = complutRubi(Probe, AcqInfo, ReconInfo, ReconMux, ReconAbsc, ...
            ReconDelay, Lut(k).data);

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

        Lut(k).ReconAbsc  = ReconAbsc ;
        Lut(k).NRecon     = ReconInfo(1);
        Lut(k).NLines     = ReconInfo(3);
        Lut(k).NPixLine   = ReconInfo(7);
        Lut(k).OutputType = ReconInfo(18);    
        Lut(k).LutSize    = LutSize ;

    end

end
