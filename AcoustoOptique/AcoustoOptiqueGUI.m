% clear all; close all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end

%% parameter for sequence :
% ======================================================================= %
% adresse Jussieu  : '192.168.1.16'
% new AIXPLORER : '192.168.1.10'

 AixplorerIP    = '192.168.1.10'; % IP address of the Aixplorer device
 
 addpath('D:\AO--commons\shared functions folder')
 addpath('sequences');    
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 
       TypeOfSequence = 'JM';    %'OF'(focused waves) , 'OS' (plane structures waves), 
                                 %'OP' (plane waves) , 'JM' (Jean-Michel waves)
        
        Master      = 'on';      % Aixplorer as Master ('on') of Slave ('off') with respect to trigger
        Volt        = 40;        % 'OF' , 'OS', 'OP' , 'JM' Volt
        FreqSonde   = 3;         % 'OF' , 'OS', 'OP' , 'JM' MHz
        NbHemicycle = 10;        % 'OF' , 'OS', 'OP' , 'JM'
        Foc         = 25;        % 'OF' mm
        AlphaM      = [0]*pi/180;        % 'OP' list of angles in scan in Rad
        X0          = 0;          % 'OF' , 'OS', 'OP' , 'JM' in mm
        X1          = 35.8 ;      % 'OF' , 'OS', 'OP' , 'JM' in mm
        PosOFscan   = 10:0.2:25;  % 17.5
        NTrig       = 300;        % 'OF' , 'OS', 'OP' , 'JM' 
        Prof        = 600;        % 'OF' , 'OS', 'OP' , 'JM' in mm
        decimation  = [8] ;       % 'OS'
        NbZ         = -4:4;       % 'JM' harmonic along z 
        NbX         = 1:8;        % 'JM' harmonic along x 
        Phase       = [0];        % 'JM' phases per frequency in 2pi unit
        Tau_cam          = 100 ;  % 'JM' camera integration time (us) : sets the number of repetition patterns
        Bacules         = 'off';  % 'JM' alternates phase to provent Talbot effect
        Frep            =  max(2,100) ;   % 'OF' , 'OS', 'OP' , 'JM'in Hz
        USemissionDelay = 65;   % 'OP' emission delay in us (error x10 in new aixplorer)
        
        % 'JM' 
        DurationWaveform = 20;  % 'JM' fondamental time along t -- do not edit --
        % imposing that be a multiple of sampling period
        n_low = round( 180*DurationWaveform ); % -- do not edit --
        NU_low = (180)/n_low;                  % 'JM' fundamental temporal frequency in MHz -- do not edit --
        
        
        
        SaveData = 1;           % set to 1 to save data
        AIXPLORER_Active = 'off';% 'on' or 'off' 

 % estimation of loading time 
 fprintf('%i events, loading should take about %d seconds\n\r',length(NbX)*length(NbZ)*length(Phase));

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
if strcmp(AIXPLORER_Active,'on')
    
switch TypeOfSequence
    case 'OF'
NbHemicycle = min(NbHemicycle,100);
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc,PosOFscan, X0 , X1 , Prof, NTrig,Frep ,Master,USemissionDelay);
    case 'OP'
NbHemicycle = min(NbHemicycle,100);
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof,NTrig ,Frep ,Master,USemissionDelay);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , decimation , X0 , X1 ,Prof, NTrig,Frep,Master);   
    case 'JM'
Volt = min(Volt,20) ; 
% check the coordinate of this function

% sequence for Digital Holography
%[SEQ,ActiveLIST,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OJMLusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam , Phase , Frep , Bacules , Master );

% sequence for Photorefractive Crystal
[SEQ,MedElmtList,NUX,NUZ,nuX0,nuZ0]          = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam ,  Frep , Bacules , Master );

end

end

c = common.constants.SoundSpeed ; % sound velocity in m/s

%% === run following script to view sequences loaded into Aixplorer ======

                    
%%  ========================================== Init Gage acquisition Card ==================
%   Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress
     
     SampleRate      =   50e6;% Gage sampling frequency in Hz (option: [50,25,10,5,2,1,0.5,0.2,0.1,0.05])
     Range           =   1;
     Offset_gage     = 0; % Vpp in mV
     Npoint          = ceil( (SampleRate*(Prof*1e-3)/c)/32 )*32 ;
     GageActive      = 'on' ; % on to activate external trig, off : will trig on timout value
     modeIN          = 'Single';            % options are : 'Single','Quad'
     
    if strcmp(AIXPLORER_Active,'on') 
    Nlines = length(SEQ.InfoStruct.event);  
    else
    Nlines = (2*length(NbX)+1)*length(NbZ) ;
    end
    
