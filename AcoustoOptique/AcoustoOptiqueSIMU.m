%% -- run when first launching program

%    clear all; clc
%    w = instrfind; if ~isempty(w) fclose(w); delete(w); end
%   restoredefaultpath % restaure original path

%% addpath and parameter for wave sequences :
% ======================================================================= %

% adresse Bastille : '192.168.0.20'
% adresse Jussieu :  '192.168.1.16'

 AixplorerIP    = '192.168.1.16'; % IP address of the Aixplorer device
 % path at Jussieu :
 if strcmp(AixplorerIP,'192.168.1.16')
 addpath('D:\AO--commons\shared functions folder')
 end
 addpath('gui');
 addpath('sequences');
 addpath('subfunctions');
 addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl')
 addpath('D:\AO--commons\read and write files')
 addpath('D:\_legHAL_Marc')
 addPathLegHAL;
 % 'OP' : Ondes Planes
 % 'OS' : Ondes Structurées
 % 'JM' : Ondes Jean-Michel
 % 'OC' : Ondes Chirpées
 
        TypeOfSequence  = 'JM'; % 'OP','OS','JM','OC'
        Master          = 'on';
        GageActive      = 'on' ; 
        Volt            = 15; %Volt
        % 2eme contrainte : 
        % soit FreqSonde congrue à NUZ0 , soit entier*FreqSonde = NUech(=180e6)
        FreqSonde       = 6; %MHz AO : 78 et 84 MHz to be multiple of 6
        FreqSonde       = 180/round(180/FreqSonde); %MHz
        NbHemicycle     = 10 ;
        
        AlphaM          = 0; %(-20:20)*pi/180; specific OP

        
        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        NbZ         = 0;        % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;        % 20 Nb de composantes de Fourier en X, 'JM'
        Phase       = 0; % phases per frequency in 2pi unit

        % note : Trep  = (20us)/Nbz
        %        NUrep =   Nbz*(50kHz)         
        
        % on choisira DurationWaveform telle que DurationWaveform*(180MHz)
        
        DurationWaveform = 20;
        
        % contrainte : 
        % soit un multiple de 180 MHz
        n_low = round( 180*DurationWaveform );
        NU_low = (180)/n_low;   % fundamental temporal frequency
        
        Tau_cam          = 500 ;% camera integration time (us)
        
        Foc             = 5; % mm
        X0              = 0; %0-40
        X1              = 40;
        
        NTrig           = 1000;
        Prof            = (1e-3*1540)*100; % last digits in us 
        SaveData        = 0 ; % set to 1 to save

%% default parameters for user input (used for saving)
[nuX0,nuZ0] = EvalNu0( X0 , X1 , NU_low );      


%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
clear SEQ ScanParam raw Datas ActiveLIST Alphas Delay Z_m
switch TypeOfSequence
    case 'OF'
Volt = min(50,Volt); % security for OP routine  
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
Volt = min(50,Volt); % security for OP routine       
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof, NTrig,'on');
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , NbX , X0 , X1 ,Prof, NTrig);
    case 'JM'
Volt = min(Volt,20) ; 
 [SEQ,ActiveLIST,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OJMLusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam , Phase ,Master);
%[SEQ,MedElmtList,NUX,NUZ,nuX0,nuZ0] = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform,Master);
 
    case 'OC'
Volt = min(Volt,15) ; 
[SEQ,MedElmtList,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OC(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 , NTrig ,DurationWaveform,Tau_cam);

end


c = common.constants.SoundSpeed ; % sound velocity in m/s

%% view sequence GUI
fprintf('============================= SEQ ANALYSIS =======================\n');

Nactive = 1;

% total number of sequences :
Nevent = length(SEQ.InfoStruct.event);
fprintf('Total number of event is %d\n',Nevent);

NbElemts    = system.probe.NbElemts ; 
SampFreq    = system.hardware.ClockFreq ;

% emission block event evaluated on Nactive over NbElemts transducers
WaveF = SEQ.InfoStruct.tx(Nactive).waveform(:,1:NbElemts) ;
figure;
imagesc( 1:NbElemts , (1:size(WaveF,1))/SampFreq , WaveF )
colormap(parula)
cb = colorbar;
ylabel(cb,'Logic Tension ')
xlabel('N element Index')
ylabel('Emission Time ( \mu s)')
title(['shot Number = ',num2str(Nactive)])

SEQ.InfoStruct.event(Nactive).duration

%% write log file to share between applications (Labview) as csv format

% list of data type : isDataType
% isfloat H:\
% islogical
% isstring
SubFolderNameLocal         = generateSubFolderName('D:\Data\Mai');  % localhost save
SubFolderNameHollande      = generateSubFolderName('Z:\Mai');       % 10.10.10.36 - holland save
FileNameLocal_csv          = [SubFolderNameLocal,'\LogFile.csv'];
FileNameHollande_csv       = [SubFolderNameHollande,'\LogFile.csv'];

%  fid = fopen(FileName_txt,'w');
%  [rows,cols]=size(ParamList);
 
%  fprintf(fid,'%s\n','=========== begin header in SI units ========');
%  fprintf(fid,'TypeOfSequence : %s \n',TypeOfSequence);
%  fprintf(fid,'Volt           : %f \n',Volt);
%  fprintf(fid,'FreqSonde      : %E \n',FreqSonde*1e6);
%  fprintf(fid,'NbHemicycle    : %f \n',NbHemicycle);
%  fprintf(fid,'Tau_cam        : %E \n',Tau_cam*1e-6);
%  fprintf(fid,'DurWaveform    : %E \n',DurationWaveform*1e-6);
%  fprintf(fid,'Prof           : %E \n',Prof*1e-3);
%  fprintf(fid,'Nevent         : %i \n',Nevent);
%  fprintf(fid,'NTrig          : %i \n',NTrig);
%  fprintf(fid,'X0             : %E \n',X0*1e-3);
%  fprintf(fid,'X1             : %E \n',X1*1e-3);
%  fprintf(fid,'Foc            : %E \n',Foc*1e-3); %nuX0,nuZ0
 
 HearderCell(:,1) = {'TypeOfSequence';TypeOfSequence};
 HearderCell(:,2) = {'Volt';Volt};
 HearderCell(:,2) = {'FreqSonde';FreqSonde*1e6};
 HearderCell(:,3) = {'NbHemicycle';NbHemicycle};
 HearderCell(:,4) = {'Tau_cam';Tau_cam};
 HearderCell(:,5) = {'DurWaveform';DurationWaveform*1e-6};
 HearderCell(:,6) = {'Prof';Prof*1e-3};
 HearderCell(:,7) = {'Nevent';Nevent};
 HearderCell(:,8) = {'NTrig';NTrig};
 HearderCell(:,9) = {'X0'; X0};
 HearderCell(:,10) = {'nuX0'; nuX0};
 HearderCell(:,11) = {'nuZ0'; nuZ0};
 
 FinalCell = joincell( HearderCell , ParamList ) ;

 cell2csv(FileNameLocal_csv,  FinalCell , ';' ,'2015' ,'.' ) ;
 cell2csv(FileNameHollande_csv,  FinalCell , ';' ,'2015' ,'.' ) ;
%fwritecell('exptable.txt',ParamList);

%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

if strcmp(GageActive,'on')
     SampleRate    =   10;
     Range         =   2; %Volt
Nlines = length(SEQ.InfoStruct.event);    
[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,'on');
% input on gageIntit: 'on' to activate external trig, 'off' : will trig on timout value
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);

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
    
