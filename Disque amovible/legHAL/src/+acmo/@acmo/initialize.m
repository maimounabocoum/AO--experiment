% ACMO.ACMO.INITIALIZE (PROTECTED)
%   Build the remoteclass ACMO.ACMO.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ACMO.ACMO instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ACMO.ACMO instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ACMO.ACMO instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   ACMO.ACMO instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - REPEAT (int32) sets the number of ACMO repetition.
%       [1 Inf] - default = 1
%     - DURATION (single) sets the TGC duration.
%       [0 Inf] us - default = 0
%     - CONTROLPTS (single) sets the value of TGC control points.
%       [0 960] - default = 900
%     - FASTTGC (int32) enables the fast TGC mode.
%       0 = classical TGC, 1 = fast TGC - default = 1
%     - NBLOCALBUFFER (int32) sets the number of local buffer.
%       0 = automatic, [1 20] - default = 0
%     - NBHOSTBUFFER (int32) sets the number of host buffer.
%       [1 20] - default = 1
%     - ORDERING (int32) sets the ELUSEV execution order during the ACMO.
%       0 = chronological, [1 Inf] = customed order - default = 0
%     - REPEATELUSEV (int32) sets the number of times all ELUSEV are repeated
%       before data transfer.
%       [1 Inf] = number of repetitions - default = 1
%
%   Dedicated objects:
%     - MODE contains a single REMOTE.MODE instance.
%     - TGC contains a single REMOTE.TGC instance.
%     - DMACONTROL contains a single REMOTE.DMACONTROL instance.
%     - ELUSEV contains ELUSEV.ELUSEV instances.
%
%   Note - This function is defined as a method of the remoteclass ACMO.ACMO. It
%   cannot be used without all methods of the remoteclass ACMO.ACMO and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/04

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'acmo.acmo';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Number of repetition of the ACMO (default = 1)
Par = common.parameter( ...
    'Repeat', ...
    'int32', ...
    'sets the number of ACMO repetition', ...
    {[1 Inf]}, ...
    {'number of repetition'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Set TGC duration (default = 0)
Par = common.parameter( ...
    'Duration', ...
    'single', ...
    'sets the TGC duration', ...
    {[0 Inf]}, ...
    {'acquisition duration [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

obj = obj.addParam( Par );

% ============================================================================ %

% Set the TGC control points (default = 900)
Par = common.parameter( ...
    'ControlPts', ...
    'single', ...
    'sets the value of TGC control points', ...
    {[0 960]}, ...
    {'values of the TGC control points'}, ...
    obj.Debug, current_class );
Par = Par.setValue(900);

obj = obj.addParam( Par );

% ============================================================================ %

% Set the fast TGC mode (default = 0)
Par = common.parameter( ...
    'fastTGC', ...
    'int32', ...
    'enables the fast TGC mode', ...
    {0 1}, ...
    {'regular TGC', 'fast TGC'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);

obj = obj.addParam( Par );

% ============================================================================ %

% Number of local buffers (default = 0)
Par = common.parameter( ...
    'NbLocalBuffer', ...
    'int32', ...
    'sets the number of host buffers', ...
    {0 [1 20]}, ...
    {'automatic number of local buffers', 'number of local buffers'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

obj = obj.addParam( Par );

% ============================================================================ %

% Number of host buffers (default = 1)
Par = common.parameter( ...
    'NbHostBuffer', ...
    'int32', ...
    'sets the number of host buffers', ...
    {[1 common.legHAL.RemoteMaxNbHostBuffers]}, ...
    {'number of host buffers'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);

obj = obj.addParam( Par );

% ============================================================================ %

% Ordering (default = 0)
Par = common.parameter( ...
    'Ordering', ...
    'int32', ...
    'sets the ELUSEV execution order', ...
    {0 [1 Inf]}, ...
    {'chronological ordering', 'customed ordering'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

obj = obj.addParam( Par );

% ============================================================================ %

% RepeatElusev (default = 1)
Par = common.parameter( ...
    'RepeatElusev', ...
    'int32', ...
    'sets the number of times all ELUSEV are repeated before data transfer', ...
    {[1 Inf]}, ...
    {'number of repetitions'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);

obj = obj.addParam( Par );

% ============================================================================ %
% ============================================================================ %

%% Add new objects

% MODE instance
Par = remote.mode( obj.Debug );

obj = obj.addParam( Par );

% ============================================================================ %

% TGC instance
Par = remote.tgc( obj.Debug );

obj = obj.addParam( Par );

% ============================================================================ %

% DMACONTROL instance
Par = remote.dmacontrol( obj.Debug );

obj = obj.addParam( Par );

% ============================================================================ %

% ELUSEV container
obj = obj.addParam('elusev', 'elusev.elusev');

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
