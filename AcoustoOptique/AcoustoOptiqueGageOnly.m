%% -- run when first launching program

%    clear all; clc
%    w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %
 addpath('D:\AO--commons\shared functions folder')
 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\AO--commons\read and write files')


    
%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

% 4 Channels @ 50 MS/s, 14-bits,
% 1 GS Memory, 65 MHz Bandwidth
% AC/DC Coupling, 50Ω or 1MΩ Inputs
clearvars -except Mesure;
     SaveData       = 0 ;               % set to 1 to save
     modeIN         = 'Single' ;        % 'Single' : acquisition on signal channel 'Quad': acquisition on four channel
     Frep           =  max(2,100) ;     % Reptition frequency from DG645 Master ( Hz )
     NTrig          =  0.2;             % repeat 2 time not allowed 
     SampleRate     =  0.5e6;             % Gage sampling frequency in Hz (option: [50,25,10,5,2,1,0.5,0.2,0.1,0.05])
     Range          =  2;               % Gage dynamic range Volt (option: 5,2,1,0.5,0.2,0.1)
     Offset_gage    =  0;               % Vpp in mV
     Npoint         =  50000 ;           % number of point for single segment
     c = 1540;

[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig,Npoint,SampleRate,Range,'on',Offset_gage,modeIN);
% input on gageIntit: 'on' to activate external trig, 'off' : will trig on timout value
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);

Npoint      = acqInfo.Depth;      % SI unit
SampleRate  = acqInfo.SampleRate; % SI unit

%%%%%%%%%%%%%%%%%%%  lauch gage acquisition %%%%%%%%%%%%%%%%%%%

 ret = CsMl_Capture(Hgage);
 
 pause(1)
 
 CsMl_ErrorHandler(ret, 1, Hgage);
 status = CsMl_QueryStatus(Hgage);
 
 while status ~= 0
  status = CsMl_QueryStatus(Hgage);
 end
    

 % initialize size of raw matrix depending on the number of channels:
 switch acqInfo.Mode
     case 1
     raw = zeros(acqInfo.SegmentSize,acqInfo.SegmentCount) ; 
     case 2
     raw = zeros(acqInfo.SegmentSize,acqInfo.SegmentCount) ; 
     case 4
     raw = zeros(acqInfo.SegmentSize,acqInfo.SegmentCount,4) ; 
 end

 
 % transfer loop on all required channel
 for channel = 1:acqInfo.Mode
     
     transfer.Channel = channel;
     
    for SegmentNumber = 1:acqInfo.SegmentCount     
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one
       raw((1+actual.ActualStart):actual.ActualLength,SegmentNumber) = datatmp' ;       
    end
    
 end  

%% -------------------- plot acquisition

t = (1e6/SampleRate)*(1:Npoint); % time in us
figure(3); 
plot(t,mean(raw(:,:),2))
% title('PD manip MG - collimated  - AO manip MG not Focused in AO')
 xlabel('time(\mu s)')
 ylabel('Volt')
% set(findall(gcf,'-property','FontSize'),'FontSize',15) 

%% ======================== data post processing =============================

  AcoustoOptiqueDATA_ANALYSES;

%% --------------------------- save datas :
Fs1 = SampleRate ;     % gage sampling frequncy
Fs2 = Frep ;           % trigger repetition rate

if SaveData == 1
    
%MainFolderName = 'D:\Datas\Mai\';
MainFolderName = 'Z:\Mai\'; % Mapped network connection (sharing network needs to be on)
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'RefOnly_20210118';%RefOnly_100Hz_noFilter_
FileName       = generateSaveName(SubFolderName ,'name',CommentName);
% savefig(Hmu,FileName);
% saveas(Hmu,FileName,'png');

save(FileName,'NTrig','Npoint','Frep','raw','SampleRate','c','Range','Fs1','Fs2');
fprintf('Data has been saved under : \r %s \r\n',FileName);

end


%%


