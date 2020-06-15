%% -- run when first launching program

%    clear all; clc
%    w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %

 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\AO--commons\read and write files')



        Master          = 'on';
        WriteLogFile    = 'off';
        Volt            = 10; %Volt
        SaveData        = 0 ; % set to 1 to save
        Frep            =  max(2,100) ; % in Hz
        NTrig           = 2;             % repeat 2 time not allowed
        Prof            = (1e-3*1540)*150; % last digits in us 
        


%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress



     SampleRate    =   50;
     Range         =   2; %Volt
     c = 1540;

[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig,Prof,c,SampleRate,Range,'on');
% input on gageIntit: 'on' to activate external trig, 'off' : will trig on timout value
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);

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

t = (1e6/acqInfo.SampleRate)*(1:size(raw,1));
figure(3); plot(t,raw)
title('PD manip MG - collimated  - AO manip MG not Focused in AO')
xlabel('time(\mu s)')
ylabel('Volt')
set(findall(gcf,'-property','FontSize'),'FontSize',15) 
% ======================== data post processing =============================

 % AcoustoOptiqueDATA_ANALYSES;

% save datas :

if SaveData == 1
    
MainFolderName = 'D:\Data\Mai';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'ScanJ0_Water';%RefOnly_100Hz_noFilter
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'Fus',FreqSonde,'Volt',Volt);
% savefig(Hmu,FileName);
% saveas(Hmu,FileName,'png');

save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','Frep','ActiveLIST','Pref','NbElemts','t1','t2','raw','Pmain','SampleRate','c','Range','TypeOfSequence','Bacules');

fprintf('Data has been saved under : \r %s \r\n',FileName);


end

