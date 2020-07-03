%    clear all; clc
%   w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %

% adresse Bastille : '192.168.0.20'
% adresse Jussieu :  '192.168.1.16'
clearvars;

 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 % path at Jussieu :
 if strcmp(AixplorerIP,'192.168.1.16')
 addpath('D:\AO---softwares-and-developpement\radon inversion\shared functions folder')
 end
 % path at Bastille :
 if strcmp(AixplorerIP,'192.168.0.20')
 addpath('D:\GIT\AO---softwares-and-developpement\radon inversion\shared functions folder');
 end
 
 addpath('..\AcoustoOptique\sequences');
 addpath('..\AcoustoOptique\subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 
        TypeOfSequence  = 'JM';
        Volt            = 15;
        FreqSonde       = 6;
        NbHemicycle     = 2;
        
        
        AlphaM          = 0;
        dA              = 1;
        
        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        NbZ         = 1:2;        % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;        % 20 Nb de composantes de Fourier en X, 'JM'
        DurationWaveform = 20;  % length in dimension x (us)
        Tau_cam          = 150 ;% camera integration time (us)
                                %   n_rep is calculated by Tau_cam/DurationWaveform  
        
        Foc             = 35;
        X0              = -10; %10-25
        X1              = 50;
        
        
        %NbHemicycle = 200;
        %NbZ         = 10;      % 4; % Nb de composantes de Fourier en Z, 'JM'
        %NbX         = 10;     % 5 Nb de composantes de Fourier en X, 'JM'

        Naverage        = 10 ;
        Prof            = 150;
        SaveData        = 1 ; % set to 1 to save

Aixplorer = 'off' ;
MotorControl = 'off';


%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %



if strcmp(Aixplorer,'on')
    
clear SEQ ScanParam raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
Volt = min(40,Volt); % security for OP routine  
[SEQ,ScanParam] = AOSeqInit_OFL(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, Naverage);
    case 'OP'
        X0              = -1; %10-25
        X1              = 40;
        ScanIndex       = 1 ;
Volt = min(40,Volt); % security for OP routine       
[SEQ,Delay,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OPL(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, Naverage);
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
        X0              = 0; %10-25
        X1              = 38;
        ScanIndex       = 1 ;
Volt = min(30,Volt); % security for OP routine     
[SEQ,Delay,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OSusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , NbX , X0 , X1 ,Prof, Naverage,ScanIndex);
    case 'JM'
        X0              = -1; %10-25
        X1              = 40;
        ScanIndex       = 10;%last11
Volt = min(Volt,15) ; 
[SEQ,ActiveLIST,NUX,NUZ] = AOSeqInit_OJMLusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Naverage ,DurationWaveform,Tau_cam);
    case 'OC'
Volt = min(15,Volt); % security for OP routine    
[SEQ,MedElmtList,NUX,NUZ] = AOSeqInit_OC(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 , Naverage ,DurationWaveform , Tau_cam);

end

end 

c = common.constants.SoundSpeed ; % sound velocity in m/s
                    
%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress
     SampleRate   =   50;
     Range        =   1 ;
     Npoints      = 30000;
     N_holdoff    =  0;
     Nevent       = 1;% length(SEQ.InfoStruct.event);
     TriggerSatus = 'on' ; % 'on' to activate external trig, 'off' : will trig on timout value


[ret,Hgage,acqInfo,sysinfo] = InitRawGage(Naverage*Nevent,Npoints,N_holdoff,SampleRate,Range,TriggerSatus) ;
SampleRate = acqInfo.SampleRate*1e-6;
fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    
% creation of new Scan structure :

Hf = figure;
set(Hf,'WindowStyle','docked'); 
    %% ======================== start acquisition =============================
% GetPosition(Controller,'1')
% GetPosition(Controller,'2')
    
x = 0 ;% + (-15:1:15) ; % horizontal axis (1) in mm
y = 0 ;
z = 0;% + (0:1:50);    % -30 vertical axis   (2) in mm , GetPosition(Controller,'2')
    
N = 2^nextpow2(acqInfo.SegmentSize);
raw   = zeros(N,Naverage);

MyScan = USscan(x,y,z,Naverage,N);   



      for n_scan = 1:MyScan.Nscans
          
        % clear buffer and look for errors
        if strcmp(MotorControl,'on')
            
            GetLastError(Controller,'1');
            GetLastError(Controller,'2');
            if(Controller.BytesAvailable>0)
                fscanf(Controller, '%s')  
            end
            
        end
        
        % move to position
        % position x
        posX = MyScan.Positions(n_scan,1);
        if strcmp(MotorControl,'on')
        PolluxDepAbs(Controller,posX,'1')
        end
        %position y
        posY = MyScan.Positions(n_scan,2);
        % no motor associated
        
        % position z
        posZ = MyScan.Positions(n_scan,3);
        if strcmp(MotorControl,'on')
        PolluxDepAbs(Controller,posZ,'2')
        end
        
        
        
        % read position and update scan position list
        if strcmp(MotorControl,'on')
        posX = GetPosition(Controller,'1') ;
        posZ = GetPosition(Controller,'2') ;
        end
        
        % print current position
        disp(sprintf('Scan position X:%f,Y:%f,Z:%f',posX,posY,posZ));
        
        % update position inside scan sctucture
        MyScan.Positions(n_scan,1) = posX ;
        MyScan.Positions(n_scan,3) = posZ ;
        
        % acquire data
        
          
        % Stop current Aixplorer Sequence
        if strcmp(Aixplorer,'on')

        SEQ = SEQ.stopSequence('Wait', 0);

        end
 
        % Start Aixplorer pre-loaded sequence
       
        if strcmp(Aixplorer,'on')

        SEQ = SEQ.startSequence();
        end
        
    % begin gage capture
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
 


    tic     
    % begin gage waiting for capture  
    status = CsMl_QueryStatus(Hgage);
    
    while (status ~= 0 && toc < 10)
        status = CsMl_QueryStatus(Hgage);
    end
    toc

        % Stop Aixplorer pre-loaded sequence
    
        if strcmp(Aixplorer,'on')

        SEQ = SEQ.stopSequence('Wait', 0);  

        end
        
    
    for SegmentNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer                                                             % actual contains the actual length of the acquisition that may be                                                       % different from the requested one.
        raw((1+actual.ActualStart):( actual.ActualStart + actual.ActualLength ),SegmentNumber) = datatmp' ;
        
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
    
    % color screen each event
    cc = jet(Nevent);
    
    % average datas
    for n_event = 1:Nevent
    if Naverage == 1
    signal(:,n_event) = raw(:,Naverage) ;    
    else
    signal(:,n_event) = ...
        mean( raw(:,( (n_event-1)*Naverage + 2):n_event*Naverage ) , 2) ;
    % start at + 2 because first value supposed to be offset
    end
    MyScan.Datas(:,n_scan) = signal(:,n_event) ;
    

    signal_FT(:,n_event) = fft(signal(:,n_event),N);
    
    subplot(2,1,2)

    frequencies = (0:N/2)*( SampleRate/(N) ) ;
    signal_FT(frequencies < 0.2,n_event) = 0;
    signal_FT(frequencies > 100,n_event) = 0;
    hold on
    plot( frequencies , abs(signal_FT( 1:(N/2+1) , n_event) ) ,'color' , cc(n_event,:) )
    hold off
    xlim([5 7])
    xlabel('frequency MHz') 
    ylabel('a.u.')
    title('|FFT|')
    
    % bandpass filter
    
    % hilbert transform of signal
    %signal_filtered(:,n_event) = ifft(signal_FT(:,n_event),'symmetric');
    
     subplot(2,1,1) 
     hold on
     plot(t*1e6 , signal(:,n_event) ,'color' , cc(n_event,:) );
     hold off
     
    %axis([21 25 -0.5 1])
%      hold on
%      plot(t*1e6 , signal_filtered ,'color' , 'black' );
     %hold on
     %plot(t*1e6 , abs(Amplitude),'color','red','linewidth',3)
%      xlim([19 25])
%      ylim([-0.5 0.5])
     
    xlabel('time(\mus)')
    ylabel('Volt')
    title('Averaged signal')
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    end
    
    
      end

% save datas :
if SaveData == 1
    
MainFolderName = 'datas';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'TriangleSautdePhase50kHz_ref';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'Noop',500);
% savefig(Hf,FileName);
% saveas(Hf,FileName,'png');

