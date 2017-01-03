% USSE.LTE.INITIALIZE (PROTECTED)
%   Build the remoteclass USSE.USSE.
%
%   OBJ = OBJ.INITIALIZE() returns a generic USSE.LTE instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic USSE.LTE instance using the
%   DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an USSE.LTE instance with
%   its name and description values set to NAME and DESC (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   USSE.LTE instance with parameters PARSNAME set to PARSVALUE.
%
%   Inherited parameters:
%     - REPEAT (int32) sets the number of USSE repetition.
%       [1 Inf]
%     - LOOP (int32) enables the loop mode.
%       0 = single execution sequence, 1 = loop the sequence
%     - DATAFORMAT (char) sets the format of output data.
%       RF = RF data, BF = beamformed data, FF = final frame data - default = RF
%     - ORDERING (int32)sets the ACMO execution order during the USSE.
%       0 = chronological, [1 Inf] = customed order - default = 0
%
%   Inherited objects:
%     - TPC contains a single REMOTE.TPC instance.
%     - ACMO contains ACMO.ACMO instances.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'usse.lte';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize USSE.USSE superclass
obj = initialize@usse.usse(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

% SERVER IP address
obj.Server.addr = '192.168.1.15'; % ???

% ============================================================================ %
% ============================================================================ %

% End error handling
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