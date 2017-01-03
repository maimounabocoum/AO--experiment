% COMMON.REMOTEPAR (COMMON.PARAMETER)
%   Create a COMMON.REMOTEPAR instance.
%
%   OBJ = COMMON.REMOTEPAR() returns the authorized syntaxes.
%
%   PAR = COMMON.REMOTEPAR(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC) creates a
%   COMMON.REMOTEPAR instance with its name set to NAME, its value type to TYPE,
%   its description to DESC, its authorized values to AUTHVALUES and the
%   authorized values description to AUTHDESC.
%
%   PAR = COMMON.REMOTEPAR(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC, DEBUG)
%   creates a COMMON.REMOTEPAR instance with a DEBUG value (1 is enabling the
%   debug mode).
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - AUTHVALUES contains the authorized values.
%     - AUTHDESC contains a description of each authorized values.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the class COMMON.REMOTEPAR.
%
%   Dedicated functions:
%     - GETVALUE retrieves the value/object of a COMMON.REMOTEPAR parameter.
%     - SETVALUE sets the value of a COMMON.REMOTEPAR parameter.
%     - ISEMPTY checks if the VALUE of the COMMON.REMOTEPAR is empty.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the class COMMON.REMOTEPAR and the superclass
%   COMMON.PARAMETER developed by SuperSonic Imagineand without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

classdef remotepar < common.parameter
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % builds class COMMON.REMOTEPAR
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = remotepar(varargin)
        
        % Initialization
        obj = obj@common.parameter(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end