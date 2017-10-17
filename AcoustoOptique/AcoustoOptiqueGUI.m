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
 
        TypeOfSequence  = 'OF';
        Volt            = 40;
        FreqSonde       = 3;
        NbHemicycle     = 4;
        
        
        AlphaM          = 20;
        dA              = 10;
        
        Foc             = 20;
        X0              = 5;
        X1              = 35;
        
        NTrig           = 200;
        Prof            = 40;
        SaveData        = 1 ; % set to 1 to save


                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ MedElmtList raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
[SEQ,MedElmtList] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
Volt = min(50,Volt); % security for OP routine       
 [SEQ,Delay,MedElmtList,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
%[SEQ,Delay,MedElmtList,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);

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

    toc
    
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
    
    % ======================== data post processing =============================
    Hf = figure;
    set(Hf,'WindowStyle','docked');
    
    switch TypeOfSequence
        case 'OF'
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    x = MedElmtList*system.probe.Pitch;
    imagesc(x,z,1e3*Datas)
    xlabel('x (mm)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
        case 'OP'
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
    imagesc(Alphas*180/pi,z*1e3,1e3*Datas)
    xlabel('angle (�)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    %%  Radon inversion :
    Hresconstruct = figure;
    set(Hresconstruct,'WindowStyle','docked');
    % plotting delay map
    for i = 1:size(Delay,1)
      Z_m(i,:) =   -Delay(i,:)*c*1e-6 ;
    end
    
    MyImage = OP(Datas,Alphas,z,SampleRate*1e6,c) ;
    [I,z_out] = DataFiltering(MyImage) ;
    
    [theta,M0] = EvalDelayLaw_shared((1:192)*0.2*1e-3,Z_m,ActiveLIST);    
    Retroprojection_shared( I , find(ActiveLIST(:,1))*(system.probe.Pitch*1e-3), z_out ,theta ,M0,Hresconstruct);
    % RetroProj_cleaned(Alphas,Datas,SampleRate*1e6);
    % back to original folder 
    
    %%
    end



    %ylim([0 50])
 
   
%% save datas :
if SaveData == 1
    
MainFolderName = 'D:\Data\JM\';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'AgarREF';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'Volt',Volt);
savefig(Hf,FileName);
saveas(Hf,FileName,'png');

switch TypeOfSequence
    case 'OF'
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','x','z','Datas','SampleRate','c','Range','TypeOfSequence');
    case 'OP'
save(FileName,'Volt','Delay','FreqSonde','NbHemicycle','Alphas'...
              ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','x','z','Datas','SampleRate','c','Range','TypeOfSequence');

          saveas(Hresconstruct,[FileName,'_retrop'],'png');
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
