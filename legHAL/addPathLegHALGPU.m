function addPathLegHAL( varargin )

% % version
% if nargin >= 1
%     addpath( [ pwd '/lib/libRemote' varargin{1} ] )
% else
%     addpath( [ pwd '/lib/libRemoteV5' ] )
% end
% 
% if isdir( [ pwd '/src' ] )
% 	addpath( [ pwd '/src' ] )
% else
% 	addpath( [ pwd '/bin' ] )
% end
% addpath( [ pwd '/remote/popeRubiBuild' ] )
% addpath( [ pwd '/remote/beamformerCuda' ] )

%% Windows
path = 'C:\Users\Mafalda\Documents\MATLAB\legHAL_03_10_13';
addpath( [ path '\lib\libRemoteV6' ] )
addpath( [ path '\src' ] )
addpath( [ path '\remote\popeRubiBuild' ] )
addpath([path '\remote\beamformerGPU\PhasedRF'])
addpath(['C:\Users\Mafalda\Documents\MATLAB\useful Functions'])
Sequence = usse.usse;
Sequence = Sequence.selectProbe
clear all

