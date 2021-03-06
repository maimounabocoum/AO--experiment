%   clear all; clc
%   w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%  restoredefaultpath % restaure original path

%% parameter for plane wave sequence :
% ======================================================================= %

% adresse Bastille : '192.168.0.20'
% adresse Jussieu :  '192.168.1.16'


 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 
        TypeOfSequence  = 'OF';
        Volt            = 40;
        FreqSonde       = 3;
        NbHemicycle     = 3;
        
        
        AlphaM          = 20;
        dA              = 1;
        
        Foc             = 13;
        X0              = 19.8;
        X1              = 20;
        
        NTrig           = 1000;
        Prof            = 30;
        SaveData        = 0 ; % set to 1 to save


                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ MedElmtList raw Datas
switch TypeOfSequence
    case 'OF'
[SEQ,MedElmtList] = AOSeqInit_OFL(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
Volt = min(30,Volt); % security for OP routine       
[SEQ,Delay,MedElmtList,ActiveLIST,Alphas] = AOSeqInit_OPL(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
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
[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,GageActive);

raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    
   

 
    %% ======================== start acquisition =============================
    SequenceDuration_us = 100 ; 
    Nloop = 100 ;
    
    
 for Iloop = 1:Nloop
            
    SEQ = SEQ.stopSequence('Wait', 0);
    
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    tic 
    
    SEQ = SEQ.startSequence();
    
    status = CsMl_QueryStatus(Hgage);
    
    tasks2execute = 0 ; 
    while status ~= 0 && tasks2execute < NTrig*(SequenceDuration_us/50)*20000
        status = CsMl_QueryStatus(Hgage);
        tasks2execute = tasks2execute + 1; % increment to exit loop in case Gage would not trig
    end
    
    CsMl_ErrorHandler(ret, 1, Hgage);
    SEQ = SEQ.stopSequence('Wait', 0);  
 
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
    
    
    
    % ======================== data post processing =============================
    Hf = figure(100);
    set(Hf,'WindowStyle','docked');
    
    switch TypeOfSequence
        case 'OF'
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate))*1e3;
    x = MedElmtList*system.probe.Pitch;
    %imagesc(x,z,1e3*Datas)
    plot(z,1e3*Datas)
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
%     imagesc(Alphas,z*1e3,1e3*Datas)
%     xlabel('angle (�)')
%     ylabel('z (mm)')
%     title('Averaged raw datas')
%     cb = colorbar;
%     ylabel(cb,'AC tension (mV)')
%     colormap(parula)
%     set(findall(Hf,'-property','FontSize'),'FontSize',15)

    %  Radon inversion :
    addpath('D:\GIT\AO---softwares-and-developpement\radon inversion\shared functions folder');
    % plotting delay map
        for i = 1:length(SEQ.InfoStruct.tx)
          Z_m(i,:) =   -(SEQ.InfoStruct.tx(i).Delays(1:192))*c*1e-6 ;
        end
    % path to radon inversion folder 
    [theta,M0] = EvalDelayLaw_shared((1:192)*0.2*1e-3,Z_m,ActiveLIST);    
    Retroprojection_shared( Datas , find(ActiveLIST(:,1))*(system.probe.Pitch*1e-3), z ,theta ,M0,Hf);
    set(findall(Hf,'-property','FontSize'),'FontSize',15)
    %%
    end
 end   
%% save datas :
if SaveData == 1
MainFolderName = 'D:\Data\mai\';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'AgarWaterANDintralipide';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'TypeOfSequence',TypeOfSequence,'Ntrig',NTrig,'Volt',Volt);
save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','AlphaM','dA'...
              ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','Datas','SampleRate','c','Range','TypeOfSequence');
% save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','AlphaM','dA'...
%               ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','raw','SampleRate','c','Range','TypeOfSequence');
savefig(Hf,FileName);
saveas(Hf,FileName,'png');
if strcmp(TypeOfSequence,'OP')
    % saving reconstructed image
saveas(Hretroprojection,[FileName,'_retrop'],'png');
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
