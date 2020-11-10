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
clearvars;
     SaveData        = 0 ;               % set to 1 to save
     Frep            =  max(2,100) ;     % Reptition frequency from DG645 Master ( Hz )
     NTrig           = 100;              % repeat 2 time not allowed 
     SampleRate    =   25e6;  % Gage sampling frequency in Hz (option: [10,50])
     Range         =   2;       % Gage dynamic range Volt (option: [2])
     Npoint          = 100 ;   % number of point for single segment
     c = 1540;

[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig,Npoint,SampleRate,Range,'on');
% input on gageIntit: 'on' to activate external trig, 'off' : will trig on timout value
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);

Npoint      = acqInfo.Depth;      % SI unit
SampleRate  = acqInfo.SampleRate; % SI unit
%%
%%%%%%%%%%%%%%%%%%%  lauch gage acquisition %%%%%%%%%%%%%%%%%%%

 ret = CsMl_Capture(Hgage);
 
 CsMl_ErrorHandler(ret, 1, Hgage);
 status = CsMl_QueryStatus(Hgage);
 
 while status ~= 0
  status = CsMl_QueryStatus(Hgage);
 end
    
    
    for SegmentNumber = 1:acqInfo.SegmentCount     
        transfer.Segment       = SegmentNumber;                     % number of the memory segment to be read
        [ret, datatmp, actual] = CsMl_Transfer(Hgage, transfer);    % transfer
                                                                    % actual contains the actual length of the acquisition that may be
                                                                    % different from the requested one.
       raw((1+actual.ActualStart):actual.ActualLength,SegmentNumber) = datatmp' ;       
    end
    

% figure(1); imagesc(raw)
% colormap(parula)

% t = (1e6/acqInfo.SampleRate)*(1:size(raw,1));
% figure(3); plot(t,raw)
% title('PD manip MG - collimated  - AO manip MG not Focused in AO')
% xlabel('time(\mu s)')
% ylabel('Volt')
% set(findall(gcf,'-property','FontSize'),'FontSize',15) 

% ======================== data post processing =============================

 AcoustoOptiqueDATA_ANALYSES;

% save datas :

if SaveData == 1
    
%MainFolderName = 'D:\Datas\Mai\';
MainFolderName = 'Z:\Mai\'; % Mapped network connection (sharing network needs to be on)
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Test_Ref_nofilter_100Hz_Mod_10mHz';%RefOnly_100Hz_noFilter_
FileName       = generateSaveName(SubFolderName ,'name',CommentName);
% savefig(Hmu,FileName);
% saveas(Hmu,FileName,'png');

save(FileName,'NTrig','Npoint','Frep','raw','SampleRate','c','Range','Fs1','Fs2');
fprintf('Data has been saved under : \r %s \r\n',FileName);

end

