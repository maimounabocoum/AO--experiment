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
     SaveData        = 1 ;              % set to 1 to save
     Frep            =  max(2,500) ;    % Reptition frequency from DG645 Master ( Hz )
     NTrig           = 44;            % repeat 2 time not allowed 
     SampleRate      =   25e6;            % Gage sampling frequency in Hz (option: [50,25,10,5,2,1,0.5,0.2,0.1,0.05])
     Range           =   0.5;             % Gage dynamic range Volt (option: 5,2,1,0.5,0.2,0.1)
     Offset_gage     = 400; % Vpp in mV
     Npoint          = 50000 ;           % number of point for single segment
     c = 1540;

[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig,Npoint,SampleRate,Range,'on',Offset_gage);
% input on gageIntit: 'on' to activate external trig, 'off' : will trig on timout value
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);

Npoint      = acqInfo.Depth;      % SI unit
SampleRate  = acqInfo.SampleRate; % SI unit

%%%%%%%%%%%%%%%%%%%  lauch gage acquisition %%%%%%%%%%%%%%%%%%%

 ret = CsMl_Capture(Hgage);
 
 pause(1)
 
%  SEQ = SEQ.startSequence();
  
  
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
    

figure(1); imagesc(raw)
colormap(parula)

t = (1e6/acqInfo.SampleRate)*(1:size(raw,1));
figure(3); plot(t,raw)
% title('PD manip MG - collimated  - AO manip MG not Focused in AO')
% xlabel('time(\mu s)')
% ylabel('Volt')
% set(findall(gcf,'-property','FontSize'),'FontSize',15) 

% ======================== data post processing =============================

 AcoustoOptiqueDATA_ANALYSES;

% save datas :
Fs1 = 0;
Fs2 = 0;
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
start_index=12760;
width=110e-6;
raw2=(raw-min(raw(:)));
figure(1)
plot(raw2(:,1))
% figure(2)
raw_tronc=raw2(start_index:start_index+width*acqInfo.SampleRate,:);
% plot(t(start_index:start_index+width*acqInfo.SampleRate),raw_tronc(:,1))
figure(4)

integ = sum(raw_tronc,1);
integ_tronc= integ(4:end);

plot(integ_tronc/integ_tronc(1),'r')
% hold on
% data = importdata('Z:\Louis\2021-01-14\RefOnly_modZ_exp19.dat');

% figure(4)
% data_tronc = data(4:end,1);
% plot(data_tronc./data_tronc(1))
hold on

data2 = importdata('Z:\Louis\2021-01-18\1moyennage44shots.dat');

% figure(4)
data_tronc2 = data2(4:end,1);
plot(data_tronc2./data_tronc2(1),'g')
%ylim([0.98,1.04])
legend('photodiode','CCD')
%%
data = importdata('Z:\Louis\2021-01-14\scanUs_On_modZ_exp100.dat');
dataoff = importdata('Z:\Louis\2021-01-14\scanUs_Off_modZ_exp100.dat');
figure(6)
plot(data(5:end,1))
hold on
plot(dataoff(5:end,1),'r')
legend('US on','US off')



