% USSE.USSE.INITIALIZE (PROTECTED)
%   Build the remoteclass USSE.USSE.
%
%   OBJ = OBJ.INITIALIZE() returns a generic USSE.USSE instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic USSE.USSE instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an USSE.USSE instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   USSE.USSE instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - REPEAT (int32) sets the number of USSE repetition.
%       [1 Inf] - default = 1
%     - LOOP (int32) enables the loop mode.
%       0 = single execution sequence, 1 = loop the sequence
%     - DATAFORMAT (char) sets the format of output data.
%       RF = RF data, BF = beamformed data, FF = final frame data - default = RF
%     - ORDERING (int32)sets the ACMO execution order during the USSE.
%       0 = chronological, [1 Inf] = customed order - default = 0
%     - DROPFRAMES (int32) enables error message if acquisition were dropped.
%       0 = no error message, 1 = error message - default = 0
%
%   Dedicated objects:
%     - TPC contains a single REMOTE.TPC instance.
%     - ACMO contains ACMO.ACMO instances.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/09

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'usse.usse';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

Par = common.parameter( ...
    'Repeat', ...
    'int32', ...
    'sets the repetition number of USSE', ...
    {[1 Inf]}, ...
    {'number of repetition'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'Loop', ...
    'int32', ...
    'sets the loop execution of the loaded sequence', ...
    {0 1}, ...
    {'sequence executed once' 'sequence looped'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'DataFormat', ...
    'char', ...
    'sets the format of output data', ...
    {'RF' 'BF' 'FF'}, ...
    {'RF signals' 'beamformed images' 'final frame images'}, ...
    obj.Debug, current_class );
Par = Par.setValue('RF');
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'Ordering', ...
    'int32', ...
    'sets the ACMO execution order during the USSE', ...
    {0 [1 Inf]}, ...
    {'chronological ordering', 'customed ordering'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'DropFrames', ...
    'int32', ...
    'enables error message if acquisition were dropped', ...
    {0 1}, ...
    {'no error message', 'error message'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %
% ============================================================================ %

Par = common.parameter( ...
    'Popup', ...
    'int32', ...
    'enables the popups to control the sequence execution', ...
    { 0 1 }, ...
    { 'popup disabled', 'popup enabled' }, ...
    obj.Debug, current_class );
Par = Par.setValue(1);
obj = obj.addParam(Par);


%% Add new objects

% TPC instance
Par = remote.tpc(obj.Debug);
obj = obj.addParam(Par);

% ============================================================================ %

% ACMO containers
obj = obj.addParam('acmo', 'acmo.acmo');

% ============================================================================ %
% ============================================================================ %

%% Dedicated variables

% SERVER variable
obj.Server.type = 'extern';            % extern / local
obj.Server.addr = [];                  % IP address (local: 127.0.0.1)
obj.Server.port = '9999';              % port number
obj.Server.file = '/tmp/remoteSocket'; % optional for extern

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