%   clear all; clc
%   w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%  restoredefaultpath % restaure original path

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
 
 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 
        TypeOfSequence  = 'OP'; % 'OP','OS'
        Volt            = 40; %Volt
        FreqSonde       = 6; %MHz
        NbHemicycle     = 2;
        
        AlphaM          = (-20:20)*pi/180; % specific OP

        
        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        decimation             = [8] ;     % 20 Nb de composantes de Fourier en X, 'OS'
        
        Foc             = 25; % mm
        X0              = 0; %13-27
        X1              = 40;
        
        NTrig           = 500;
        Prof            = 50;
        SaveData        = 1; % set to 1 to save
        SaveRaw         = 0 ;

                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ ScanParam raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
Volt = min(60,Volt); % security for OP routine  
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
Volt = min(60,Volt); % security for OP routine       
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof, NTrig);
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , decimation , X0 , X1 ,Prof, NTrig);

end


c = common.constants.SoundSpeed ; % sound velocity in m/s
                    
%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress
     SampleRate    =   10;
     Range         =   1; %Volt
     GageActive = 'on' ; % 'on' to activate external trig, 'off' : will trig on timout value
     
 Nlines = length(SEQ.InfoStruct.event);    
[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,GageActive);
fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    
   

 
    %% ======================== start acquisition =============================
    %SEQinfosPrint( SEQ )        % printout SEQ infos
    SEQ = SEQ.stopSequence('Wait', 0);
    
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    tic 
    
    SEQ = SEQ.startSequence();
    
    status = CsMl_QueryStatus(Hgage);
    
 
    while status ~= 0
        status = CsMl_QueryStatus(Hgage);
    end
    
 
    % Transfer data to Matlab
    % Z  = linspace(0,Prof,acqInfo.Depth); 
    % loop over segment counts:

    t_aquisition = toc
    
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
    
    SEQ = SEQ.stopSequence('Wait', 0);  
    
    %% ======================== data post processing =============================
    Hmu = figure;
    set(Hmu,'WindowStyle','docked');

    
    switch TypeOfSequence
        case 'OF'
    [Datas_mu,Datas_std, Datas_var] = RetreiveDatas(raw,NTrig,Nlines,ScanParam);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    NbElemts = system.probe.NbElemts ;
    pitch = system.probe.Pitch ; 
    x = ScanParam*pitch;
    imagesc(x,z,1e3*Datas_mu)
    ylim([0 Prof])
    xlabel('x (mm)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hmu,'-property','FontSize'),'FontSize',15) 
    
    Hstd = figure;
    set(Hstd,'WindowStyle','docked');
    imagesc(x,z,1e3*Datas_std)
    ylim([0 Prof])
    xlabel('x (mm)')
    ylabel('z (mm)')
    title('STD raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hstd,'-property','FontSize'),'FontSize',15) 
    
    Hsnr = figure;
    set(Hsnr,'WindowStyle','docked');
    imagesc(x,z,abs(Datas_mu./Datas_std))
    ylim([0 Prof])
    xlabel('x (mm)')
    ylabel('z (mm)')
    title('SNR raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hsnr,'-property','FontSize'),'FontSize',15)    
    
        case 'OP'
    Datas = RetreiveDatas(raw,NTrig,Nlines,ScanParam);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
    imagesc(Alphas*180/pi,z*1e3,1e3*Datas)
    xlabel('angle (°)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hstd,'-property','FontSize'),'FontSize',15) 
    %  Radon inversion :
% 
% 
%     %conv2(Datas,Mconv,'same')
    MyImage = OP(Datas,Alphas,z,SampleRate*1e6,c) ;
    [I,z_out] = DataFiltering(MyImage,10) ;
    NbElemts = system.probe.NbElemts ;
    pitch = system.probe.Pitch ; 
    X_m = (1:NbElemts)*(pitch*1e-3) ;
    [theta,M0,X0,Z0] = EvalDelayLaw_shared(X_m,DelayLAWS,ActiveLIST,c); 

    Hresconstruct = figure;
    set(Hresconstruct,'WindowStyle','docked');
    Ireconstruct = Retroprojection_shared(I , X_m , z_out ,theta,M0,Hresconstruct);
    ylim([0 Prof])
    cb = colorbar;
    ylabel(cb,'a.u')
    colormap(parula)
    set(findall(Hresconstruct,'-property','FontSize'),'FontSize',15) 
    
    % RetroProj_cleaned(Alphas,Datas,SampleRate*1e6);
    % back to original folder 
    
        case 'OS'
     Datas = RetreiveDatas(raw,NTrig,Nlines,1:size(ScanParam,1));
     NbElemts = system.probe.NbElemts ;
     pitch = system.probe.Pitch ; 
     X_m = (1:NbElemts)*(pitch*1e-3) ;
     z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
     x = ScanParam(:,2);
     
    imagesc(x,z*1e3,1e3*Datas)   
    xlabel('order N_x')
    zlabel('z(mm)')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
   
    MyImage = OS(Datas,ScanParam(:,1),ScanParam(:,2),...
                 dFx,z,SampleRate*1e6,c,[X0 X1]*1e-2) ; 
   
             
             %% resolution par ifourier
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
    
 

    
    
    end



    %ylim([0 50])
 
   
%% save datas :
if SaveData == 1
    
MainFolderName = 'D:\Data\Mai';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Lens5cm_1paper';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'Foc',Foc,'type',TypeOfSequence);
savefig(Hmu,FileName);
saveas(Hmu,FileName,'png');

switch TypeOfSequence
    case 'OF'
        if SaveRaw == 0
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','pitch','NbElemts','x','z','Datas_mu','Datas_std','SampleRate','c','Range','TypeOfSequence','t_aquisition');
        else
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','pitch','NbElemts','x','z','raw','SampleRate','c','Range','TypeOfSequence','t_aquisition');            
        end
          
          case 'OP'
save(FileName,'Volt','DelayLAWS','ActiveLIST','FreqSonde','NbHemicycle','Alphas'...
              ,'X0','X1','NTrig','Nlines','Prof','ScanParam','pitch','NbElemts','x','z','Datas','SampleRate','c','Range','TypeOfSequence','t_aquisition');
%saveas(Hresconstruct,[FileName,'_retrop'],'png');
    case 'OS'
        if SaveRaw == 0
save(FileName,'Volt','DelayLAWS','ActiveLIST','FreqSonde','pitch','NbElemts','NbHemicycle','Alphas','decimation','dFx'...
                  ,'X0','X1','NTrig','Nlines','Prof','ScanParam','z','Datas_mu','Datas_std','SampleRate','c','Range','TypeOfSequence','t_aquisition');
        else
save(FileName,'Volt','DelayLAWS','ActiveLIST','FreqSonde','pitch','NbElemts','NbHemicycle','Alphas','decimation','dFx'...
                  ,'X0','X1','NTrig','Nlines','Prof','ScanParam','z','raw','SampleRate','c','Range','TypeOfSequence','t_aquisition');    
        end
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
% rmpath('D:\AO---softwares-and-developpement\radon inversion\shared functions folder');
