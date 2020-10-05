classdef CAMscan
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        x       % scanning vector
        y       % scanning vector
        z       % scanning vector
        Positions
        Nscans
        Naverage       % averaging per position
        camera    % camera structure
        
        Datas
    end
    
    methods
        
        function ShowRotatedPlane(obj,R,PointOrigine)
        
       % perform rotation
       
       PointOrigine = repmat(PointOrigine(:),1,obj.Nscans);
       Positions = obj.Positions' - PointOrigine ;
       Positions = (R*Positions + PointOrigine)' ;
            
        %figure;
        scatter3(obj.Positions(:,1),...
                 obj.Positions(:,3),...
                 obj.Positions(:,2),'filled')
        
        hold on
             
        scatter3(Positions(:,1),...
                 Positions(:,3),...
                 Positions(:,2),'filled')
        xlabel(' x (mm)')
        ylabel(' z (mm)')
        
        
        set (gca,'Ydir','reverse')
        set (gca,'Xdir','reverse')
        zlabel(' y (mm)')
        axis equal
        view([65.6624    8.1364])   
        
        zlim([-max(abs(Positions(:,2))) , max(abs(Positions(:,2)))])
        hold off
        end
        
        function R = DefineRotationMatrix(obj,Points,FixedPoint,HorizontalPlane)
            
            if sum(size(Points)==[3,3])~= 2 
            % check that rotation Points has the right dimension
            error('ploblem with the number of input point used for the rotation'); 
            return;
            end
            if sum(size(FixedPoint)) ~= 4                 
            error('ploblem with the dimension of fixed point'); 
            return;
            end
            P1 = Points(1,:) - Points(1,:); % defines origine in P1
            P2 = Points(2,:) - Points(1,:);
            P3 = Points(3,:) - Points(1,:);
            normal = cross(P1-P2, P1-P3);
            
            % calculate coefficient of plane equation
            a = dot(normal, [1,0,0]-P1);
            b = dot(normal, [0,1,0]-P1);
            c = dot(normal, [0,0,1]-P1);
            
            switch HorizontalPlane
                case 'x'
            % rotation where x is invariant 
            sinTheta = -(b/c)/sqrt(1+(b/c)^2);
            cosTheta = 1/sqrt(1+(b/c)^2);
            Rx = [1 0 0 ;0 cosTheta -sinTheta; 0 sinTheta cosTheta];
            Ry = [1 0 0; 0 1 0; 0 0 1]; 
                case 'y'
            % rotation where x is invariant 
            sinTheta = -(b/c)/sqrt(1+(b/c)^2);
            cosTheta = 1/sqrt(1+(b/c)^2);
            Rx = [1 0 0 ;0 cosTheta -sinTheta; 0 sinTheta cosTheta];
            Ry = [1 0 0; 0 1 0; 0 0 1];
                case 'z'
            % rotation where x is invariant 
            %sinTheta = -(b/c)/sqrt(1+(b/c)^2);
            %cosTheta = 1/sqrt(1+(b/c)^2);
            Theta = atan(-(b/c));
            Rx = [1 0 0 ;0 cos(Theta) -sin(Theta); 0 sin(Theta) cos(Theta)];
            %Rx = [1 0 0 ;0 cosTheta -sinTheta; 0 sinTheta cosTheta]
            %sinTheta = -(c/a)/sqrt(1+(c/a)^2);
            %cosTheta = 1/sqrt(1+(c/a)^2);
            Theta =atan(-(a/c));
            Ry = [cos(Theta) 0 -sin(Theta);0 1 0;sin(Theta) 0 cos(Theta)];
            %Ry = [cosTheta 0 sinTheta;0 1 0;-sinTheta 0 cosTheta]
            end
            
            R = Rx*Ry ;

            
            
        end
             
        function Plane = DefineRotationPlane(obj,Points,FixedPoint)
            
            if sum(size(Points)==[3,3])~= 2 
            % check that rotation Points has the right dimension
            error('ploblem with the number of input point used for the rotation'); 
            return;
            end
            if sum(size(FixedPoint)) ~= 4                 
            error('ploblem with the dimension of fixed point'); 
            return;
            end
            P1 = Points(1,:) - Points(1,:);
            P2 = Points(2,:) - Points(1,:);
            P3 = Points(3,:) - Points(1,:);
            normal = cross(P1-P2, P1-P3);
            
            Plane = normal;     
            
            %Next, we declare x, y, and z to be symbolic variables, 
            % create a vector whose components represent the vector 
            % from P1 to a typical point on the plane, and compute 
            % the dot product of this vector with our normal. 
            syms X Y Z
            P = [X,Y,Z];
            pretty(dot(normal, P-P1));
            
            a = dot(normal, [1,0,0]-P1);
            b = dot(normal, [0,1,0]-P1);
            c = dot(normal, [0,0,1]-P1);

            
            
        end
        
        function obj =  CAMscan(x,y,z,Naverage,camera)
            
            
            
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
            obj.Naverage  = Naverage ;
            obj.camera    = camera  ;
            
         % Datas contains only results for memory space constraint
         
         SizeScan_X = round((1e-3)*( max(x(:)) - min(x(:)) )/camera.dpixel) + camera.Nx_cam ;
         SizeScan_Y = round((1e-3)*( max(y(:)) - min(y(:)) )/camera.dpixel)  + camera.Ny_cam ;
         
            obj.Datas = zeros(SizeScan_Y,SizeScan_X) ;
        end
        
       
        function [x,y] = GetXYcoordinate(obj,zin)
            
        % extract all coordinate matching input z value.
        I_zin = find( abs(obj.Positions(:,3) - zin ) < 1e-6 );
        %I_zin = find( obj.Positions(:,3) == zin );
        
        % extract corresponding X values
        x = obj.Positions(I_zin,1);
        %[x,Isortx] = sort(X_zin);
        
        % extract corresponding X values
        y = obj.Positions(I_zin,2);
        %[y,Isorty] = sort(X_zin);
            
        end
        
        function obj = FillData( obj , n_scan , InputDatas )

        % get center position of current frame in data
        IcenterX = mm2pxIndex( obj.Positions(n_scan,1) , min(obj.x) , obj.camera.dpixel , obj.camera.Nx_cam ) ;
        IcenterY = mm2pxIndex( obj.Positions(n_scan,2) , min(obj.y) , obj.camera.dpixel , obj.camera.Ny_cam ) ;
        
        I_Y = (IcenterY - floor(obj.camera.Ny_cam/2)):(IcenterY - floor(obj.camera.Ny_cam/2) + obj.camera.Ny_cam - 1 ) ;
        I_X = (IcenterX - floor(obj.camera.Nx_cam/2)):(IcenterX - floor(obj.camera.Nx_cam/2) + obj.camera.Nx_cam - 1 ) ;
        
        obj.Datas( I_Y , I_X ) = InputDatas ; 
        
        end
    end
end
    
         function x_pixels = mm2pxIndex( x_mm , x_min , dx , Nx_cam)

          x_pixels = round((1e-3)*x_mm/dx) - round((1e-3)*x_min/dx) + floor(Nx_cam/2) + 1  ;
          
        end

