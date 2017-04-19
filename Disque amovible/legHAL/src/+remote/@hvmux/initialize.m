% REMOTE.HVMUX.INITIALIZE (PROTECTED)
%   Create a REMOTE.HVMUX instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.HVMUX instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.HVMUX instance with
%   its name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.HVMUX instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - BLOCKS (int32) defines the position of the HV mux.
%       [0 Inf]
%
%   Note - This function is defined as a method of the remoteclass REMOTE.HVMUX.
%   It cannot be used without all methods of the remoteclass REMOTE.HVMUX and
%   all methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic
%   Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.hvmux';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Position of the HV mux
Par = common.remotepar( ...
    'blocks', ...
    'int32', ...
    'defines the position of the HV mux', ...
    {[0 Inf]}, ...
    {'the several positions'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'initialize');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end