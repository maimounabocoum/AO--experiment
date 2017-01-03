% REMOTE.TX_CIRCULAR.INITIALIZE (PROTECTED)
%   Create a REMOTE.TX_CIRCULAR instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TX_CIRCULAR instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TX_CIRCULAR instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TX_CIRCULAR instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - xApex (single) sets the apex x position (mm)
%       [-100 100]
%     - zApex (single) sets the apex z position (mm)
%       [0 100]
%
%   Inherited parameters:
%     - TXCLOCK180MHZ (int32) sets the waveform sampling rate.
%       0 = 90-MHz sampling, 1 = 180-MHz sampling - default = 1
%     - TWID (int32) sets the id of the waveform.
%       0 = none, [1 Inf] = waveform id - default = 0
%     - DELAYS (single) sets the transmit delays.
%       [0 1000] us - default = 0
%
%   Note - This function is defined as a method of the remoteclass
%   REMOTE.TX_CIRCULAR. It cannot be used without all methods of the remoteclass
%   REMOTE.TX_CIRCULAR and all methods of its superclass REMOTE.TX developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tx_circular';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize REMOTE.TX superclass
obj = initialize@remote.tx(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% apex position
Par = common.parameter( ...
    'xApex', ...
    'single', ...
    'sets the circular angle value', ...
    {[-100 100]}, ...
    {'x apex position [mm]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(system.probe.Pitch*system.probe.NbElemts/2.0);
obj = obj.addParam(Par);

Par = common.parameter( ...
    'zApex', ...
    'single', ...
    'sets the circular angle value', ...
    {[0 100]}, ...
    {'z apex position [mm]'}, ...
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
