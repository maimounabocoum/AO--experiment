% COMMON.CONSTANTS
%   Class containing only constant variable.
%
%   Constants:
%     - SOUNDSPEED contains a generic sound speed in water (1540 m/s).
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

classdef constants
   
% ============================================================================ %
% ============================================================================ %

% Physics constant
properties ( Constant = true )

    SoundSpeed = 1540; % sound speed [m/s]

    GetDataTimeout = 120; % s
    GetDataPause = 0.001; % s
    NotificationTimeout = 10000; % 1000 - inf [ms]
    NotificationTrigInTimeout = 3000; % ms

end
    
% ============================================================================ %
% ============================================================================ %

end
