% REMOTE.HVMUX (COMMON.REMOTEOBJ)
%   Create a REMOTE.HVMUX instance.
%
%   OBJ = REMOTE.DMACONTROL() creates a generic REMOTE.HVMUX instance.
%
%   OBJ = REMOTE.DMACONTROL(NAME, DESC, DEBUG) creates aREMOTE.HVMUX instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.DMACONTROL(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.HVMUX instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - BLOCKS (int32) defines the position of the HV mux.
%       [0 Inf]
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.HVMUX.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.HVMUX.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.HVMUX.
%     - GETPARAM retrieves the value/object of a REMOTE.HVMUX parameter.
%     - SETPARAM sets the value of a REMOTE.HVMUX parameter.
%     - ISEMPTY checks if all REMOTE.HVMUX parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.HVMUX and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

classdef hvmux < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.HVMUX
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = hvmux(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'HvMux', ...
                    'default mux control', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'HvMux', ...
                'default mux control', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end