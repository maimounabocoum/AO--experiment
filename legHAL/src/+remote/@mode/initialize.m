% REMOTE.MODE.INITIALIZE (PROTECTED)
%   Create a REMOTE.DMACONTROL instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.MODE instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.MODE instance with
%   its name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.MODE instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - NBHOSTBUFFER (int32) sets the number of host buffers.
%       [1 20] - default = 2
%     - MODERX (int32) describes the rx of the mode (numSamples+rxId).
%       [0 Inf]
%
%   Note - This function is defined as a method of the remoteclass REMOTE.MODE.
%   It cannot be used without all methods of the remoteclass REMOTE.MODE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/02

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.mode';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Number of host buffers (default = 2)
Par = common.parameter( ...
    'NbHostBuffer', ...
    'int32', ...
    'sets the number of host buffers', ...
    {[1 common.legHAL.RemoteMaxNbHostBuffers]}, ...
    {'number of host buffers'}, ...
    obj.Debug, current_class );
Par = Par.setValue(2);
obj = obj.addParam(Par);

% ============================================================================ %

% Description of the RX of this mode (default = 0)
Par = common.remotepar( ...
    'ModeRx', ...
    'int32', ...
    'describes the rx of the mode (numSamples+rxId)', ...
    {[0 Inf]}, ...
    {'number of RF samples for each rxId'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
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
