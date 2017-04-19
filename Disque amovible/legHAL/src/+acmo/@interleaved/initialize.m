% ACMO.INTERLEAVED.INITIALIZE (ACMO.ACMO)
%   Build the remoteclass ACMO.INTERLEAVED.
%
%   OBJ = OBJ.INITIALIZE() creates a generic ACMO.INTERLEAVED instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates an ACMO.INTERLEAVED instance
%   with its name and description values set to NAME and DESC (character values)
%   and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ACMO.INTERLEAVED instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - NBEVENTS (int32) contains a vector (length equal to the number of
%       interleaved acmos) to define the events size for each acmo.
%       [1 Inf] = number of events
%     - TIMEINTEGRATION (int32) enables preserving the timing between events.
%       0 = do not preserve timing, 1 = preserve timing - default = 0
%
%   Dedicated objects:
%     - ACMO contains the ACMOs to be interleaved.
%
%   Inherited parameters:
%     - REPEAT (int32) sets the number of ACMO repetition.
%       [1 Inf] - default = 1
%     - DURATION (single) sets the TGC duration.
%       [0 Inf] us - default = 0
%     - CONTROLPTS (single) sets the value of TGC control points.
%       [0 960] - default = 900
%     - FASTTGC (int32) enables the fast TGC mode.
%       0 = classical TGC, 1 = fast TGC - default = 0
%     - NBLOCALBUFFER (int32) sets the number of local buffer.
%       0 = automatic, [1 20] - default = 0
%     - NBHOSTBUFFER (int32) sets the number of host buffer.
%       [1 10] - default = 1
%     - ORDERING (int32) sets the ELUSEV execution order during the ACMO.
%       0 = chronological, [1 Inf] = customed order - default = 0
%     - REPEATELUSEV (int32) sets the number of times all ELUSEV are repeated
%       before data transfer.
%       [1 Inf] = number of repetitions - default = 1
%
%   Inherited objects:
%     - MODE contains REMOTE.MODE instances.
%     - TGC contains REMOTE.TGC instances.
%     - DMACONTROL contains REMOTE.DMACONTROL instances.
%     - ELUSEV contains ELUSEV.ELUSEV instances.
%
%   Note - This function is defined as a method of the remoteclass
%   ACMO.INTERLEAVED. It cannot be used without all methods of the remoteclass
%   ACMO.INTERLEAVED and all methods of its superclass ACMO.ACMO developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/03

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'acmo.interleaved';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize ACMO.ACMO superclass
obj = initialize@acmo.acmo(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Number of events per acmo
Par = common.parameter( ...
    'NbEvents', ...
    'int32', ...
    'sets the number of events for each acmo', ...
    {[1 Inf]}, ...
    {'number of events for each acmo'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Number of events per acmo (default = 0)
Par = common.parameter( ...
    'TimeIntegration', ...
    'int32', ...
    'enables preserving the timing between events', ...
    {0 1}, ...
    {'do not preserve timing', 'preserve timing'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %
% ============================================================================ %

%% Add new objects

% ACMO instance
obj = obj.addParam('acmo', 'acmo.acmo');

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