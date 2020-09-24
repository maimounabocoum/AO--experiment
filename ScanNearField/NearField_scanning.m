%% include folders
addpath('Q:\AO--commons\shared functions folder');
addpath('Q:\AO--experiment\ScanUS\commands')

%% Fermeture et nettoyage de la memoire
PolluxClose(Controller,COM_Port);

%% connection to COM Port
close all
clear all

COM_Port   = 4 ;
Controller = PolluxOpenAndInitialize(COM_Port) ;

%% get axis number 
fprintf(Controller,['getaxisno']);
y = str2double(fscanf(Controller,'%s'));

%% set axis number 
fprintf(Controller,['2' 'setaxisno']);

%% emmergency stop motion
StopMotion(Controller,'1');
StopMotion(Controller,'2');

%% calibration commands
fprintf(Controller,['1','ncal']);
fprintf(Controller,['2','ncal']);
fprintf(Controller,['1','nrm']);
fprintf(Controller,['2','nrm']);

%% get position
GetPosition(Controller,'1');
GetPosition(Controller,'2');


%% Go to position zero : center of laser beam

    %% ======================== start acquisition =============================
% GetPosition(Controller,'1')
% GetPosition(Controller,'2')
MotorControl = 'off';    
x = [0:100] ;% + (-15:1:15) ; % horizontal axis (1) in mm
y = 0 ;
z = 0 ;% + (0:1:50);    % -30 vertical axis   (2) in mm , GetPosition(Controller,'2')
Naverage = 2;
MyCamera = camera('PCO.edge');
MyScan = CAMscan(x,y,z,Naverage,MyCamera);   


      for n_scan = 1:MyScan.Nscans
          
        % clear buffer and look for errors
        if strcmp(MotorControl,'on')
            
            GetLastError(Controller,'1');
            GetLastError(Controller,'2');
            if(Controller.BytesAvailable>0)
                fscanf(Controller, '%s')  
            end
            
        end
        
        % move to position
        % position x
        posX = MyScan.Positions(n_scan,1);
        if strcmp(MotorControl,'on')
        PolluxDepAbs(Controller,posX,'1')
        end
        % position y
        posY = MyScan.Positions(n_scan,2);
        if strcmp(MotorControl,'on')
        PolluxDepAbs(Controller,posY,'2')
        end
        
        % position z
        posZ = MyScan.Positions(n_scan,3);
        % no motor associated
        
        % read position and update scan position list
        if strcmp(MotorControl,'on')
        posX = GetPosition(Controller,'1') ;
        posY = GetPosition(Controller,'2') ;
        end
        
        % print current position
        fprintf('Scan position X:%f,Y:%f,Z:%f\n',posX,posY,posZ);
        
        % update position inside scan sctucture
        MyScan.Positions(n_scan,1) = posX ;
        MyScan.Positions(n_scan,2) = posY ;
        
        % acquire data
        
        MyScan = MyScan.FillData( n_scan , rand( MyCamera.Ny_cam, MyCamera.Ny_cam ) ) ;
        
      figure(1) 
      imagesc(MyScan.Datas);
      drawnow
      end
     
      
      %% data analysis
      
      %% save datas
    
  


















