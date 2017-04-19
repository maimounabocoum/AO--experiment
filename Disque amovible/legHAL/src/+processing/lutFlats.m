function BFStruct = lutFlats( seq, ModeId, ImgInfo, NThreads, varargin )

    % beamforming without synthetic summation

    % ============================================================================ %
    % ============================================================================ %

    option.lutinfo_output = 0;

    if nargin > 4 
        for n=1:2:nargin-4
            if strcmp( varargin{n}, 'lutinfo_output' )
                option.lutinfo_output = varargin{n+1};
            end
        end
    end
    
    %% Retrieve parameters and control their value

    % Retrieve parameters

    NSamples    = double( unique( seq.InfoStruct.mode(ModeId).ModeRx(1,:) ) );
    SkipSamples = double( unique( seq.InfoStruct.mode(ModeId).ModeRx(2,:) ) );
    RxIds       = unique( seq.InfoStruct.mode(ModeId).ModeRx(3,:) );
    TxIds       = unique( seq.InfoStruct.mode(ModeId).ModeRx(4,:) );

    All_ACMOs = seq.getParam('acmo');

    TxPolarity = All_ACMOs{ModeId}.getParam('TxPolarity');
    TxElemsPattern = All_ACMOs{ModeId}.getParam('TxElemsPattern');
    
    NbTxPerFlat = max( [ length(TxPolarity) length(TxElemsPattern) ] ) 

    if ~isfield( ImgInfo, 'NbFlatAnglesAccum' )
        ImgInfo.NbFlatAnglesAccum = 1;
    end
    NbFlatAnglesAccum = ImgInfo.NbFlatAnglesAccum;

    if ~isfield( ImgInfo, 'MeanAngleSynthetic' )
        ImgInfo.MeanAngleSynthetic = 0;
    end

    if ~isfield( ImgInfo, 'TxAlongRx' )
        ImgInfo.TxAlongRx = 10;
    end

    if NbFlatAnglesAccum < 1
        error( 'NbFlatAnglesAccum must be >= 1' )
    end
    if mod( length(TxIds)/NbTxPerFlat, NbFlatAnglesAccum )
        error( 'The number of angles must be a multiple of NbFlatAnglesAccum' )
    end

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

    [Lut,LutSizeArray,LutInfo] = ComputeLut( seq, ModeId, ImgInfo );

    if option.lutinfo_output
        BFStruct.LutInfo = LutInfo;
    end


    % ============================================================================ %
    % ============================================================================ %


    NbAngles = length(TxIds)/NbTxPerFlat/NbFlatAnglesAccum; % TODO: get angles from acmo.ultrafast ?
    
    % assuming all those variable does not depend on angle
    NPixLine = Lut(1).NPixLine;
    NLines  = Lut(1).NLines;
    NRecon = Lut(1).NRecon;

    NSamples = NSamples * (1+SyntAcq) * NbTxPerFlat * NbFlatAnglesAccum;

    skipSamplePerExec = NSamples*NThreads ;

    NImages = double(length(seq.InfoStruct.mode(ModeId).ModeRx(3,:)) ...
        / (length(TxIds) * (1 + SyntAcq)));


    % parsing lut if needed
    NbTotalLuts = ceil(NThreads/NbAngles);

    if NbTotalLuts > 1
        for kt = 2:NbTotalLuts
            for k = 1:NbAngles
                Lut(k+ (kt-1)*NbAngles).data = zeros(1, LutSizeArray(k)/2, 'int16');
            end
        end

        for kt = 2:NbTotalLuts
            for k = 1:NbAngles
                Lut(k+ (kt-1)*NbAngles).data(1:(LutSizeArray(k)/2)) = Lut(k).data(1:(LutSizeArray(k)/2));
            end
        end
    else
        NbTotalLuts = 1 ;
    end

    % add NbAngles-1 luts as we can start at any angle between 1 and NAngles

    for k=1:(NbAngles-1)
        Lut(k+ NbTotalLuts*NbAngles).data = zeros(1, LutSizeArray(k)/2, 'int16');
        Lut(k+ NbTotalLuts*NbAngles).data( 1:(LutSizeArray(k)/2) ) = Lut(k).data( 1:(LutSizeArray(k)/2) );
    end

    BFStruct.Info.NImages = NImages;
    BFStruct.Info.NbAngles = NbAngles ;
    BFStruct.Info.NThreads = NThreads ;
    BFStruct.Info.skipSamplePerExec = double( skipSamplePerExec ) ;
    BFStruct.Info.nbRFSamplePerFlat = double( NSamples ) ;
    BFStruct.Info.Nexec = floor( NImages*NbAngles/NThreads );
    BFStruct.Lut = Lut ;
    BFStruct.IQ = 1i*ones( NPixLine, NLines*NRecon, NImages*NbAngles, 'single' );
    BFStruct.type = 'flat' ;
    BFStruct.ModeID = ModeId ;

end
% ============================================================================ %
% ============================================================================ %

