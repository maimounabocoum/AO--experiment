% REMOTE.TGC (COMMON.REMOTEOBJ)
%   Create a REMOTE.TGC instance.
%
%   OBJ = REMOTE.TGC() creates a generic REMOTE.TGC instance.
%
%   OBJ = REMOTE.TGC(NAME, DESC, DEBUG) creates a REMOTE.TGC instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.TGC(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TGC instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - DURATION (single) sets the TGC duration.
%       [0 4000] us - default = 0
%     - CONTROLPTS (single) sets the values of TGC control points.
%       [0 960] - default = 900
%     - FASTTGC (int32) enables the fast TGC mode.
%       0 = classical TGC, 1 = fast TGC - default = 0
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.TGC.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.TGC.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.TGC.
%     - GETPARAM retrieves the value/object of a REMOTE.TGC parameter.
%     - SETPARAM sets the value of a REMOTE.TGC parameter.
%     - ISEMPTY checks if all REMOTE.TGC parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.TGC and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

classdef tgc < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Remote variables
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 3; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.TGC
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = tgc(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'TGC', ...
                    'default time gain control', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'TGC', ...
                'default time gain control', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end