% clear all; close all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end

%% parameter for plane wave sequence :
% ======================================================================= %
% adresse Jussieu  : '192.168.1.16'
% adresse Bastille : '192.168.0.20'

 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device

 addpath('D:\AO--commons\shared functions folder')
 addpath('sequences');    
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 
       TypeOfSequence = 'JM';   %'OF'(focused waves) , 'OS' (plane structures waves), 
                                %'OP' (plane waves) , 'JM' (Jean-Michel waves)
        
        Master      = 'on';     % Aixplorer as Master ('on') of Slave ('off') with respect to trigger
        Volt        = 15;       % 'OF' , 'OS', 'OP' , 'JM'
        FreqSonde   = 6;        % 'OF' , 'OS', 'OP' , 'JM'
        NbHemicycle = 250;      % 'OF' , 'OS', 'OP' , 'JM'
        Foc         = 5;        % 'OF'
        AlphaM      = [-10,0,10]*pi/180;        % 'OP' list of angles in scan in Rad
        X0          = 0;        % 'OF' , 'OS', 'OP' , 'JM'
        X1          = 50 ;      % 'OF' , 'OS', 'OP' , 'JM'
        NTrig       = 50;       % 'OF' , 'OS', 'OP' , 'JM'
        Prof        = 300;      % 'OF' , 'OS', 'OP' , 'JM'
        decimation  = [8] ;     % 'OS'
        NbZ         = 8;        % 'JM' harmonic along z 
        NbX         = 0;        % 'JM' harmonic along x 
        Phase       = [0];        % 'JM' phases per frequency in 2pi unit
        Tau_cam          = 100 ;  % 'JM' camera integration time (us) : sets the number of repetition patterns
        Bacules         = 'off';  % 'JM' alternates phase to provent Talbot effect
        Frep            =  max(2,50) ;   % 'OF' , 'OS', 'OP' , 'JM'in Hz
        
        
        % 'JM' 
        DurationWaveform = 20;  % 'JM' fondamental time along t -- do not edit --
        % imposing that be a multiple of sampling period
        n_low = round( 180*DurationWaveform ); % -- do not edit --
        NU_low = (180)/n_low;                  % 'JM' fundamental temporal frequency in MHz -- do not edit --
        
        
        
        SaveData = 0;           % set to 1 to save data
        AIXPLORER_Active = 'on';% 'on' or 'off' 

 % estimation of loading time 
 fprintf('%i events, loading should take about %d seconds\n\r',length(NbX)*length(NbZ)*3);

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
if strcmp(AIXPLORER_Active,'on')
    
switch TypeOfSequence
    case 'OF'
NbHemicycle = min(NbHemicycle,100);
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
NbHemicycle = min(NbHemicycle,100);
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof,NTrig ,Frep ,Master);
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
     
     SampleRate    =   10;
     Range         =   1;
     GageActive = 'on' ; % on to activate external trig, off : will trig on timout value
     
    if strcmp(AIXPLORER_Active,'on') 
    Nlines = length(SEQ.InfoStruct.event);  
    else
    Nlines = (2*length(NbX)+1)*length(NbZ) ;
    end
 
[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig*Nlines,Prof,c,SampleRate,Range,GageActive);
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
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
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
    
        case 'OP'
    
    [Datas_mu,Datas_std, Datas_var] = RetreiveDatas(raw,NTrig,Nlines,ScanParam);
    % Datas_mu: average data
    % Datas_std: = data standard deviation
    % Datas_var: data variance
    
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
    
    
    % plot raw datas
    Hmu = figure;
    set(Hmu,'WindowStyle','docked');
    imagesc(Alphas*180/pi,z*1e3,1e3*Datas_mu)
    xlabel('angle (°)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hmu,'-property','FontSize'),'FontSize',15) 
    
    %  Load data to OP structure file :
    MyImage = OP(Datas_mu,Alphas,z,SampleRate*1e6,c) ;
    [I,z_out] = DataFiltering(MyImage) ;
    NbElemts = system.probe.NbElemts ;
    pitch = system.probe.Pitch ; 
    X_m = (1:NbElemts)*(pitch*1e-3) ;
    [theta,M0,X0,Z0] = EvalDelayLaw_shared(X_m,DelayLAWS,ActiveLIST,c); 

    %  iRadon inversion :
    Ireconstruct = Retroprojection_shared(I , X_m , z_out ,theta,M0,Hresconstruct);
    
    Hresconstruct = figure;
    set(Hresconstruct,'WindowStyle','docked');
    ylim([0 Prof])
    cb = colorbar;
    ylabel(cb,'a.u')
    colormap(parula)
    set(findall(Hresconstruct,'-property','FontSize'),'FontSize',15) 
    
    % RetroProj_cleaned(Alphas,Datas,SampleRate*1e6);
    % back to original folder 
    

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
MainFolderName = 'D:\Data\JM';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'SansEffetTalbotRepeat4_InclusionMiddle';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'NbZ',max(NbZ),'NbZ',max(NbX));
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','X0','X1',...
              'NTrig','Nlines','Prof','MedElmtList','Datas_mu','Datas_std',...
              'SampleRate','c','Range','TypeOfSequence','x','z',...
              'NbX','NbZ','NUX','NUZ','Master','DurationWaveform','nuX0','nuZ0','t_aquisition','raw');
% save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','AlphaM','dA'...
%               ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','raw','SampleRate','c','Range','TypeOfSequence');
savefig(Hf,FileName);
saveas(Hf,FileName,'png');

switch TypeOfSequence
    case 'OF'
saveas(Hf,FileName,'png');
    case 'JM'
saveas(Hfinal,FileName,'png');      
end

fprintf('Data has been saved under : \r %s \r\n',FileName);

end
%% ================================= command line to force a trigger on Gage :
%  CsMl_ForceCapture(Hgage);
%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote()      ;
%               ret = CsMl_FreeAllSystems   ;
