% ELUSEV.ELUSEV (COMMON.REMOTEOBJ)
%   Create an ELUSEV.ELUSEV instance.
%
%   OBJ = ELUSEV.ELUSEV() creates a generic ELUSEV.ELUSEV instance.
%
%   OBJ = ELUSEV.ELUSEV(NAME, DESC, DEBUG) creates an ELUSEV.ELUSEV instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ELUSEV.ELUSEV(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ELUSEV.ELUSEV instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TRIGIN (int32) enables the trigger in.
%       0 = no trigger in, 1 = trigger in - default = 0
%     - TRIGOUT (single) enables the trigger out.
%       0 = no trigger out, [1e-3 720.8] us = trigger out duration - default = 0
%     - TRIGOUTDELAY (single) sets the trigger out delay.
%       [0 1000] us = trigger out delay - default = 0
%     - TRIGALL (int32) enables triggers on all events.
%       0 = triggers on 1st event, 1 = triggers on all events - default = 0
%     - REPEAT (int32) sets the number of ELUSEV repetition.
%       [1 Inf] - default = 1
%
%   Dedicated objects:
%     - TX contains REMOTE.TX instances.
%     - TW contains REMOTE.TW instances.
%     - RX contains REMOTE.RX instances.
%     - FC contains REMOTE.FC instances.
%     - EVENT contains REMOTE.EVENT instances.
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass ELUSEV.ELUSEV.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ELUSEV.ELUSEV.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ELUSEV.ELUSEV.
%     - GETPARAM retrieves the value/object of a ELUSEV.ELUSEV parameter.
%     - SETPARAM sets the value of a ELUSEV.ELUSEV parameter.
%     - ISEMPTY checks if all ELUSEV.ELUSEV parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ELUSEV.ELUSEV and its
%   superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a
%   system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/02

classdef elusev < common.remoteobj
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass ELUSEV.ELUSEV
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = elusev(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'ELUSEV', ...
                            'default elementary ultrasound events', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'ELUSEV', ...
                        'default elementary ultrasound events', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end