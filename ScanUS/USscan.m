classdef USscan
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x       % scanning vector
        y       % scanning vector
        z       % scanning vector
        Positions
        Nscans
        Naverage       % averaging per position
        Npoints        % Number of points / aquisition line
        
        Datas
    end
    
    methods
        function obj =  USscan(x,y,z,Naverage,Npoints)
            
            % empty Data inituialization
            Nx = max(length(x),1);
            Ny = max(length(y),1);
            Nz = max(length(z),1);
            obj.Nscans = Nx*Ny*Nz ;
            
            % initialisation of properties
            obj.x = x ;
            obj.y = y ;
            obj.z = z ;
            x = 0:1:2  ; % horizontal axis (1)
            y = 0:1:2  ;  
            z = 0:2;    % vertical axis   (2)
            [X,Y,Z] = meshgrid(x,y,z);
            test =[X(:),Y(:),Z(:)]
            
            % switch even values from matrix
            
            % snale order for scan
            obj.Positions = [X(:),Y(:),Z(:)];
            
            
            obj.Naverage = Naverage ;
            obj.Npoints  = Npoints  ;
            

            obj.Datas = zeros(obj.Npoints,obj.Nscans) ;
        end

    end
    
end

