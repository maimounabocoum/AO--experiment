% clear all; close all; clc
% w = instrfind; if ~isempty(w) fclose(w); delete(w); end

%% parameter for plane wave sequence :
% ======================================================================= %
% adresse Jussieu : '192.168.1.16'
% adresse Bastille : '192.168.0.20'

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
 
       ypeOfSequence = 'JM';   %'OF'(focused waves) , 'OS' (plane structures waves), 
                                %'OP' (plane waves) , 'JM' (Jean-Michel waves)
        
        Master      = 'on';     % Aixplorer as Master ('on') of Slave ('off') with respect to trigger
        Volt        = 15;       % 'OF' , 'OS', 'OP' , 'JM'
        FreqSonde   = 6;        % 'OF' , 'OS', 'OP' , 'JM'
        NbHemicycle = 250;      % 'OF' , 'OS', 'OP' , 'JM'
        Foc         = 5;        % 'OF'
        AlphaM      = [-10,0,10]*pi/180;        % 'OP' list of angles in scan in Rad
        X0          = 0;        % 'OF' , 'OS', 'OP' , 'JM'
        X1          = 50 ;      % 'OF' , 'OS', 'OP' , 'JM'
        NTrig       = 50;       % 'OF' , 'OS', 'OP' , 'JM'
        Prof        = 300;      % 'OF' , 'OS', 'OP' , 'JM'
        decimation  = [8] ;     % 'OS'
        NbZ         = 8;        % 'JM' harmonic along z 
        NbX         = 0;        % 'JM' harmonic along x 
        Phase       = [0];        % 'JM' phases per frequency in 2pi unit
        Tau_cam          = 100 ;  % 'JM' camera integration time (us) : sets the number of repetition patterns
        Bacules         = 'off';  % 'JM' alternates phase to provent Talbot effect
        Frep            =  max(2,50) ;   % 'OF' , 'OS', 'OP' , 'JM'in Hz
        
        
        % 'JM' 
        DurationWaveform = 20;  % 'JM' fondamental time along t -- do not edit --
        % imposing that be a multiple of sampling period
        n_low = round( 180*DurationWaveform ); % -- do not edit --
        NU_low = (180)/n_low;                  % 'JM' fundamental temporal frequency in MHz -- do not edit --
        
        
        
        SaveData = 0;           % set to 1 to save data
        AIXPLORER_Active = 'on';% 'on' or 'off' 


 % estimation of loading time 
 fprintf('%i events, loading should take about %d seconds\n\r',(2*NbX+1)*NbZ,(2*NbX+1)*NbZ*3);

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
if strcmp(AIXPLORER_Active,'on')
    
switch TypeOfSequence
    case 'OF'
NbHemicycle = min(NbHemicycle,100);
[SEQ,ScanParam] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
NbHemicycle = min(NbHemicycle,100);
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM ,X0 , X1 ,Prof,NTrig ,Frep ,Master);
    case 'OS'
Volt = min(50,Volt); % security for OP routine     
[SEQ,DelayLAWS,ScanParam,ActiveLIST,Alphas,dFx] = AOSeqInit_OS(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , decimation , X0 , X1 ,Prof, NTrig,Frep,Master);   
    case 'JM'
Volt = min(Volt,20) ; 
% check the coordinate of this function

% sequence for Digital Holography
%[SEQ,ActiveLIST,nuX0,nuZ0,NUX,NUZ,ParamList] = AOSeqInit_OJMLusmeasure(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam , Phase , Frep , Bacules , Master );

% sequence for Photorefractive Crystal
[SEQ,MedElmtList,NUX,NUZ,nuX0,nuZ0]          = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,NTrig ,NU_low,Tau_cam ,  Frep , Bacules , Master );

end

end

c = common.constants.SoundSpeed ; % sound velocity in m/s

%%  ========================================== Init Gage ==================
% Possible return values for status are:
%   0 = Ready for acquisition or data transfer
%   1 = Waiting for trigger event
%   2 = Triggered but still busy acquiring
%   3 = Data transfer is in progress

        Nlines = (2*NbX+1)*NbZ ;
 


    %% ======================== LOAD =============================
     
         tic ;
         
         SEQ = SEQ.loadSequence();

         fprintf('Sequence has loaded in %f s \n\r',toc)
         display('--------ready to use -------------');
         

 
     
    %% ======================== START =============================

  
        SEQ = SEQ.startSequence('Wait',0);


    %% ======================== STOP =============================


        SEQ = SEQ.stopSequence('Wait', 0);  
  

    
    
