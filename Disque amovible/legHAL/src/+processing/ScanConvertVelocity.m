function Data = ScanConvertVelocity(BFStruct,xPush,velocityPolar,Nx,Nz)


angProbePitch = system.probe.Pitch/system.probe.Radius ;
lambda = 1e-3*processing.ExtractLutParam(BFStruct.Lut(1).data,'SoundSpeed')/processing.ExtractLutParam(BFStruct.Lut(1).data,'DemodFrequ') ;

parameters.NR = size(velocityPolar,1);
parameters.NTheta = size(velocityPolar,2);

parameters.Nx = Nx ;
parameters.Nz = Nz ;

parameters.AngleOfFirstLine = double(BFStruct.Lut(1).ReconAbsc(1))*angProbePitch - xPush/system.probe.Radius ;
parameters.AngleStep = angProbePitch*processing.ExtractLutParam(BFStruct.Lut(1).data,'LinePitch');
parameters.FirstSampleAxialPosition = system.probe.Radius + processing.ExtractLutParam(BFStruct.Lut(1).data,'ZOrigin');
parameters.RadialStep = processing.ExtractLutParam(BFStruct.Lut(1).data,'PitchPix')*lambda;
parameters.OffSet = zeros(2,1, 'double');
parameters.SizeOfImg = zeros(2,1, 'double');
parameters.NbVois = 1 ;
parameters.SmoothDistance = lambda/2;
parameters.SecondPass = 0 ;
parameters.OffSetX = 0 ;
parameters.OffSetZ = 0 ;
parameters.SizeOfImgX = 0 ;
parameters.SizeOfImgZ = 0 ;
parameters.ComputeOffSetAndSize = 1 ;



lutsize = zeros(1,'int32');

parameters_array = processing.SCV_Parser(parameters) ;
processing.ScanConversionTable(parameters_array,lutsize);

parameters.OffSetX = parameters_array(10);
parameters.OffSetZ = parameters_array(11);
parameters.SizeOfImgX = parameters_array(12);
parameters.SizeOfImgZ = parameters_array(13);

NbVoistot = (parameters.NbVois*2)^2 ;

parameters.SecondPass = 1 ;
LUT_coeff = zeros(lutsize*NbVoistot,1, 'single');
LUT_X = zeros(lutsize,1, 'int16');
LUT_Z = zeros(lutsize,1, 'int16');
LUT_Vois1 = zeros(lutsize*NbVoistot,1, 'int16');
LUT_Vois2 = zeros(lutsize*NbVoistot,1, 'int16');

processing.ScanConversionTable(processing.SCV_Parser(parameters),LUT_coeff,LUT_X,LUT_Z,LUT_Vois1,LUT_Vois2,lutsize);

Data.XAxis = parameters.OffSetX + (0:(parameters.Nx-1))*parameters.SizeOfImgX/(parameters.Nx-1) ;
Data.ZAxis = parameters.OffSetZ + (0:(parameters.Nz-1))*parameters.SizeOfImgZ/(parameters.Nz-1) ;

Data.velocity = zeros(parameters.Nz,parameters.Nx,size(velocityPolar,3),'single');

OUT = zeros(parameters.Nx,parameters.Nz,'single');
for k=1:size(velocityPolar,3)
    IN = single(squeeze(velocityPolar(:,:,k))');
        processing.ScanConvertLin(LUT_coeff,LUT_X,LUT_Z,LUT_Vois1,LUT_Vois2,parameters.NbVois,lutsize,IN,OUT);
        Data.velocity(:,:,k) = OUT' ;
end