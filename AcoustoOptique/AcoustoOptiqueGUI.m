close all
clearvars
%% parameter for plane wave sequence :
% ======================================================================= %
        Volt        = 20;
        f0          = 6;
        NbHemicycle = 2;
        AlphaM      = 20;
        dA          = 1;
        X0          = 0;
        ScanLength  = 38.5;
        NTrig       = 1;
        Prof        = 40;

%% Definition of window
AOSeqIniy_OP;
%% starts the aquisition after all parameters have been loaded
     SampleRate    =   10;
     Range         =   1;
                 
                    figure(1126)
                    imagesc(X,Y,squeeze(data(:,:,1)))
                    axis equal
                    axis tight
%% Initialize Gage Acquisition card
% %% Sequence execution
% % ============================================================================ %
 %SEQ = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 , NTrig);
 %SEQ = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 , NTrig);
 SEQ = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , NTrig);
 
 SEQ = SEQ.loadSequence();
c = common.constants.SoundSpeed ; % sound velocity in m/s
                    
%%========================================== Acquire data==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

clear MyMeasurement
MyMeasurement = oscilloTrace(acqInfo.Depth,acqInfo.SegmentCount,SampleRate*1e6,c) ;
    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    
   
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
   
    SEQ = SEQ.startSequence('Wait',0);
    close;
  
    status = CsMl_QueryStatus(Hgage);
    
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end

    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:

    for LineNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = LineNumber;                        % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
        
       % MyMeasurement = MyMeasurement.Addline(actual.ActualStart,actual.ActualLength,datatmp,LineNumber);
       MyMeasurement.Lines((1+actual.ActualStart):actual.ActualLength,LineNumber) = datatmp' ;

       

       
       %        data = data + (1/NTrig)*datatmp';
%        raw(:,ii) = datatmp';
        
    end

%            y = sum(MyMeasurement.Lines')/NTrig;
%        n = round(length(y)*0.66);
%        Err= std(y(n:end))
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    
   MyMeasurement.ScreenAquisition();
   
   SEQ = SEQ.stopSequence('Wait', 0);  
   

%% command line to force a trigger on Gage :
%CsMl_ForceCapture(Hgage);