[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig*Nlines,Npoint,SampleRate,Range,GageActive,Offset_gage,modeIN);
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    

    %% ======================== start acquisitionMaster =============================
     
   if strcmp(GageActive,'on')
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
   end
    
    if strcmp(AIXPLORER_Active,'on')

%        SEQinfosPrint( SEQ )        % printout SEQ infos

        %SEQ = StartMySequence(SEQ);
        SEQ = SEQ.startSequence('Wait',0);
    
    end
%     % retreive received RF data 
%     buffer = SEQ.getData('Realign', 1);
%     figure
%     imagesc(double(mean(buffer.data,3)))
    if strcmp(GageActive,'on')
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
    
    end
    % if strcmp(AIXPLORER_Active,'on')

        % SEQ = SEQ.stopSequence('Wait', 0);  
  
    % end
   
    
    
%% ======================== data post processing =============================
 
    switch TypeOfSequence
        
        case 'OF'
            
    [Datas_mu,Datas_std, Datas_var] = RetreiveDatas(raw,NTrig,Nlines,ScanParam);
    t_aquisition = (1:actual.ActualLength)*(1/SampleRate);
    z = c*t_aquisition*1e3;
    NbElemts = system.probe.NbElemts ;
    pitch = system.probe.Pitch ; 
    x = ScanParam*pitch;

    Hmu = figure;
    set(Hmu,'WindowStyle','docked');
    imagesc(x,z,1e3*Datas_mu)
    ylim([0 Prof])
    xlabel('x (mm)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hmu,'-property','FontSize'),'FontSize',15) 
%     
%      Hmu = figure;
%      set(Hmu,'WindowStyle','docked');
%      title('OF scan at 17.5mm')
%      subplot(211); plot(t_aquisition*1e6,1e3*Datas_mu);
%      subplot(212); plot(t_aquisition*1e6,1e3*Datas_std);
%      xlabel('x (mm)')
%      ylabel('mVolt')
%      set(findall(Hmu,'-property','FontSize'),'FontSize',15) 
     
        case 'OP'
    
    [Datas_mu,Datas_std, Datas_var] = RetreiveDatas(raw,NTrig,Nlines,ScanParam);
    % Datas_mu: average data
    % Datas_std: = data standard deviation
    % Datas_var: data variance
    
    t_aquisition = (1:actual.ActualLength)*(1/SampleRate);
    
    
    % plot raw datas
    Hmu = figure;
    set(Hmu,'WindowStyle','docked');
    %imagesc(Alphas*180/pi,t*1e6,1e3*Datas_mu)
    plot(t_aquisition*1e6,1e3*Datas_mu)
    %xlabel('angle (°)')
    xlabel('t (\mu s)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hmu,'-property','FontSize'),'FontSize',15) 
    
    %  Load data to OP structure file :(temporalily commented: to be fixed)
%     MyImage = OP(Datas_mu,Alphas,z,SampleRate*1e6,c) ;
%     [I,z_out] = DataFiltering(MyImage) ;
%     NbElemts = system.probe.NbElemts ;
%     pitch = system.probe.Pitch ; 
%     X_m = (1:NbElemts)*(pitch*1e-3) ;
%     [theta,M0,X0,Z0] = EvalDelayLaw_shared(X_m,DelayLAWS,ActiveLIST,c); 
% 
%     %  iRadon inversion :
%     Ireconstruct = Retroprojection_shared(I , X_m , z_out ,theta,M0,Hresconstruct);
%     
%     Hresconstruct = figure;
%     set(Hresconstruct,'WindowStyle','docked');
%     ylim([0 Prof])
%     cb = colorbar;
%     ylabel(cb,'a.u')
%     colormap(parula)
%     set(findall(Hresconstruct,'-property','FontSize'),'FontSize',15) 
%     
    % RetroProj_cleaned(Alphas,Datas,SampleRate*1e6);
    % back to original folder 
    
       case 'OS'
            
     [Datas_mu,Datas_std, Datas_var] =  RetreiveDatas(raw,NTrig,Nlines,1:size(ScanParam,1));
     NbElemts = system.probe.NbElemts ;
     pitch = system.probe.Pitch ; 
     X_m = (1:NbElemts)*(pitch*1e-3) ;
     z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
     x = ScanParam(:,2);
    
    Hmu = figure;
    set(Hmu,'WindowStyle','docked');
    imagesc(x,z*1e3,1e3*Datas_mu)   
    xlabel('order N_x')
    zlabel('z(mm)')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hmu,'-property','FontSize'),'FontSize',15) 
   
    MyImage = OS(Datas_mu,ScanParam(:,1),ScanParam(:,2),dFx,z,SampleRate*1e6,c,[X0 X1]*1e-2) ; 
    % resolution par ifourier
    [FTFx, theta , decimation ] = MyImage.AddSinCos(MyImage.R) ;
    DelayLAWS_  = MyImage.SqueezeRepeat( DelayLAWS  ) ;
    ActiveLIST_ = MyImage.SqueezeRepeat( ActiveLIST ) ;
       
    [theta,~,~,C] = EvalDelayLawOS_shared( X_m  , DelayLAWS_  , ActiveLIST_ , c) ;


    FTF = MyImage.InverseFourierX( FTFx  , decimation , theta , C ) ;
    OriginIm = sum(FTF,3) ;

    Hresconstruct = figure ;
    set(Hresconstruct ,'WindowStyle','docked');
    imagesc(X_m*1e3, MyImage.z*1e3,real(OriginIm))
    xlim([X0 X1])
    ylim([0 Prof])
    cb = colorbar;
    ylabel(cb,'a.u')
    colormap(parula)
    xlabel('x(mm)')
    ylabel('z(mm)')
    set(findall(gcf,'-property','FontSize'),'FontSize',15) 
    
   case 'JM'
        MedElmtList = 1:Nlines ;
        [Datas_mu,Datas_std, ~] = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
        % Calcul composante de Fourier
        z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
        x = (1:Nlines);
        
        % plot raw datas
            Hmu = figure;
            set(Hmu,'WindowStyle','docked');
            imagesc(x,z*1e3,1e3*Datas_mu)
            xlabel('lines Nbx, Nbz')
            ylabel('z (mm)')    
            title('Averaged raw datas')
            cb = colorbar;
            ylabel(cb,'AC tension (mV)')
            colormap(parula)
            set(findall(Hmu,'-property','FontSize'),'FontSize',15)

       [I,X,Z] = Reconstruct(NbX , NbZ, ...
                             NUX , NUZ ,...
                             x , z , ...
                             Datas_mu , ...
                             SampleRate , DurationWaveform, c , nuX0,nuZ0); 

       Hfinal = figure(101);
       set(Hfinal,'WindowStyle','docked');
       imagesc(X*1e3,Z,I);
       title('reconstructed image')
       xlabel('x (mm)')
       ylabel('z (mm)')
       cb = colorbar;
       ylabel(cb,'a.u')
       set(findall(Hfinal,'-property','FontSize'),'FontSize',15)
       
    end

    
 
 %% save datas :
