% clear all; close all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end

%% parameter for plane wave sequence :
% ======================================================================= %
% adresse Jussieu : '192.168.1.16'
% adresse Bastille : '192.168.0.20'

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
 
       TypeOfSequence = 'JM';   % 'OF' , 'JM'
 
        Volt        = 15;       % 'OF' , 'OP' , 'JM'
        FreqSonde   = 6;        % 'OF' , 'OP' , 'JM'
        NbHemicycle = 250;      % 'OF' , 'OP' , 'JM'
        Foc         = 23;       % 'OF' 
        AlphaM      = 20;       % 'OP' 
        dA          = 1;        % 'OP' 
        X0          = 12;        % 'OF' , 'OP' 
        X1          = 25 ;      % 'OF' , 'OP' 
        NTrig       = 100;      % 'OF' , 'OP' , 'JM'
        Prof        = 200;      % 'OF' , 'OP' , 'JM'
        NbZ         = 3;        % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;        % 20 Nb de composantes de Fourier en X, 'JM'
        DurationWaveform = 20;  % length in dimension x (us)
        
        SaveData = 1 ;          % set to 1 to save data
        AIXPLORER_Active = 'on';% 'on' or 'off' 

 % estimation of loading time 
 fprintf('%i events, loading should take about %d seconds\n\r',(2*NbX+1)*NbZ,(2*NbX+1)*NbZ*3);

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
if strcmp(AIXPLORER_Active,'on')
    
switch TypeOfSequence
    case 'OF'
NbHemicycle = min(NbHemicycle,15);
[SEQ,MedElmtList] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
NbHemicycle = min(NbHemicycle,15);
[SEQ,MedElmtList,AlphaM] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'JM'
Volt = min(Volt,20) ; 
[SEQ,MedElmtList,NUX,NUZ] = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform);

end

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
     GageActive = 'on' ; % on to activate external trig, off : will trig on timout value
     
    if strcmp(AIXPLORER_Active,'on') 
 Nlines = length(SEQ.InfoStruct.event);  
    else
        Nlines = (2*NbX+1)*NbZ ;
    end
 
[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,GageActive);

fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    

    %% ======================== start acquisition =============================
     
     if strcmp(AIXPLORER_Active,'on')
         
         tic
         SEQ = SEQ.loadSequence();

         fprintf('Sequence has loaded in %f s \n\r',toc)
         display('--------ready to use -------------');
         
     end
 
     
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    if strcmp(AIXPLORER_Active,'on')

%        SEQinfosPrint( SEQ )        % printout SEQ infos

        %SEQ = StartMySequence(SEQ);
        SEQ = SEQ.startSequence('Wait',0);
    
    end
%     % retreive received RF data 
%     buffer = SEQ.getData('Realign', 1);
%     figure
%     imagesc(double(mean(buffer.data,3)))
    
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
    
    if strcmp(AIXPLORER_Active,'on')

        SEQ = SEQ.stopSequence('Wait', 0);  
  
    end
    
    
%% ======================== data post processing =============================
    Hf = figure;
    set(Hf,'WindowStyle','docked');
    
    switch TypeOfSequence
        
        case 'OF'
            
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    x = (1:Nlines)*system.probe.Pitch;
    imagesc(x,z,1e3*Datas)
    xlabel('x (mm)')
    ylabel('z (mm)')



   case 'JM'
        MedElmtList = 1:Nlines ;
        Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
        % Calcul composante de Fourier
        z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
        x = (1:Nlines);
        
            imagesc(x,z,1e3*Datas)
            xlabel('lines Nbx, Nbz')
            ylabel('z (mm)')    
            title('Averaged raw datas')
            cb = colorbar;
            ylabel(cb,'AC tension (mV)')
            colormap(parula)
            set(findall(Hf,'-property','FontSize'),'FontSize',15)

       [I,X,Z] = Reconstruct(NbX , NbZ, ...
                             NUX , NUZ ,...
                             x , z , ...
                             Datas , ...
                             SampleRate , DurationWaveform, c , system.probe.Pitch*1e-3); 

       Hfinal = figure(101);
       set(Hfinal,'WindowStyle','docked');
       imagesc(X*1e3+mean([X0 X1]),Z,I);
       xlim([5 35])
       title('reconstructed image')
       xlabel('x (mm)')
       ylabel('z (mm)')
       cb = colorbar;
       ylabel(cb,'a.u')
       set(findall(Hfinal,'-property','FontSize'),'FontSize',15)
       
    end

    
 
   
%% save datas :
if SaveData == 1
MainFolderName = 'D:\Data\Francois\';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Verticale';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'NbZ',NbZ,'NbZ',NbX);
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','X0','X1',...
              'NTrig','Nlines','Prof','MedElmtList','Datas',...
              'SampleRate','c','Range','TypeOfSequence','x','z',...
              'NbX','NbZ','NUX','NUZ');
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
