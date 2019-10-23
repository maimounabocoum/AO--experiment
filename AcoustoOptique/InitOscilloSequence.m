%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress
clearvars raw
     
     SampleRate    =   10;
     Range         =   1; % option 1 - 5
     GageActive = 'on' ; % on to activate external trig, off : will trig on timout value
     Nsegments = 500 ;  
     Prof = 50500e-6*1500*1e3 ; % in mm
 
[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(Nsegments,Prof,SampleRate,Range,GageActive);

fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    
    %% acquisition : 
    
        tic
    status = CsMl_QueryStatus(Hgage);
    
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end

    fprintf('Aquisition lasted %f s \n\r',toc);
    
    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:
    
    tic 
    for SegmentNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
       raw((1+actual.ActualStart):actual.ActualLength,SegmentNumber) = datatmp' ;
        
    end
    
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    fprintf('Data Transfer lasted %f s \n\r',toc);
    
  %% ======================== data post processing =============================
    
    Hf = figure;
    set(Hf,'WindowStyle','docked');
         
    t = (1:actual.ActualLength)*(1/(1e6*SampleRate))*1e6;

    plot(t,mean(raw,2))
    xlabel('t(\mu s)')
    ylabel('z (mm)')


    
    %% ================================= quite remote ===========================================%%
%               ret = CsMl_FreeAllSystems   ;
    