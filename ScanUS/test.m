
%% testing plan interpolation and view results
clearvars;

x = (-15:15) ; % horizontal axis (1) in mm
y = (-1:0.1:1) ; % horizontal axis (2) in mm
z = (0:-1:-65);           % horizontal axis (3) in mm
    
N = 2^5 ;
Naverage = 1;

% give list of 3 points (the order does not matter) to define the plane
% DefinePlane = [ X1 , Y1 , Z1 ; X2 , Y2 , Z2 ; X3 , Y3 , Z3 ]
PointsCoordinates = [0 0 0;...
                    10 10 1;...
                    0 10 1];
PointOrigine = [0,0,0]; % origine of rotation plane 

MyScan = USscan(x,y,z,Naverage,N);
R = MyScan.DefineRotationMatrix(PointsCoordinates,PointOrigine,'z');
MyScan.ShowRotatedPlane(R,PointOrigine)

%%