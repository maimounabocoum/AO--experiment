%    clear all; clc
%   w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %
addpath('..\AcoustoOptique\subfunctions');
        ProbeType      = 'Probe4MHz';
        SequenceType   = 'CW';
        NbCycle        = 1;
        Fburst         = 4 ;%MHz
        AmpSeqGen      = 10;
        SaveData        = 1 ; % set to 1 to save



%% ============================   Initialize AIXPLORER

c = 1540 ; % sound velocity in m/s
                    
%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress
     SampleRate   =   50; % 25
     Range        =   1 ;
     N_holdoff    =  0 ;
     Npoints      = 1000;
     Naverage     = 50 ;
     TriggerSatus = 'on' ; % 'on' to activate external trig, 'off' : will trig on timout value
     
[ret,Hgage,acqInfo,sysinfo] = InitRawGage(Naverage,Npoints,N_holdoff,SampleRate,Range,TriggerSatus) ;
fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
SampleRate = acqInfo.SampleRate*1e-6;
fprintf(' Sample rate is %4.2f MHz \n\r',1e-6*acqInfo.SampleRate);

transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    
% creation of new Scan structure  :

Hf = figure;
set(Hf,'WindowStyle','docked'); 
    %% ======================== start acquisition =============================
    % GetPosition(Controller,'1')  position mm ?
    % PolluxMoveCal(Controller,'2') mouvement absolue mm
    % PolluxDepRel(Controller,-5,'1') mouvement relatif mm
x = 70 ;% +(-5:0.1:5); %96 + (-10:0.50:10) ; % horizontal axis (1) in mm
y = 0 ;
z = 8:0.5:30;%0:0.5:30;    % vertical axis   (2) in mm
    
N = 2^nextpow2(acqInfo.SegmentSize);
raw   = zeros(N,Naverage);

MyScan = USscan(x,y,z,Naverage,N);   
tic
      for n_scan = 1:MyScan.Nscans
          
        % clear buffer and look for errors
        GetLastError(Controller,'1');
        GetLastError(Controller,'2');
        if(Controller.BytesAvailable>0)
            fscanf(Controller, '%s')  
        end
        
        % move to position
        % position x
        posX = MyScan.Positions(n_scan,1);
        PolluxDepAbs(Controller,posX,'1')
        %position y
        posY = MyScan.Positions(n_scan,2);
        % no motor associated
        
        % position z
        posZ = MyScan.Positions(n_scan,3);
        PolluxDepAbs(Controller,posZ,'2')
        
        
        
        % read position and update scan position list
        posX = GetPosition(Controller,'1') ;
        posZ = GetPosition(Controller,'2') ;
        
        % print current position
        disp(sprintf('Scan position X:%f,Y:%f,Z:%f',posX,posY,posZ));
        
        % update position inside scan sctucture
        MyScan.Positions(n_scan,1) = posX ;
        MyScan.Positions(n_scan,3) = posZ ;
        
        % acquire data

    % begin gage capture
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);

  
    % begin gage waiting for capture  
    status = CsMl_QueryStatus(Hgage);
    
    while (status ~= 0)
        status = CsMl_QueryStatus(Hgage);
    end
    

    for SegmentNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer                                                             % actual contains the actual length of the acquisition that may be                                                       % different from the requested one.
        raw((1+actual.ActualStart):actual.ActualLength,SegmentNumber) = datatmp' ;
        
    end
    

    
    CsMl_ErrorHandler(ret, 1, Hgage);
    

    
    %% ======================== data post processing =============================
    
    %Datas = RetreiveDatas(raw,Naverage,Nevent,1:size(ScanParam,1));

    Points = 1:N ;
    dt = (1/(1e6*SampleRate)) ;
    t = Points*dt; % time in s
    z = Points*(c/(1e6*SampleRate)); % z in m

    %raw(:,1) = rand(1)*sin(2*pi*(3e6)*t).*exp(-(t-20e-6).^2/(1e-6)^2)+ 0.5*rand(1,length(t));
    %raw(:,2) = rand(1)*sin(2*pi*(3e6)*t).*exp(-(t-20e-6).^2/(1e-6)^2)+ 0.5*rand(1,length(t));
    
    
    % average datas
 

    signal = mean(raw(:,1:Naverage),2) ;
    MyScan.Datas(:,n_scan) = signal ;

    signal_FT = fft(signal,N);
    
    subplot(2,1,2)

    frequencies = (0:N/2)*( SampleRate/(N) ) ;
    signal_FT(frequencies < 0.2) = 0;
    signal_FT(frequencies > 100) = 0;
    plot( frequencies , abs(signal_FT( 1:(N/2+1) ) ) )
    xlabel('frequency MHz') 
    % bandpass filter
    
    % hilbert transform of signal
    signal_filtered = ifft(signal_FT,'symmetric');
    
    Amplitude = abs( hilbert(signal_filtered) );
    %Amplitude = filter(H_lowpass, Amplitude);
    
     subplot(2,1,1) 
     plot(t*1e6 , signal );
%      hold on
%      plot(t*1e6 , signal_filtered ,'color' , 'black' );
     %hold on
     %plot(t*1e6 , abs(Amplitude),'color','red','linewidth',3)
%      xlim([19 25])
%      ylim([-0.5 0.5])
     
    xlabel('time(\mus)')
    ylabel('Volt')
    title('Single acquire')
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
%     if n_scan<10
%     end
if (mod(n_scan,10)==1)
         ttoc = toc;
     disp(['Temps restant : ' num2str(ttoc/n_scan*(MyScan.Nscans-n_scan)/60) ' min'])
disp([num2str(n_scan/MyScan.Nscans*100) ' %'])
end
      end

% save datas :
if SaveData == 1
    
%MainFolderName = 'datas\Sebastien';
MainFolderName = 'C:\Users\AcoustoOptique\Dropbox\PPT - prez\routine matlab\calibration sonde Nathan\Maimouna_Bocoum_calibration_transducteur_4Mega\calibrationCuvierHydrophone';
SubFolderName  = generateSubFolderName(MainFolderName);

% savefig(Hf,FileName);
% saveas(Hf,FileName,'png');


switch SequenceType
    case 'Burst'
        CommentName    = ['Sonde' ProbeType]; 
        FileName       = generateSaveName(SubFolderName ,'name',CommentName...
            ,'Fburst',Fburst,'Nbcycle',NbCycle);
        
        save(FileName,'Fburst','NbCycle','AmpSeqGen','SequenceType','ProbeType'...
              ,'Naverage','Npoints','MyScan','SampleRate','c','Range');
    case 'CW'
        CommentName    = '100cycles' ; 
        FileName       = generateSaveName(SubFolderName ,'name',CommentName,'Volt',AmpSeqGen...
            ,'FMHz',Fburst);

        save(FileName,'Fburst','AmpSeqGen','ProbeType'...
              ,'Naverage','Npoints','MyScan','SampleRate','c','Range');

end


fprintf('Data has been saved under : \r %s \r\n',FileName);

end

%% ================================= command line to force a trigger on Gage :
%  CsMl_ForceCapture(Hgage);
%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote()      ;
%               ret = CsMl_FreeAllSystems   ;
%% ======================================== remove search paths =======
% rmpath('D:\legHAL')   ;  
% rmpath('subfunctions');
% rmpath('sequences')   ;