function [Lut,LutSizeArray,LutInfos] = ComputeLut( seq, ModeId, ImgInfo )

    if ImgInfo.Depth(2) < ImgInfo.Depth(1)
        error( 'BFSRIPT:BEAMFORMINGFLAT', 'The depth must be increasing.' );
    end
    
    RxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(3,:));
    TxIds       = unique(seq.InfoStruct.mode(ModeId).ModeRx(4,:));
    SyntAcq     = ( length(RxIds) == 2 );
    NumSamples  = unique(seq.InfoStruct.mode(ModeId).ModeRx(1,:));
    SkipSamples = unique(seq.InfoStruct.mode(ModeId).ModeRx(2,:));
    
    All_ACMOs = seq.getParam('acmo');

    TxPolarity = All_ACMOs{ModeId}.getParam('TxPolarity');
    TxElemsPattern = All_ACMOs{ModeId}.getParam('TxElemsPattern');
    
    NbTxPerFlat = max( [ length(TxPolarity) length(TxElemsPattern) ] );
    NbFlatAnglesAccum = ImgInfo.NbFlatAnglesAccum;
    
    NbSuccessiveAccum = NbTxPerFlat*NbFlatAnglesAccum;

    for k = 1 : NbSuccessiveAccum : length(TxIds)

        txId      = TxIds(k);
        FlatAngle = double(mean(asin(diff(seq.InfoStruct.tx(txId).Delays * 1e-3) ...
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
        AcqInfo(7)  = 0; %ImgInfo.Depth(2); % depth (not used)
        AcqInfo(8)  = 0; % 99;       % initial time (not used)
        AcqInfo(9)  = SkipSamples;
        AcqInfo(10) = NumSamples;
        AcqInfo(11) = (1 + SyntAcq) * system.hardware.NbRxChan; % is it 128 or 256 ?

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
        ReconInfo( 2) = NbSuccessiveAccum;              % planewave (0 for focalized)
        ReconInfo( 3) = round(1 / ImgInfo.LinePitch);   % # lines in AcqInfo (1 for planewave)
        ReconInfo( 4) = 1 / (2 * ReconInfo(3));         % xorigin
        ReconInfo( 5) = 1 / ReconInfo(3);               % dx / PiezoPitch
        ReconInfo( 6) = ImgInfo.PitchPix;               % dz / lambda
        NPixLine = ( (ImgInfo.Depth(2) - ImgInfo.Depth(1) ) ... % # pixels / ligne ?!
            / ReconInfo(6) / ( common.constants.SoundSpeed/1000 / AcqInfo(4) ) );
        ReconInfo( 7) = ceil(NPixLine/4)*4 ;
        ReconInfo( 8) = 0; % PeakDelay (1/2 taille pulse) ?!
        ReconInfo( 9) = 0; % PipeOffset
        ReconInfo(10) = AcqInfo(11);
        ReconInfo(11) = system.hardware.NbRxChan/2; % MaxChannelsOneSide
        ReconInfo(12) = double( seq.InfoStruct.mode(ModeId).channelSize );
        ReconInfo(13) = ImgInfo.TxAlongRx; % TxAlongRx, TODO: put as parameter
        ReconInfo(14) = 97;                % coeff pour interpolation BP (par pope)
        ReconInfo(15) = 50;                % coeff pour interpolation foot (par pope)
        ReconInfo(16) = ImgInfo.RxApod(1); % aperture apodisation (par pope)
        ReconInfo(17) = ImgInfo.RxApod(2); % slope apodisation (par pope)

        % output type:
        % 0 : IQ rectangular output
        % 3 : IQ rectangular output + accumulation (no steering)
        % 10: IQ rectangular output + SteerOutputFloat (no accumulation)
        % 13: IQ rectangular output + SteerOutputFloat with accumulation
        if Probe(4) > 0 
            ReconInfo(18) = 0;  % output type
        else
            ReconInfo(18) = 10; % output type 
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
        ReconInfo(26) = ImgInfo.MeanAngleSynthetic; % MeanAngleSynthetic

        % ============================================================================ %

        % ============================================================================ %

        % ReconMux array for geometric position of different recons
        NRecon   = ReconInfo( 1);
        if SyntAcq
            ReconMux = zeros(1, NRecon, 'int32');
        else
            ReconMux = int32( min( seq.InfoStruct.rx(RxIds(1)).Channels ) - 1 ) ...
                .* ones(1, NRecon, 'int32');
        end

    % ============================================================================= %

        LutSize      = zeros( 1, 1, 'int32' );
        %     LutSizeBytes = 0;

        Status = complutRubi( Probe, AcqInfo, ReconInfo, ReconMux, ReconAbsc, ...
            ReconDelay, LutSize );
        if Status ~= 12
            disp('Complut output status first pass')
            disp(Status)
            error('erreur de parametrage');
        end

        % Set correct Lut size in bytes.
        LutSizeBytes  = LutSize;
        ReconInfo(20) = LutSizeBytes;

        if NbSuccessiveAccum > 1
            lutidx = floor( k/NbSuccessiveAccum ) + 1 ;
        else
            lutidx = k ;
        end

        Lut(lutidx).data = zeros(1, LutSize/2, 'int16');

        % Compute LUT
        Status = complutRubi( Probe, AcqInfo, ReconInfo, ReconMux, ReconAbsc, ...
            ReconDelay, Lut(lutidx).data );

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

        LutInfos(lutidx).Probe = Probe;
        LutInfos(lutidx).AcqInfo = AcqInfo;
        LutInfos(lutidx).ReconInfo = ReconInfo;
        LutInfos(lutidx).ReconMux = ReconMux;
        LutInfos(lutidx).ReconAbsc = ReconAbsc;
        LutInfos(lutidx).ReconDelay = ReconDelay;

        Lut(lutidx).NRecon   = ReconInfo(1);
        Lut(lutidx).NLines   = ReconInfo(3);
        Lut(lutidx).NPixLine = ReconInfo(7);
        Lut(lutidx).OutputType = ReconInfo(18);

        LutSizeArray(lutidx) = LutSize ;

    end

end
