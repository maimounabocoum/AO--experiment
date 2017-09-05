% clear all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end
% restoredefaultpath % restaure original path

%% parameter for plane wave sequence :
% ======================================================================= %

% adresse Bastille : '192.168.0.20'
% adresse Jussieu :  '192.168.1.16'


 AixplorerIP    = '192.168.0.20'; % IP address of the Aixplorer device
 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\legHAL');
 addPathLegHAL();
 
        TypeOfSequence  = 'OF';
        Volt            = 20;
        FreqSonde       = 4;
        NbHemicycle     = 10;
        Foc             = 23;
        AlphaM          = 10;
        dA              = 1;
        X0              = 0;
        X1              = 38;
        NTrig           = 10;
        Prof            = 80;
        SaveData        = 0 ; % set to 1 to save data


                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ MedElmtList
switch TypeOfSequence
    case 'OF'
[SEQ,MedElmtList] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
[SEQ,MedElmtList,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
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
    SEQinfosPrint( SEQ )        % printout SEQ infos
    
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
    
    tic 
    SEQ = SEQ.stopSequence('Wait', 0);
    SEQ = SEQ.startSequence('Wait',0);
    
  
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
    
    SEQ = SEQ.stopSequence('Wait', 0);  
    
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
%     axis equal
%     axis tight
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
        case 'OP'
    Datas = RetreiveDatas(raw,NTrig,Nlines,MedElmtList);
    z = (1:actual.ActualLength)*(c/(1e6*SampleRate));
    imagesc(Alphas,z*1e3,1e3*Datas)
    xlabel('angle (°)')
    ylabel('z (mm)')
    title('Averaged raw datas')
    cb = colorbar;
    ylabel(cb,'AC tension (mV)')
    colormap(parula)
    set(findall(Hf,'-property','FontSize'),'FontSize',15) 
    
    %%  Radon inversion :
%       currentFolder = pwd ;
%     % path to radon inversion folder
%       cd('D:\GIT\AO---softwares-and-developpement\radon inversion')
%        
%     Iradon = OPinversionFunction(Alphas*pi/180,z,Datas,SampleRate*1e6,c);
%     % RetroProj_cleaned(Alphas,Datas,SampleRate*1e6);
%     % back to original folder 
    cd(currentFolder)
    %%
    end



    ylim([0 40])
 
   
%% save datas :
if SaveData == 1
MainFolderName = 'D:\Data\mai\';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'SacherPVAtuyauMain91mV_x2';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'wavelength',764);


save(FileName,'Volt','FreqSonde','NbHemicycle','Foc','AlphaM','dA'...
              ,'X0','X1','NTrig','Nlines','Prof','MedElmtList','raw','SampleRate','c','Range','TypeOfSequence');
savefig(Hf,FileName);
saveas(Hf,FileName,'png');

fprintf('Data has been saved under : \r %s \r\n',FileName);

end

%% ================================= command line to force a trigger on Gage :
%  CsMl_ForceCapture(Hgage);
%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote();
%               ret = CsMl_FreeAllSystems;
%% ======================================== remove search paths =======
% rmpath('D:\legHAL');
% rmpath('subfunctions');
% rmpath('sequences');
