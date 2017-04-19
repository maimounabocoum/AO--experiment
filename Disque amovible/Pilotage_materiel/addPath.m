function addPath( varargin )

ici=[ pwd ];
addpath(ici);
%ici=[ pwd '/legHAL' ];
% version
if nargin >= 1
    addpath( [ ici varargin{1} ] )
else
    addpath( [ ici '/TiePie_Driver' ] )
end

% if isdir( [ ici '/src' ] )
% 	addpath( [ ici '/src' ] )
% else
% 	addpath( [ ici '/bin' ] )
% end
%addpath( [ ici '/remote/popeRubiBuild' ] )
%addpath( [ ici '/remote/beamformerCuda' ] )

