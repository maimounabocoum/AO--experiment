function [I,X,Z] = Reconstruct(NbX,NbZ,NUX,NUZ,x,z,Datas,SampleRate,durationWaveform,c,pitch)
% all inputs are in SI units
dx_fourier = abs(max(x) - min(x)) ;

        [NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
        Nfrequencymodes = length(NUX(:));
        XLambda = (durationWaveform*1e-6)*1e3*c;

            % each line is the exponential for NBz
            % integrale is performed between 2*XLambda and 5*XLambda
            ExpFunc                          =   exp(2*1i*pi*(NUZ(:)*z));
            ExpFunc( : , z <= 2*XLambda )    =   0;
            ExpFunc( : , z > 5*XLambda  )    =   0;
            
            %imagesc(z,1:Nfrequencymodes,real( ExpFunc) );
            
            % projection of fourrier composants:
            Cnm = conj(diag(ExpFunc*Datas))' ;
   
               
        DecalZ  =   0.9; % ??
        NtF     =   2^10;
        
% Variables

NtFs = NtF/2+1; % index of 0 in fourier domain
tF = zeros(NtF);

for nbs = 1:Nfrequencymodes
    
    s = exp(2i*pi*DecalZ*NBZ(nbs));
    
    tF( NtFs+NBZ(nbs), NtFs+NBX(nbs) ) = -conj(1j*s*Cnm(nbs));
    tF( NtFs-NBZ(nbs), NtFs-NBX(nbs) ) = -s*1j*Cnm(nbs);
    
end

%        figure;
%        set(gcf,'WindowStyle','docked');
%        imagesc(abs(tF));
%        title('fourier transform I')
%        xlabel('Nz')
%        ylabel('Ny')
       
I = ifft2(fftshift(tF));
I = I - ones(NtF,1)*I(1,:);

X = (0:NtF-1)*pitch*128/NtF;

Z = (0:NtF-1)*durationWaveform*1.54/NtF;
