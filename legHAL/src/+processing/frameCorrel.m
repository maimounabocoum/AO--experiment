function phaseShift=frameCorrel(IQ,lag,AxialAveraging,LateralAveraging,display)

Nz = size(IQ,1);
Nx = size(IQ,2);
Nt = size(IQ,3);

A = ones(AxialAveraging,LateralAveraging)/LateralAveraging/AxialAveraging ;
phaseShift = zeros(Nz,Nx,Nt); 

for t=1:Nt-lag
        phaseShift(:,:,t) = -angle(filter2(A,IQ(:,:,t).*conj(IQ(:,:,t+lag))));
end

if display > 0
   figure
   for t=1:Nt-lag
        imagesc(phaseShift(:,:,t));
        caxis([-display display]);
        drawnow ;
        pause(1/10);
   end    
end
    