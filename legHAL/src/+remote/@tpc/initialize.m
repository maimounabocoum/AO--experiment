% REMOTE.TPC.INITIALIZE (PROTECTED)
%   Create a REMOTE.TPC instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TPC instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TPC instance with
%   its name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TPC instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - IMGVOLTAGE (single) sets maximum imaging voltage.
%       [10 80] V - default = 10
%     - PUSHVOLTAGE (single) sets maximum push voltage.
%       [10 80] V - default = 10
%     - IMGCURRENT sets maximum imaging current.
%       [0 2] A - default = 0.1
%     - PUSHCURRENT sets maximum push current.
%       [0 20] A - default = 0.1
%
%   Note - This function is defined as a method of the remoteclass REMOTE.TPC.
%   It cannot be used without all methods of the remoteclass REMOTE.TPC and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tpc';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Set maximum imaging voltage (default = 10)
Par = common.remotepar( ...
    'imgVoltage', ...
    'single', ...
    'sets maximum imaging voltage', ...
    {[8 80]}, ...
    {'imaging voltage [V]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(10);
obj = obj.addParam(Par);

% ============================================================================ %

% Set maximum push voltage (default = 10)
Par = common.remotepar( ...
    'pushVoltage', ...
    'single', ...
    'sets maximum push voltage', ...
    {[8 80]}, ...
    {'push voltage [V]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(10);
obj = obj.addParam(Par);

% ============================================================================ %

% Set maximum imaging current (default = 0.1)
Par = common.remotepar( ...
    'imgCurrent', ...
    'single', ...
    'sets maximum imaging current', ...
    {[0 2]}, ...
    {'imaging current [A]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0.1);
obj = obj.addParam(Par);

% ============================================================================ %

% Set maximum push current (default = 0.1)
Par = common.remotepar( ...
    'pushCurrent', ...
    'single', ...
    'sets maximum push current', ...
    {[0 20]}, ...
    {'push current [A]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0.1);
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