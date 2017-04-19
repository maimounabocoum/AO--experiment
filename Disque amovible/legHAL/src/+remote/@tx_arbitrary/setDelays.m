% REMOTE.TX_ARBITRARY.SETDELAYS (PROTECTED)
%   Build the REMOTE.TX_ARBITRARY transmit delays.
%
%   OBJ = OBJ.SETDELAYS() sets the delays of the REMOTE.TX_ARBITRARY instance.
%
%   Note - This function is defined as a method of the remoteclass
%   REMOTE.TX_ARBITRARY. It cannot be used without all methods of the
%   remoteclass REMOTE.TX_ARBITRARY and all methods of its superclass REMOTE.TX
%   developed by SuperSonic Imagine and without a system with a REMOTE server
%   running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

function obj = setDelays(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check syntax
if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Build the delays and structure

% Initialize parameters
Delays = obj.getParam('Delays');   % arbitrary delays
if ( length(Delays) == 1 )
    Delays = zeros(1, system.probe.NbElemts);
end

% ============================================================================ %

% Set to 0 delays < TxClock
Delays(Delays < 1/system.hardware.ClockFreq) = 0;

% Control that the delays are correctly defined
if ( (length(Delays) ~= system.hardware.NbTxChan) ...
        && (length(Delays) ~= system.probe.NbElemts) )
    
    ErrMsg = ['The arbitrary delays are not defined for all transmit ' ...
        'elements.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Update the delays
obj = obj.setParam('Delays', Delays);

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'setDelays');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end