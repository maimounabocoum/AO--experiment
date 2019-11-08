function [freq , psdx ] = CalculateDoublePSD( raw , Fs )
%Created by maimouna bocoum - 07-11-2019
%% test to see o raw as the rigth number of column :
   
N               = size(raw,1);
XDFT            = fft(raw);
XDFT            = XDFT(1:N/2+1,:);
PSDX            = (1/(Fs*N))*abs(XDFT).^2;
PSDX(2:end-1,:) = 2*PSDX(2:end-1,:);
freq            = 0:Fs/N:Fs/2 ;



psdx = mean(PSDX,2);

end

