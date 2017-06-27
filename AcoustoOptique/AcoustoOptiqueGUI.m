% clear all; close all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end

%% parameter for plane wave sequence :
% ======================================================================= %
 AixplorerIP    = '192.168.0.20'; % IP address of the Aixplorer device
 addpath('D:\legHAL');
 addPathLegHAL();
 
        Volt        = 50;
        FreqSonde   = 3;
        NbHemicycle = 10;
        Foc         = 23;
        AlphaM      = 20;
        dA          = 1;
        X0          = 0;
        X1          = 38 ;
        NTrig       = 200;
        Prof        = 10;
        TypeOfSequence = 'OF';
        SaveData = 0 ; % set to 1 to save data


                 

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %

switch TypeOfSequence
    case 'OF'
SEQ = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
%SEQ = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0 , NTrig);
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
     
 Nlines = length(SEQ.InfoStruct.event);    
[ret,Hgage,acqInfo,sysinfo] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,GageActive);
fprintf(' Segments last %4.2f us \n\r',1e6*acqInfo.SegmentSize/acqInfo.SampleRate);

% Set transfer parameters
transfer.Mode           = CsMl_Translate('Default', 'TxMode');
transfer.Start          = -acqInfo.TriggerHoldoff;
transfer.Length         = acqInfo.SegmentSize;
transfer.Channel        = 1;

    raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);
    
   
    ret = CsMl_Capture(Hgage);
    CsMl_ErrorHandler(ret, 1, Hgage);
 
    %% ======================== start acquisition =============================
    tic 
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
    
    Datas = RetreiveDatas(raw,NTrig,Nlines);
    Hf = figure;
    
    set(Hf,'WindowStyle','docked');
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

   
   SEQ = SEQ.stopSequence('Wait', 0);  
   
%% save datas :
if SaveData == 1
MainFolderName = 'D:\Data\mai';
%SubFolderName  = generateSubFolderName();
FileName       = generateSaveName(SaveFolderName,'Volt',Volt);

save('MyDatas','Volt','FreqSonde','NbHemicycle','Foc','AlphaM','dA'...
              ,'X0','X1','NTrig','Prof');

        Volt        = 30;
        FreqSonde   = 10;
        NbHemicycle = 10;
        Foc         = 23;
        AlphaM      = 20;
        dA          = 1;
        X0          = 0;
        X1          = 38 ;
        NTrig       = 200;
        Prof        = 40;
end

%% ================================= command line to force a trigger on Gage :
%  CsMl_ForceCapture(Hgage);
%% ================================= quite remote ===========================================%%
%               SEQ = SEQ.quitRemote();

