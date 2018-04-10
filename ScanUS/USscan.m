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
        function obj =  USscan(x,y,z,Naverage,Npoints,Nevents)
            
            
            
            % empty Data inituialization
            Nx = max(length(x),1);
            Ny = max(length(y),1);
            Nz = max(length(z),1);
            obj.Nscans = Nx*Ny*Nz ;

            
            % initialisation of properties
            obj.x = x ;
            obj.y = y ;
            obj.z = z ;

           
            
                
            %making plan (X,Y) scan
            if mod(Ny,2)==0
                % parity
            X = repmat([x(:);flipud(x(:))], Ny/2 , 1 )  ;
            Y = repmat(y(:)',Nx,1);
            XY = [X(:),Y(:)] ;
            
            else

            X = [ x(:) ; repmat( [flipud(x(:)) ; x(:) ], (Ny-1)/2 , 1 ) ]  ;
            Y = repmat(y(:)',Nx,1);
            XY = [X(:),Y(:)] ; 
            
            end
            
            % making full (X,Y,Z) box
            if mod(Nz,2)==0
            
                XYZ = repmat( [XY;flipud(XY)] , Nz/2 , 1 );
                Z = repmat(z(:)',Nx*Ny,1);
                XYZ = [XYZ,Z(:)];
                
            else
                XYZ = [ XY ; repmat( [flipud(XY);XY] , (Nz-1)/2 , 1 ) ];
                Z = repmat(z(:)',Nx*Ny,1);
                XYZ = [XYZ,Z(:)];               
                
            end
            
            
            obj.Positions = XYZ ;
            obj.Naverage = Naverage ;
            obj.Npoints  = Npoints  ;
            

            obj.Datas = zeros(obj.Npoints,obj.Nscans) ;
        end

    end
    
end

