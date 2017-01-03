% REMOTE.DMACONTROL (COMMON.REMOTEOBJ)
%   Create a REMOTE.DMACONTROL instance.
%
%   OBJ = REMOTE.DMACONTROL() creates a generic REMOTE.DMACONTROL instance.
%
%   OBJ = REMOTE.DMACONTROL(NAME, DESC, DEBUG) creates a REMOTE.DMACONTROL
%   instance with its name and description values set to NAME and DESC
%   (character values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.DMACONTROL(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.DMACONTROL instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - LOCALBUFFER (int32) sets the index of the local buffer.
%       [0 Inf]
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.DMACONTROL.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.DMACONTROL.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.DMACONTROL.
%     - GETPARAM retrieves the value/object of a REMOTE.DMACONTROL parameter.
%     - SETPARAM sets the value of a REMOTE.DMACONTROL parameter.
%     - ISEMPTY checks if all REMOTE.DMACONTROL parameters are correctly
%       defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.DMACONTROL and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

classdef dmacontrol < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 1; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.DMACONTROL
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = dmacontrol(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'DmaControl', ...
                    'default control of direct memory access', ...
                    varargin{1:end}};
            else

            end
        else
            varargin = { ...
                'DmaControl', ...
                'default control of direct memory access', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end