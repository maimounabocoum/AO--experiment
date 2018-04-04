%%% parameters sheet %%%

%% scan box delimitation
x = 0:5:10  ;
y = 0     ;
z = 0:1;

Naverage = 1 ;
Npoints = 500 ;

%% creation of new Scan structure :

MyScan = USscan(x,y,z,Naverage,Npoints);