end
%
%  Get system status
%  Msg    = struct('name', 'get_status');
%  Status = remoteSendMessage(SEQ.Server, Msg);
%  Status.rfsequencetype
% 
%  Msg = struct('name', 'start_stop_sequence', 'start', 1);
%  Status = remoteSendMessage(SEQ.Server, Msg)

%  SEQ = SEQ.startSequence();
%  SEQ = SEQ.stopSequence('Wait',0);

% ======================== data post processing =============================
SaveData        = 0 ; % set to 1 to save

h = 6.6e-34;
lambda = 780e-9;
Ephoton = h*(3e8/lambda);

if strcmp(GageActive,'on')

    %
    Hmu = figure;
    set(Hmu,'WindowStyle','docked');

    [Datas_mu1,Datas_std1,Datas_mu2,Datas_std2] = AverageDataBothWays( raw/(0.45*1e5) );

    t = (1:actual.ActualLength)*(1/SampleRate);
    NbElemts = system.probe.NbElemts ;
    pitch = system.probe.Pitch ; 
    x = 1:(Nlines*NTrig) ;
    
    subplot(223)
    %imagesc(1:size(raw,2),t,1e6*raw/(0.45*1e5))
    imagesc(1:size(raw,2),t,1e6*raw/(0.45*1e5))
    xlabel('index')
    ylabel('time (\mu s)')
    cb = colorbar;
    ylabel(cb,'\mu W')
    colormap(parula)
    
    subplot(221)
    line(1:length(Datas_std1),1e6*Datas_std1,'Color','r'); hold on 
    line(1:length(Datas_std1),1e6*sqrt(Ephoton*(10e6)*Datas_mu1),'Color','r');hold off
    ylabel('\sigma (\mu W)over short ')
    xlabel('index')
    ylim([0.05 0.5])
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
    ax1_pos = get(ax1,'Position'); % position of first axes
    ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
    line(t,1e6*Datas_std2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\sigma (nW) over long')
    xlabel('time (\mu s)')
    
    subplot(222)
    line(1:length(Datas_std1),1e6*Datas_mu1,'Color','r'); hold on 
    ylabel('\mu (\mu W)over short ')
    xlabel('index')
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
    ax1_pos = get(ax1,'Position'); % position of first axes
    ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
    line(t,1e6*Datas_mu2,'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    ylabel('\mu (\mu W)over  long')
    xlabel('time (\mu s)')

    subplot(224)
    [freq1 , psdx1 ] = CalculateDoublePSD( raw , 10e6 );
    [freq2 , psdx2 ] = CalculateDoublePSD( raw' , 100e3 );
    line(freq1*1e-6,10*log10(10e6*psdx1),'Color','r')
    ylim([-52 -40])
    xlabel('Frequency (MHz)')
    ylabel('Power/Frequency (dB/MHz)')
    ax1 = gca; % current axes
    set(ax1,'XColor','r');
    set(ax1,'YColor','r');
ax1_pos = get(ax1,'Position'); % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');
    line(freq2*1e-3,10*log10(100e3*psdx2),'Parent',ax2,'Color','k')
    set(ax2,'Ylim',get(ax1,'Ylim'));
    xlabel('Frequency (kHZ)')
    ylabel('Power/Frequency (dB/kHz)')
    
%  
end
PmuW = 0;
% autosave

% save datas :
if SaveData == 1
    
MainFolderName = 'D:\Data\Mai';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Signal_CH1CH2';
FileName       = generateSaveName(SubFolderName ,'name',CommentName,'RepHz',100);
savefig(Hmu,FileName);
saveas(Hmu,FileName,'png');

save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','ActiveLIST','pitch','NbElemts','x','t','raw','SampleRate','c','Range','TypeOfSequence','PmuW');

fprintf('Data has been saved under : \r %s \r\n',FileName);


end

