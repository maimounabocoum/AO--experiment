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
 
        TypeOfSequence  = 'OP';
        Volt            = 40;
        FreqSonde       = 3;
        NbHemicycle     = 4;
        
        
        AlphaM          = 20;
        dA              = 1;
        
        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        NbX             = 1:5:10 ;     % 20 Nb de composantes de Fourier en X, 'JM'
        
        Foc             = 25;
        X0              = 0; %10-25
        X1              = 38;
        
        NTrig           = 800;
        Prof            = 40;
        SaveData        = 1 ; % set to 1 to save


                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ ScanParam raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
Volt = min(50,Volt); % security for OP routine  
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
Volt = min(50,Volt); % security for OP routine       
[SEQ,Delay,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,Delay,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , NbX , X0 , X1 ,Prof, NTrig);

end


c = common.constants.SoundSpeed ; % sound velocity in m/s
                    
%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress
     SampleRate    =   10;
     Range         =   1;
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
    SEQ = SEQ.stopSequence('Wait', 1);
    
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
    
    SEQ = SEQ.stopSequence('Wait', 1);  
    
    %% ======================== data post processing =============================
    Hf = figure;
    set(Hf,'WindowStyle','docked');
    
    switch TypeOfSequence
        case 'OF'
    Datas = RetreiveDatas(raw,NTrig,Nlines,ScanParam);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    x = ScanParam*system.probe.Pitch;
    imagesc(x,z,1e3*Datas)
    xlabel('x (mm)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
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
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    %%  Radon inversion :
    Hresconstruct = figure;
    set(Hresconstruct,'WindowStyle','docked');
    [MconvX,MconvY] = meshgrid(-10:10,10:10);
    Mconv = exp(-(MconvX.^2+MconvY.^2)/(2*5^2));
    %conv2(Datas,Mconv,'same')
    MyImage = OP(Datas,Alphas,z,SampleRate*1e6,c) ;
    [I,z_out] = DataFiltering(MyImage) ;
%     Xm = (1:system.probe.NbElemts)*(0.2e-3) ;
    Xm = (1:system.probe.NbElemts)*(system.probe.Pitch*1e-3) ;
    [theta,M0,X0,Z0] = EvalDelayLaw_shared(Xm,Delay,ActiveLIST,c);   
    
    Retroprojection_shared(I , Xm , z_out ,theta ,M0,Hresconstruct);
    % RetroProj_cleaned(Alphas,Datas,SampleRate*1e6);
    % back to original folder 
    
        case 'OS'
     Datas = RetreiveDatas(raw,NTrig,Nlines,1:size(ScanParam,1));
     z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
     x = ScanParam(:,2);
    imagesc(x,z*1e3,1e3*Datas)   
    xlabel('order N_x')
    zlabel('z(mm)')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    
    %  Fourier  Inversion :
    Hresconstruct = figure;
    set(Hresconstruct,'WindowStyle','docked');
     
%     [MconvX,MconvY] = meshgrid(-10:10,10:10);
%     Mconv = exp(-(MconvX.^2+MconvY.^2)/(2*0.5^2));
    % conv2(Datas,Mconv,'same')
    
    MyImage = OS(Datas,ScanParam(:,1),ScanParam(:,2),...
                 dFx,z,SampleRate*1e6,c) ; 
         
    MyImage.F_R = MyImage.fourierz( MyImage.R ) ;   
    [MyImage.F_R, MyImage.theta,MyImage.decimation] = MyImage.AddSinCos(MyImage.F_R) ;
    FTF = MyImage.GetFourier(MyImage.F_R,MyImage.decimation ) ;
    %figure; imagesc(MyImage.fx/MyImage.dfx,MyImage.fz/MyImage.dfz,abs(FTF) );   
    
    OriginIm = MyImage.ifourier(FTF) ;
    imagesc(MyImage.x*1e3 + mean([X0,X1]),MyImage.z*1e3,real(OriginIm));
    ylim([0 Prof])
    xlabel('x(mm)')
    ylabel('z(mm)')
    title('OS reconstruct')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hresconstruct,'-property','FontSize'),'FontSize',15) 
    
    
    end



    %ylim([0 50])
 
   
%% save datas :
if SaveData == 1
    
MainFolderName = 'D:\Data\Mai\';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Ref2inclusions';
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
