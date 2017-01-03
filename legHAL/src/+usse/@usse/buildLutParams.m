function obj = buildLutParams( obj, BFStruct )

% acqInfo
NFirings = 1;

acqInfo(1).steerAngle     = int32( BFStruct{1}.LutInfo.AcqInfo(1) );
acqInfo(1).firings        = int32( NFirings );
acqInfo(1).bandwith       = int32( BFStruct{1}.LutInfo.AcqInfo(2) );
acqInfo(1).freqDivider    = int32( BFStruct{1}.LutInfo.AcqInfo(3) );
acqInfo(1).demodFreq      = BFStruct{1}.LutInfo.AcqInfo(4) ;
acqInfo(1).synthAcq       = int32( BFStruct{1}.LutInfo.AcqInfo(5) );
acqInfo(1).zOrigin        = BFStruct{1}.LutInfo.AcqInfo(6);
acqInfo(1).initialTime    = 99; int32( BFStruct{1}.LutInfo.AcqInfo(8) );
acqInfo(1).firstSample    = int32( BFStruct{1}.LutInfo.AcqInfo(9) );
acqInfo(1).rfSampleNumber = int32( BFStruct{1}.LutInfo.AcqInfo(10) );

obj.RemoteStruct.acqInfo = acqInfo;


% reconInfo
% constants for planewaves (why ?)
NLines = 1 ; 
Mode = 0;

reconInfo(1).nbRecon         = int32( BFStruct{1}.LutInfo.ReconInfo(10) );
reconInfo(1).planeWave       = int32( BFStruct{1}.LutInfo.ReconInfo(2) );
reconInfo(1).nbLines         = int32( NLines );
reconInfo(1).xOrigin         = BFStruct{1}.LutInfo.ReconInfo(4);
reconInfo(1).linePitch       = BFStruct{1}.LutInfo.ReconInfo(5);
reconInfo(1).pitchPix        = BFStruct{1}.LutInfo.ReconInfo(6);
reconInfo(1).nbPixLine       = BFStruct{1}.LutInfo.ReconInfo(7);
reconInfo(1).peakDelay       = BFStruct{1}.LutInfo.ReconInfo(8);
reconInfo(1).pipeOffset      = BFStruct{1}.LutInfo.ReconInfo(9);
reconInfo(1).defaultRFChannelNumber = int32( BFStruct{1}.LutInfo.ReconInfo(11) *2 ); % in rubi this is mul by (1+syntacq)
reconInfo(1).hwcNbReceive    = int32( BFStruct{1}.LutInfo.ReconInfo(11)*2 );
reconInfo(1).channelOffset   = int32( BFStruct{1}.LutInfo.ReconInfo(12) );
reconInfo(1).txAlongRX       = int32( BFStruct{1}.LutInfo.ReconInfo(13) );
reconInfo(1).bandInterp      = BFStruct{1}.LutInfo.ReconInfo(14) ;
reconInfo(1).footInterp      = BFStruct{1}.LutInfo.ReconInfo(15) ;
reconInfo(1).apodisationKa1  = BFStruct{1}.LutInfo.ReconInfo(16);
reconInfo(1).apodisationKa2  = BFStruct{1}.LutInfo.ReconInfo(17);
reconInfo(1).apodisationKa3  = 0; %500;  %%not computed???
reconInfo(1).outputType      = int32( BFStruct{1}.LutInfo.ReconInfo(18) );
reconInfo(1).nbPixSlices     = int32( BFStruct{1}.LutInfo.ReconInfo(19) );
reconInfo(1).mode            = int32( Mode );
reconInfo(1).soundSpeed      = BFStruct{1}.LutInfo.ReconInfo(22);
reconInfo(1).soundSpeedLayer = 0;
reconInfo(1).heightLayer     = 0;

obj.RemoteStruct.reconInfo = reconInfo;


% reconDelay
obj.RemoteStruct.reconDelay.data = BFStruct{1}.LutInfo.ReconDelay;

% reconMux
obj.RemoteStruct.reconMux.data = BFStruct{1}.LutInfo.ReconMux;

% reconAbsc
obj.RemoteStruct.reconAbsc.data = BFStruct{1}.LutInfo.ReconAbsc;




