function addPathLegHAL( varargin )

[pwd,~,~]=fileparts(mfilename('fullpath'));

% remote libs
if nargin >= 1
    addpath( [ pwd '/lib/libRemote' varargin{1} ] )
else
    addpath( [ pwd '/lib/libRemoteV9' ] )
end

% matlab packages
if isdir( [ pwd '/src' ] )
	addpath( [ pwd '/src' ] )
else
	addpath( [ pwd '/bin' ] )
end

% % beamforming libs
% addpath( [ pwd '/lib/popeRubi' ] )
% addpath( [ pwd '/lib/beamformerCuda' ] )
