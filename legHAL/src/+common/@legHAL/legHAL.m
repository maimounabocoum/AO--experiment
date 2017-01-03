% COMMON.LEGHAL
%   Class containing constant variables and static methods for the legHAL
%   package.
%
%   Constants:
%     - LEGHAL contains the version of the current legHAL package.
%
%   Methods:
%     - GETEXCEPTION builds an exception regarding the initial exception and add
%       an identifier to it.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/12/16

classdef legHAL
   
% ============================================================================ %
% ============================================================================ %

% Software constant
properties ( Constant = true )
    
    Version = '1.6.3'; % version of the legHAL package
    SupportedVersions = { '1.6.3', '1.7', '1.8', '1.8.1' };

    % legHAL configuration
    WarningType = 'text'; % text | popup
    
    % RUBI Remote SW constants
    RemoteMaxNbHostBuffers = 1000;
end
    
% ============================================================================ %
% ============================================================================ %

% Error management
methods ( Static = true )
    
    varargout = GetException(varargin) % reissue an exception
    
end

% ============================================================================ %
% ============================================================================ %

end