if SaveData == 1
SaveRaw = 0 ;

MainFolderName = 'D:\Datas\mai';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = '5cm-1_burst_3170mA_ampli_100W_referenceON_100Hz';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence);
savefig(Hmu,FileName);
saveas(Hmu,FileName,'png');

switch TypeOfSequence
    
    case 'OF'
        if SaveRaw == 0
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','raw','NTrig','Nlines','Prof','ScanParam','pitch','NbElemts','x','z','Datas_mu','Datas_std','SampleRate','c','Range','TypeOfSequence','t_aquisition','Master');
        else
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','pitch','NbElemts','x','z','raw','SampleRate','c','Range','TypeOfSequence','t_aquisition','Master');            
        end
          
       case 'OP'
save(FileName,'Volt','DelayLAWS','ActiveLIST','FreqSonde','NbHemicycle','Alphas'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','pitch','NbElemts','x','z','Datas_mu','Datas_std','SampleRate','c','Range','TypeOfSequence','t_aquisition','Master');
%saveas(Hresconstruct,[FileName,'_retrop'],'png');
    case 'OS'
        if SaveRaw == 0
save(FileName,'Volt','DelayLAWS','ActiveLIST','FreqSonde','pitch','NbElemts','NbHemicycle','Alphas','decimation','dFx'...
                  ,'X0','X1','NTrig','Nlines','Prof','ScanParam','z','Datas_mu','Datas_std','SampleRate','c','Range','TypeOfSequence','t_aquisition','Master');
        else
save(FileName,'Volt','DelayLAWS','ActiveLIST','FreqSonde','pitch','NbElemts','NbHemicycle','Alphas','decimation','dFx'...
                  ,'X0','X1','NTrig','Nlines','Prof','ScanParam','z','raw','SampleRate','c','Range','TypeOfSequence','t_aquisition','Master');    
        end
saveas(Hresconstruct,[FileName,'_ifft'],'png');

    case 'JM'
        
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','X0','X1',...
              'NTrig','Nlines','Prof','MedElmtList','Datas_mu','Datas_std',...
              'SampleRate','c','Range','TypeOfSequence','x','z',...
              'NbX','NbZ','NUX','NUZ','Master','DurationWaveform','nuX0','nuZ0','t_aquisition','raw');
          saveas(Hfinal,FileName,'png');
% save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','AlphaM','dA'...
%               ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','raw','SampleRate','c','Range','TypeOfSequence');
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
% rmpath('D:\AO---softwares-and-developpement\radon inversion\shared functions folder');

