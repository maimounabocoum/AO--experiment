% REMOTE.TX (COMMON.REMOTEOBJ)
%   Create a REMOTE.TX instance.
%
%   OBJ = REMOTE.TX() creates a generic REMOTE.TX instance.
%
%   OBJ = REMOTE.TX(NAME, DESC, DEBUG) creates a REMOTE.TX instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.TX(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TX instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TXCLOCK180MHZ (int32) sets the waveform sampling rate.
%       0 = 90-MHz sampling, 1 = 180-MHz sampling - default = 1
%     - TWID (int32) sets the id of the waveform.
%       0 = none, [1 Inf] = waveform id - default = 0
%     - DELAYS (single) sets the transmit delays.
%       [0 1000] us - default = 0
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.TX.
%     - BUILDREMOTE builds the associated remote structure.
%     - SETDELAYS builds the REMOTE.TX transmit delays.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.TX.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.TX.
%     - GETPARAM retrieves the value/object of a REMOTE.TX parameter.
%     - SETPARAM sets the value of a REMOTE.TX parameter.
%     - ISEMPTY checks if all REMOTE.TX parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.TX and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

classdef tx < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 4; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.TX
    varargout = setDelays(obj, varargin) % build the REMOTE.TX delays
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = tx(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'TX', ...
                    'default transmit', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'TX', ...
                'default transmit', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end