switch TypeOfSequence
    case 'OF'
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','Naverage','Npoints','Prof','ScanParam','x','z','MyScan','SampleRate','c','Range','TypeOfSequence');
    case 'OP'
save(FileName,'Volt','Delay','ActiveLIST','FreqSonde','NbHemicycle','Alphas'...
              ,'X0','X1','Naverage','Npoints','Prof','ScanParam','x','z','MyScan','SampleRate','c','Range','TypeOfSequence','ScanIndex');
    case 'OS'
save(FileName,'Volt','Delay','ActiveLIST','FreqSonde','NbHemicycle','Alphas','NbX','dFx'...
                  ,'X0','X1','Naverage','Npoints','Prof','ScanParam','z','MyScan','SampleRate','c','Range','TypeOfSequence','ScanIndex');
    case 'JM'
% save(FileName,'Volt','ActiveLIST','FreqSonde','NbHemicycle','NbX','NbZ','NUX','NUZ','dFx'...
%                   ,'X0','X1','Naverage','Npoints','Prof','z','MyScan','SampleRate','DurationWaveform','c','Range','TypeOfSequence','ScanIndex');
save(FileName,'Volt','FreqSonde','NbHemicycle','NbX','NbZ'...
                  ,'X0','X1','Naverage','Npoints','Prof','z','MyScan','SampleRate','DurationWaveform','c','Range','TypeOfSequence');

% saveas(Hresconstruct,[FileName,'_ifft'],'png');
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
