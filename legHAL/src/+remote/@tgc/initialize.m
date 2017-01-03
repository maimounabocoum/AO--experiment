% REMOTE.TGC.INITIALIZE (PROTECTED)
%   Create a REMOTE.TGC instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TGC instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TGC instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
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
%   Note - This function is defined as a method of the remoteclass REMOTE.TGC.
%   It cannot be used without all methods of the remoteclass REMOTE.TGC and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tgc';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Set TGC duration (default = 0)
Par = common.parameter( ...
    'Duration', ...
    'single', ...
    'sets the TGC duration', ...
    {[0 4000]}, ...
    {'acquisition duration [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

% Set the TGC control points (default = 900)
Par = common.parameter( ...
    'ControlPts', ...
    'single', ...
    'sets the values of TGC control points', ...
    {[0 960]}, ...
    {'values of the TGC control points'}, ...
    obj.Debug, current_class );
Par = Par.setValue(900);
obj = obj.addParam(Par);

% ============================================================================ %

% Set the fast TGC mode (default = 0)
Par = common.remotepar( ...
    'fastTGC', ...
    'int32', ...
    'enables the fast TGC mode', ...
    {0 1}, ...
    {'regular TGC', 'fast TGC'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
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