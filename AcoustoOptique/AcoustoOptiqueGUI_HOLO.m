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
 
       TypeOfSequence = 'OP';   % 'OF' , 'JM'
        Master      = 'off'; 
        Volt        = 20;       % 'OF' , 'OP' , 'JM'
        FreqSonde   = 6;        % 'OF' , 'OP' , 'JM'
        NbHemicycle = 500;      % 'OF' , 'OP' , 'JM'
        Foc         = 23;       % 'OF' 
        AlphaM      = 20;       % 'OP' 
        dA          = 1;        % 'OP' 
        X0          = 0;        % 'OF' , 'OP' 
        X1          = 50 ;      % 'OF' , 'OP' 
        NTrig       = 5000;     % 'OF' , 'OP' , 'JM'
        Prof        = 200;      % 'OF' , 'OP' , 'JM'
        NbZ         = 8;        % 8; % Nb de composantes de Fourier en Z, 'JM'
        NbX         = 0;        % 20 Nb de composantes de Fourier en X, 'JM'
        DurationWaveform = 20;  % length in dimension x (us)
        
        AIXPLORER_Active = 'on';% 'on' or 'off' 

 % estimation of loading time 
 fprintf('%i events, loading should take about %d seconds\n\r',(2*NbX+1)*NbZ,(2*NbX+1)*NbZ*3);

%% ============================   Initialize AIXPLORER
% %% Sequence execution
% % ============================================================================ %
if strcmp(AIXPLORER_Active,'on')
    
switch TypeOfSequence
    case 'OF'
NbHemicycle = min(NbHemicycle,15);
[SEQ,MedElmtList] = AOSeqInit_OF(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc, X0 , X1 , Prof, NTrig);
    case 'OP'
NbHemicycle = min(NbHemicycle,15);
[SEQ,MedElmtList,AlphaM] = AOSeqInit_OP(AixplorerIP, Volt , FreqSonde , NbHemicycle , AlphaM , X0 , X1 ,Prof, NTrig,Master);
    case 'JM'                       
Volt = min(Volt,20) ; 
[SEQ,MedElmtList,NUX,NUZ] = AOSeqInit_OJM(AixplorerIP, Volt , FreqSonde , NbHemicycle , NbX , NbZ , X0 , X1 ,Prof, NTrig,DurationWaveform,Master);

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
  

    
    
