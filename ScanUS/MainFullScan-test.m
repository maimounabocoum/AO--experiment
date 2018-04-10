%% scan box delimitation
x = 76 ; % horizontal axis (1)
y = 0     ;
z = 40;    % vertical axis   (2)

Naverage = 1 ;
Npoints = 500 ;

% creation of new Scan structure :

MyScan = USscan(x,y,z,Naverage,Npoints);


    %% ======================== start acquisition =============================
    
    
    for n_scan = 1:MyScan.Nscans
        
        % clear buffer and look for errors
        GetLastError(Controller,'1');
        GetLastError(Controller,'2');
        if(Controller.BytesAvailable>0)
            fscanf(Controller, '%s')  
        end
        
        
        % move to position
        % position x
        posX = MyScan.Positions(n_scan,1);
        PolluxDepAbs(Controller,posX,'1')
        %position y
        posY = MyScan.Positions(n_scan,2);
        % no motor associated
        
        % position z
        posZ = MyScan.Positions(n_scan,3);
        PolluxDepAbs(Controller,posZ,'2')
        
        
        
        % read position and update scan position list
        posX = GetPosition(Controller,'1') ;
        posZ = GetPosition(Controller,'2') ;
        
        % print current position
        disp(sprintf('Scan position X:%f,Y:%f,Z:%f',posX,posY,posZ));
        
        % update position inside scan sctucture
        MyScan.Positions(n_scan,1) = posX ;
        MyScan.Positions(n_scan,2) = posZ ;
        
        % acquire data
        
        %pause(1)
       
        
    end
    

 