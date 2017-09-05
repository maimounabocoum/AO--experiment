function [I X Y]=Reconstruct(tDum,NbX,NbZ,SampleRate,DecalZ,NtF,durationWaveform,c)

% Variables
c = c/1000;         % conversion m/s en mm/us
NtFs = NtF/2;
NtFd = 2*NtF;
tF = zeros(NtF);    % fourier transform

[NBX,NBZ] = meshgrid(-NbX:NbX,1:NbZ);
Nfrequencymodes = length(NBX(:));
for nbs = 1:Nfrequencymodes
    s = exp(2i*pi*DecalZ*NBZ(nbs));
    tF(NtFs+1+NBZ(nbs),NtFs+1+NBX(nbs)) = -conj(1j*s*tDum(nbs));
    tF(NtFs+1-NBZ(nbs),NtFs+1-NBX(nbs)) = -s*1j*tDum(nbs);
end;

I = ifft2(fftshift(tF));
I = I - ones(NtF,1)*I(1,:);

X = (0:NtF-1)*0.2*128/NtF;
Y = (0:NtF-1)*20*1.54/NtF;
