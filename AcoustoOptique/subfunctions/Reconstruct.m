function [I,X,Z] = Reconstruct(NbX,NbZ,NUX,NUZ,x,z,Datas,SampleRate,durationWaveform,c,nuX0,nuZ0)
% all inputs are in SI units

        Origin_Z = 25;
    %    Origin_Z = 20;

        [NBX,NBZ] = meshgrid(NbX,NbZ);
        Nfrequencymodes = length(NUX(:));
        XLambda = 1/nuZ0;
        XLambda_min = (1*XLambda+Origin_Z);
        XLambda_max = (3*XLambda+Origin_Z);

            % each line is the exponential for NBz
            % integrale is performed between 2*XLambda and 5*XLambda
            ExpFunc                          =   exp(2*1i*pi*NUZ(:)*(z-Origin_Z) );
            ExpFunc( : , z <= XLambda_min )    =   0;
            ExpFunc( : , z > XLambda_max  )    =   0;
            
            %imagesc(z,1:Nfrequencymodes,real( ExpFunc) );
            
            % projection of fourrier composants:
            Cnm = conj(diag(ExpFunc*Datas))' ;
               
        DecalZ  =   1.4; % ??
        NtF     =   2^10;
        F = TF2D(NtF,(NtF-1)*nuX0,(NtF-1)*nuZ0);
        dF = nuX0 ;
        Fmax = (NtF/2)*dF;
        dx = 1e-3/abs(2*Fmax) ;
        
% Variables

NtFs = NtF/2+1; % index of 0 in fourier domain
tF = zeros(NtF);

for nbs = 1:Nfrequencymodes
    
    s = exp(2i*pi*DecalZ*NBZ(nbs));
    
    tF( NtFs+NBZ(nbs), NtFs+NBX(nbs) ) = -conj(1j*s*Cnm(nbs));
    tF( NtFs-NBZ(nbs), NtFs-NBX(nbs) ) = -s*1j*Cnm(nbs);
    
end
 

       figure(50);
       set(gcf,'WindowStyle','docked');
       imagesc(abs(tF));
       %surf(angle(tF));
       %surf(abs(tF));
       title('fourier transform I')
       xlabel('Ny')
       ylabel('Nz')
 
%tF = abs(tF).*exp(1i*angle(I_fft));
%I = F.ifourier(tF);

I = ifft2(fftshift(tF));
I = I - ones(NtF,1)*I(1,:);
I = ifftshift(I,2);

%X = (-NtF/2:(NtF/2-1))*dx;
 X = F.x;
 Z = F.z;
% Z = (0:NtF-1)*durationWaveform*1.54/NtF;
