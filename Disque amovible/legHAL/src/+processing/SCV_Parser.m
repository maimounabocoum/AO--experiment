function double_array = SCV_Parser(parameters)

double_array(1) = 0 ;%double(parameters.ScanconversionType) ;
double_array(2) = 0 ;
double_array(3) = double(parameters.SecondPass) ;
double_array(4) = double(parameters.NR) ;
double_array(5) = double(parameters.NTheta) ;
double_array(6) = double(parameters.AngleOfFirstLine) ;
double_array(7) = double(parameters.AngleStep) ;
double_array(8) = double(parameters.FirstSampleAxialPosition) ;
double_array(9) = double(parameters.RadialStep) ;
double_array(10) = double(parameters.OffSetX) ;
double_array(11) = double(parameters.OffSetZ) ;
double_array(12) = double(parameters.SizeOfImgX) ;
double_array(13) = double(parameters.SizeOfImgZ) ;
double_array(14) = double(parameters.ComputeOffSetAndSize) ;
double_array(15) = double(parameters.Nx) ;
double_array(16) = double(parameters.Nz) ;
double_array(17) = double(parameters.NbVois) ;
double_array(18) = double(parameters.SmoothDistance) ;

double_array(2) = double(length(double_array));