% REMOTE.RX (COMMON.REMOTEOBJ)
%   Create a REMOTE.RX instance.
%
%   OBJ = REMOTE.RX() creates a generic REMOTE.RX instance.
%
%   OBJ = REMOTE.RX(NAME, DESC, DEBUG) creates a REMOTE.RX instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.RX(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.RX instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - FCID (int32) sets the filter coefficients id.
%       [1 Inf]
%     - CLIPMODE (int32) sets the clip mode level.
%       0 = none, 1 = maximum, 2 = medium, 3 = lowest - default = 0
%     - RXFREQ (single) sets the receive frequency.
%       [1 60] MHz
%     - QFILTER (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50%
%     - HARMONICFILTER (int32) sets the harmonic filtering.
%       1 = none, 2 = -15dB @<2MHz, min @3MHz, to -2.5dB @[3MHz;5MHz],
%       0 = -15dB @<2MHz, min @3.75MHz, to 0dB @[3MHz;10MHz]- default = 1
%     - VGAINPUTFILTER (int32) sets notches to block frequencies.
%       0 = none, 4 = notch @ 2.25 MHz, 2 = notch @ 3.75 MHz,
%       1 = notch @ 5.5 MHz - default = 0
%     - VGALOWGAIN (int32) sets a filter for low gain.
%       0 = no attenuation, 1 = -20dB after 10µs - default = 0
%     - RXELEMTS (int32) sets the receiving elements.
%       0 = none, [1 system.probe.NbElemts]
%     - HIFURX (int32) enables reception on non-contiguous elements.
%       0 = contiguous channels, 1 = distinct channels - default = 0
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.RX.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.RX.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.RX.
%     - GETPARAM retrieves the value/object of a REMOTE.RX parameter.
%     - SETPARAM sets the value of a REMOTE.RX parameter.
%     - ISEMPTY checks if all REMOTE.RX parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.RX and its superclass
%   COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

classdef rx < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 11; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.RX
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = rx(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'RX', ...
                    'default receive', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'RX', ...
                'default receive', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end