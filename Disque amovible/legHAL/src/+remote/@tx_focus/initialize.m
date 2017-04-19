% REMOTE.TX_FOCUS.INITIALIZE (PROTECTED)
%   Create a REMOTE.TX_FOCUS instance.
%
%   OBJ = OBJ.INITIALIZE() creates a generic REMOTE.TX_FOCUS instance.
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) creates a REMOTE.TX_FOCUS instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TX_FOCUS instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - POSX (single) sets the focus lateral position.
%       [-100 100] mm
%     - POSZ (single) sets the focus axial position.
%       [0 100] mm
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
%   REMOTE.TX_FOCUS. It cannot be used without all methods of the remoteclass
%   REMOTE.TX_FOCUS and all methods of its superclass REMOTE.TX developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'remote.tx_focus';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize REMOTE.TX superclass
obj = initialize@remote.tx(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Lateral position of the focus
Par = common.parameter( ...
    'PosX', ...
    'single', ...
    'sets the focus lateral position', ...
    {[-Inf Inf]}, ...
    {'lateral position [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

% Axial position of the focus
Par = common.parameter( ...
    'PosZ', ...
    'single', ...
    'sets the focus axial position', ...
    {[0 100]}, ...
    {'axial position [mm]'}, ...
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