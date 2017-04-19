function [ad, rho] = crosscorr_nonGPU4(RFdata1, Config)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RFdata1 is a 3D matrix (depth, width, time) containing beamformed RF data
% Config is a structure with two fields:
%                       -wsize: window size in pixels
%                       -wshift: window shift in pixels
% This is a table-sum based RF cross-correlation with cosine interpolation based on 
% Luo, Jianwen, and Elisa E. Konofagou,
% "A fast normalized cross-correlation calculation method for motion estimation." 
% Ultrasonics, Ferroelectrics and Frequency Control, IEEE Transactions on 57.6 (2010): 1347-1357.
% 
% but includes some modifications.  Notably, in this version, the normalized cross-correlation 
% is expected to be maximum at zero-lag, which means displacements must be
% small (typically less than 0.5 pixel). This makes the code much faster
% and allows a straightforward Matlab-based GPU implementation (also
% available). 
%
% Jean Provost is the copyright holder of all code below. Do not re-use without permission.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

wsize = (Config.wsize);
wshift = (Config.wshift);
[L1,L2,L3]=size(RFdata1);
% RFdata2 = RFdata1(:,:,2:end);
% RFdata1 = RFdata1(:,:,1:end-1);

sf = cat(1,zeros(1,L2,L3,'single'),cumsum(RFdata1.^2));

L3 = L3-1;
sfg = zeros(L1+1,L2,L3,3,'single');
%sg = sf(:,:,2:end);
%sf = sf(:,:,1:end-1);
% sg = cat(1,zeros(1,L2,L3),cumsum(RFdata2.^2));
sfg(:,:,:,3) = cat(1,zeros(1,L2,L3,'single'),cumsum(RFdata1(:,:,1:end-1).*cat(1,RFdata1(2:end,:,2:end),zeros(1,L2,L3,'single'))));
sfg(:,:,:,1) = cat(1,cumsum(RFdata1(:,:,1:end-1).*[zeros(1,L2,L3,'single');RFdata1(1:end-1,:,2:end)]),zeros(1,L2,L3,'single'));

sfg(:,:,:,2) = cat(1,zeros(1,L2,L3,'single'),cumsum(RFdata1(:,:,1:end-1).*RFdata1(:,:,2:end)));

clear RFdata1
j = (wsize/2+1+1):wshift:(L1-wsize/2-1);
NCC = (sfg(j+wsize/2,:,:,:)-sfg(j-wsize/2,:,:,:))./...
    sqrt((sf(j+wsize/2,:,1:end-1,ones(3,1))-sf(j-wsize/2,:,1:end-1,ones(3,1))).*(sf(j+wsize/2,:,2:end,ones(3,1))-sf(j-wsize/2,:,2:end,ones(3,1))));

% y0 = NCC(:,:,:,1);
% y1 = NCC(:,:,:,2);
% y2 = NCC(:,:,:,3);
% w0=acos((NCC(:,:,:,1)+NCC(:,:,:,3))./(2.*NCC(:,:,:,2)));
% theta=atan2(NCC(:,:,:,1)-NCC(:,:,:,3),2.*NCC(:,:,:,2).*sin(w0));
w0 = (NCC(:,:,:,1)+NCC(:,:,:,3))./(2.*NCC(:,:,:,2));
w0(w0>1.0) = 1;
% w0(w0<0)=0;
w0 = acos(w0);

ad = -(atan2(NCC(:,:,:,1)-(NCC(:,:,:,3)),2.*NCC(:,:,:,2).*real(sin(w0))))./w0;

% ad=-theta./(w0);
rho = NCC(:,:,:,2)./cos(atan2(NCC(:,:,:,1)-NCC(:,:,:,3),2.*NCC(:,:,:,2).*real(sin(w0))));
% rho=y1./cos(theta);

