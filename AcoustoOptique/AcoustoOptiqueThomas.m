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

        TypeOfSequence  = 'BAS'; % 'OP','OS','JM','OC','OFJM', 'BAS', 'BAS_SYNC'
        Bacules         = 'on';
        Master          = 'on';
        GageActive      = 'on' ; 
        Volt            = 15; %Volt
        seq_time        = 20e-6; % Sequence duration in s

        % 2eme contrainte : 
        % soit FreqSonde congrue à NUZ0 , soit entier*FreqSonde = NUech(=180e6)
        FreqSonde       = 6; % MHz AO : 78 et 84 MHz to be multiple of 6
        FreqSonde       = 180/round(180/FreqSonde); %MHz
        NbHemicycle     = 100 ;

        AlphaM          = 0; %(-20:20)*pi/180; specific OP


        % the case NbX = 0 is automatically generated, so NbX should be an
        % integer list > 0
        NbZ         = 2;    % [6,1:5];        % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0 ;    % [-10:10];        % 20    Nb de composantes de Fourier en X, 'JM'
        Phase       = 0; % phases per frequency in 2pi unit

        % note : Trep  = (20us)/Nbz
        %        NUrep =   Nbz*(50kHz)         

        % on choisira DurationWaveform telle que DurationWaveform*(180MHz)

        DurationWaveform = 20; % fundamental temporal duration

        % contrainte : 
        % soit un multiple de 180 MHz
        n_low = round( 180*DurationWaveform );
        NU_low = (180)/n_low;    % fundamental temporal frequency

        Tau_cam          = 200 ; % camera integration time (us)

        Foc             = 99; % mm
        X0              = 0;  % 19.2
        X1              = 40;
        step            = 1;     % in mm
        TxWidth         = 40;

        Frep            =  max(2,100) ; % in Hz
        NTrig           = 2000;             % repeat 2 time not allowed
        Prof            = (1e-3*1540)*1000; % last digits in us 
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
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof, NTrig,Frep,'on');
%[SEQ,Delay,ScanParam,Alphas] = AOSeqInit_OP_arbitrary(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , dA , X0 , X1 ,Prof, NTrig);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , NbX , X0 , X1 ,Prof, NTrig );
    case 'JM'
Volt = min(Volt,20) ; 
 [SEQ,ActiveLIST,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OJMLusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam , Phase , Frep , Bacules , Master );
%[SEQ,MedElmtList,NUX,NUZ,nuX0,nuZ0] = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform,Master);
    case 'OFJM'
Volt = min(Volt,20) ; 
 [SEQ,ActiveLIST,dX0,nuZ0,NUZ,ParamList] = AOSeqInit_OFJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , NbZ , X0 , X1 , TxWidth ,step , NTrig ,NU_low,Tau_cam , Phase , Frep , Master );
%[SEQ,MedElmtList,NUX,NUZ,nuX0,nuZ0] = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform,Master);

    case 'OC'
Volt = min(Volt,15) ; 
[SEQ,MedElmtList,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OC(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 , NTrig , DurationWaveform , Tau_cam );

    case 'BAS'
        Volt = min(Volt, 15);
        [SEQ,ActiveLIST,nuX0,nuZ0,NUX,NUZ] = AOSeqInit_Bas(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam , Phase , Frep , Bacules , Master, seq_time);
end


c = common.constants.SoundSpeed ; % sound velocity in m/s

 % SEQ = SEQ.startSequence();
%% view sequence GUI
fprintf('============================= SEQ ANALYSIS =======================\n');

Nactive = 1;

% total number of sequences :
Nevent = length(SEQ.InfoStruct.event);
fprintf('Total number of event is %d\n',Nevent);

NbElemts    = system.probe.NbElemts ; 
if strcmp(Bacules,'on')
SampFreq    = (system.hardware.ClockFreq)/2 ;
else
SampFreq    = system.hardware.ClockFreq ;    
end


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


%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress



%%
pause(1);

if strcmp(GageActive,'on')
     SampleRate    =   50;
     Range         =   2; %Volt
Nlines = length(SEQ.InfoStruct.event);    
[ret,Hgage,acqInfo,sysinfo,transfer] = InitOscilloGage(NTrig*Nlines,Prof,SampleRate,Range,'on');
% input on gageIntit: 'on' to activate external trig, 'off' : will trig on timout value
raw   = zeros(acqInfo.Depth,acqInfo.SegmentCount);

%%%%%%%%%%%%%%%%%%%  lauch gage acquisition %%%%%%%%%%%%%%%%%%%

 ret = CsMl_Capture(Hgage);

 CsMl_ErrorHandler(ret, 1, Hgage);
 status = CsMl_QueryStatus(Hgage);
 %SEQ = SEQ.startSequence();


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
figure;imagesc(raw)
colormap(parula)

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
% SaveData        = 1; % set to 1 to save
% 
% h       = 6.6e-34;
% lambda  = 780e-9;
% Ephoton = h*(3e8/lambda);
 Frep    = 100; %Hz
 Pmain = 9;
 Pref = 2;
 AcoustoOptiqueDATA_ANALYSES;

% save datas :
SaveData = 1;
if SaveData == 1

MainFolderName = 'D:\Data\Fevrier_Thomas';
SubFolderName  = generateSubFolderName(MainFolderName);
CommentName    = 'Interf';%RefOnly_100Hz_noFilter
FileName       = generateSaveName(SubFolderName ,'name',CommentName);
% savefig(Hmu,FileName);
% saveas(Hmu,FileName,'png');

save(FileName,'Volt','FreqSonde','NbHemicycle','Foc'...
              ,'X0','X1','NTrig','Nlines','Prof','Frep','ActiveLIST','Pref','NbElemts','t1','t2','raw','Pmain','SampleRate','c','Range','TypeOfSequence','Bacules');

fprintf('Data has been saved under : \r %s \r\n',FileName);


end

