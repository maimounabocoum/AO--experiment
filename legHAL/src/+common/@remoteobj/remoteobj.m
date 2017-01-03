% COMMON.REMOTEOBJ (COMMON.OBJECT)
%   Create a COMMON.REMOTEOBJ instance.
%
%   OBJ = COMMON.REMOTEOBJ() returns the authorized syntaxes.
%
%   OBJ = COMMON.REMOTEOBJ(NAME, DESC, DEBUG) creates a COMMON.REMOTEOBJ
%   instance with its name and description values set to NAME and DESC
%   (character values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = COMMON.REMOTEOBJ(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   COMMON.REMOTEOBJ instance with parameters PARSNAME set to PARSVALUE.
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%
%   Dedicated functions:
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - INITIALIZE builds the class COMMON.REMOTEOBJ.
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the class COMMON.REMOTEOBJ.
%     - ADDPARAM adds a parameter (explicit definition and cell array
%       definition) to the class COMMON.REMOTEOBJ.
%     - GETPARAM retrieves the value/object of a COMMON.REMOTEOBJ parameter.
%     - SETPARAM sets the value of a COMMON.REMOTEOBJ parameter.
%     - ISEMPTY checks if all COMMON.REMOTEOBJ parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the class COMMON.REMOTEOBJ and the superclass
%   COMMON.OBJECT developed by SuperSonic Imagineand without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

classdef remoteobj < common.object
   
% ============================================================================ %
% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build the associated remote structure
    
end
    
% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = remoteobj(varargin)
        
        % Initialization
        obj = obj@common.object(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end