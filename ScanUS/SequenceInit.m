%    clear all; clc
%   w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %

% adresse Bastille : '192.168.0.20'
% adresse Jussieu :  '192.168.1.16'

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
 
        TypeOfSequence  = 'OP';
        Volt            = 20;
        FreqSonde       = 3;
        NbHemicycle     = 3;
        
        
        AlphaM          = 0;
        dA              = 1;
        
        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        NbX             = 1:20 ;     % 20 Nb de composantes de Fourier en X, 'JM'
        
        Foc             = 20;
        X0              = 0; %10-25
        X1              = 38;
        
        
        Prof            = 40;
        SaveData        = 0 ; % set to 1 to save



%% scan box delimitation
x = 0:1:2  ; % horizontal axis (1)
y = 0     ;
z = 0:1:2;    % vertical axis   (2)


%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %

Aixplorer = 'off' ;

if strcmp(Aixplorer,'on')
    
clear SEQ ScanParam raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
Volt = min(30,Volt); % security for OP routine  
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, Naverage);
    case 'OP'
Volt = min(30,Volt); % security for OP routine       
[SEQ,Delay,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, Naverage);
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
Volt = min(30,Volt); % security for OP routine     
[SEQ,Delay,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , NbX , X0 , X1 ,Prof, Naverage);

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
     N_holdoff    =  200 ;
     Npoints      = 2500;
     Naverage     = 2 ;
     TriggerSatus = 'off' ; % 'on' to activate external trig, 'off' : will trig on timout value
     
[ret,Hgage,acqInfo,sysinfo] = InitRawGage(Naverage,Npoints,N_holdoff,SampleRate,Range,TriggerSatus) 
fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    
    
% creation of new Scan structure :

N = 2^nextpow2(acqInfo.SegmentSize);
raw   = zeros(N,Naverage);
MyScan = USscan(x,y,z,acqInfo.SegmentCount,N);   

    Hf = figure;
    set(Hf,'WindowStyle','docked'); 
    %% ======================== start acquisition =============================

      for n_scan = 1:MyScan.Nscans
          
        % Stop current Aixplorer Sequence
        if strcmp(Aixplorer,'on')

        SEQ = SEQ.stopSequence('Wait', 1);

        end
    
    % begin gage capture
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    tic 
        
        % Start Aixplorer pre-loaded sequence
        
        if strcmp(Aixplorer,'on')

        SEQ = SEQ.startSequence();

        end

        
    % begin gage waiting for capture  
    status = CsMl_QueryStatus(Hgage);
    
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end
    
 
    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:

    t_aquisition = toc
    
        % Stop Aixplorer pre-loaded sequence
    
        if strcmp(Aixplorer,'on')

        SEQ = SEQ.stopSequence('Wait', 1);  

        end
        
    
    tic 
    for SegmentNumber = 1:acqInfo.SegmentCount
        
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
       raw((1+actual.ActualStart):actual.ActualLength,SegmentNumber) = datatmp' ;
        
    end
    
    toc
    
    CsMl_ErrorHandler(ret, 1, Hgage);
    

    
    %% ======================== data post processing =============================
    
    %Datas = RetreiveDatas(raw,NTrig,Nlines,1:size(ScanParam,1));
    hold off
    Points = 1:N ;
    dt = (1/(1e6*SampleRate)) ;
    t = Points*dt; % time in s
    z = Points*(c/(1e6*SampleRate)); % z in m

    raw(:,1) = rand(1)*sin(2*pi*(3e6)*t).*exp(-(t-20e-6).^2/(1e-6)^2)+ 0.5*rand(1,length(t));
    raw(:,2) = rand(1)*sin(2*pi*(3e6)*t).*exp(-(t-20e-6).^2/(1e-6)^2)+ 0.5*rand(1,length(t));
    
    
    % average datas
    Nav = 2 ;
    signal = mean(raw(:,1:Nav),2) ;
    signal_FT = fft(signal,N);
    
    subplot(2,1,2)
    % (0:(N/2))*(SampleRate/(2*N))) , 
    frequencies = (0:N/2)*( SampleRate/(N) ) ;
    signal_FT(frequencies<2) = 0;
    signal_FT(frequencies>4) = 0;
    plot( frequencies , abs(signal_FT( 1:(N/2+1) ) ) )
    xlabel('frequency MHz') 
    % bandpass filter
    
    % hilbert transform of signal
    signal_filtered = ifft(signal_FT,'symmetric');
    
    Amplitude = abs( hilbert(signal_filtered) );
    %Amplitude = filter(H_lowpass, Amplitude);
    subplot(2,1,1) 
    plot(Points , signal );
    hold on
    plot(Points , signal_filtered ,'color' , 'black' );
    hold on
    plot(Points , abs(Amplitude),'color','red','linewidth',3)
    axis([800 1500 -1 1])
    xlabel('pixels')
    ylabel('Volt')
    title('Single acquire')
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    
      end
    

 
   
%% save datas :
if SaveData == 1
    
MainFolderName = 'D:\Data\Mai\';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Vertical';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'Noop',1500);
savefig(Hf,FileName);
saveas(Hf,FileName,'png');

switch TypeOfSequence
    case 'OF'
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','x','z','Datas','SampleRate','c','Range','TypeOfSequence','t_aquisition');
    case 'OP'
save(FileName,'Volt','Delay','ActiveLIST','FreqSonde','NbHemicycle','Alphas'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','x','z','Datas','SampleRate','c','Range','TypeOfSequence','t_aquisition');
saveas(Hresconstruct,[FileName,'_retrop'],'png');
    case 'OS'
save(FileName,'Volt','Delay','ActiveLIST','FreqSonde','NbHemicycle','Alphas','NbX','dFx'...
                  ,'X0','X1','NTrig','Nlines','Prof','ScanParam','z','Datas','SampleRate','c','Range','TypeOfSequence','t_aquisition');

saveas(Hresconstruct,[FileName,'_ifft'],'png');
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
