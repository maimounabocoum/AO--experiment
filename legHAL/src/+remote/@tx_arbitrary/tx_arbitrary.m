% REMOTE.TX_ARBITRARY (REMOTE.TX)
%   Create a REMOTE.TX_ARBITRARY instance.
%
%   OBJ = REMOTE.TX_ARBITRARY() creates a generic REMOTE.TX_ARBITRARY instance.
%
%   OBJ = REMOTE.TX_ARBITRARY(NAME, DESC, DEBUG) creates a REMOTE.TX_ARBITRARY
%   instance with its name and description values set to NAME and DESC
%   (character values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.TX_ARBITRARY(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates
%   a REMOTE.TX_ARBITRARY instance with parameters PARSNAME set to PARSVALUE.
%
%   Inherited parameters:
%     - TXCLOCK180MHZ (int32) sets the waveform sampling rate.
%       0 = 90-MHz sampling, 1 = 180-MHz sampling - default = 1
%     - TWID (int32) sets the id of the waveform.
%       0 = none, [1 Inf] = waveform id - default = 0
%     - DELAYS (single) sets the transmit delays.
%       [0 1000] us - default = 0
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.TX_ARBITRARY.
%     - SETDELAYS builds the REMOTE.TX_ARBITRARY transmit delays.
%
%   Inherited functions:
%     - BUILDREMOTE builds the associated remote structure.
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.TX_ARBITRARY.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.TX_ARBITRARY.
%     - GETPARAM retrieves the value/object of a REMOTE.TX_ARBITRARY parameter.
%     - SETPARAM sets the value of a REMOTE.TX_ARBITRARY parameter.
%     - ISEMPTY checks if all REMOTE.TX_ARBITRARY parameters are correctly
%       defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.TX_ARBITRARY and its
%   superclass REMOTE.TX developed by SuperSonic Imagine and without a system
%   with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

classdef tx_arbitrary < remote.tx
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass REMOTE.TX_ARBITRARY
    varargout = setDelays(obj, varargin) % build the REMOTE.TX_ARBITRARY delays
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = tx_arbitrary(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = { ...
                    'TX_ARBITRARY', ...
                    'default arbitrary transmit', ...
                    varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'TX_ARBITRARY', ...
                'default arbitrary transmit', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@remote.tx(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end