% COMMON.PARAMETER
%   Create a COMMON.PARAMETER instance.
%
%   OBJ = COMMON.PARAMETER() returns the authorized syntaxes.
%
%   PAR = COMMON.PARAMETER(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC) creates a
%   COMMON.PARAMETER instance with its name set to NAME, its value type to TYPE,
%   its description to DESC, its authorized values to AUTHVALUES and the
%   authorized values description to AUTHDESC.
%
%   PAR = COMMON.PARAMETER(NAME, TYPE, DESC, AUTHVALUES, AUTHDESC, DEBUG)
%   creates a COMMON.PARAMETER instance with a DEBUG value (1 is enabling the
%   debug mode).
%
%   Dedicated variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - AUTHVALUES contains the authorized values.
%     - AUTHDESC contains a description of each authorized values.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the class COMMON.PARAMETER.
%     - GETVALUE retrieves the value/object of a COMMON.PARAMETER parameter.
%     - SETVALUE sets the value of a COMMON.PARAMETER parameter.
%     - ISEMPTY checks if the VALUE of the COMMON.PARAMETER is empty.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the class COMMON.PARAMETER developed by
%   SuperSonic Imagineand without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

classdef parameter
   
% ============================================================================ %
% ============================================================================ %

%% General variables (protected value)
properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    Name       % name of the parameter
    Type       % type of input/output data
    Desc       % description of the parameter
    AuthValues % cell array containing all authorized variables
    AuthDesc   % description of the parameter authorized values
    Value      % value of the parameter (can be a vector or a matrix)
    AuthRange  % identify if authorized values are ranges of values
    ParClass   % class where the parameter was added
end
    
% ============================================================================ %

% Debug variables
properties ( SetAccess = 'public', GetAccess = 'public' )
    
    Debug = 0; % parameter to show debug info
    
end

% ============================================================================ %
% ============================================================================ %

%% Inline public functions
methods ( Access = 'public' )
    
    % Parameter is empty
    function Success = isempty(obj)
        Success = isempty(obj.Value);
    end
    
end

% ============================================================================ %

%% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % builds class COMMON.PARAMETER
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = setValue(obj, varargin) % sets the VAR value
    varargout = getValue(obj, varargin) % gets the VAR value
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = parameter(varargin)
        
        % Initialization
        obj = obj.initialize(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end