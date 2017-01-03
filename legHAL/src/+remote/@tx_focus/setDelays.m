% REMOTE.TX_FOCUS.SETDELAYS (PUBLIC)
%   Build the TX_FOCUS transmit delays.
%
%   OBJ = OBJ.SETDELAYS() sets the delays of the REMOTE.TX_FOCUS instance.
%
%   Note - This function is defined as a method of the remoteclass
%   REMOTE.TX_FOCUS. It cannot be used without all methods of the remoteclass
%   REMOTE.TX_FOCUS and all methods of its superclass REMOTE.TX developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
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

% Initialize variables
Delays     = zeros(1, system.hardware.NbTxChan); %
NbElemts   = system.probe.NbElemts;              %
SoundSpeed = common.constants.SoundSpeed;        %
PosS       = obj.getParam('PosX') * 1e-3;        % lateral position [m]
PosF       = obj.getParam('PosZ') * 1e-3;        % axial position [m]
TxElemts   = obj.getParam('TxElemts');           % Array containing firing elements

% ============================================================================ %

% Initialize variables
PrPitch = system.probe.Pitch * 1e-3; % probe pitch [m]

switch system.probe.Type
    
    case 'linear' % linear probe
        
        ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch; % element positions [m]
        ElemtZpos = zeros(1, NbElemts); % [m]
        PosX = PosS ;
        PosZ = PosF ;

% ============================================================================ %
        
    case 'curved' % curved probe
        
        % Initialize parameters
        PrRadius  = system.probe.Radius * 1e-3;                % probe radius [m]
        ElemtApos = ((1:NbElemts) - 0.5) * PrPitch / PrRadius; % angular positions [rad]
        
        % Element cartesian positions
        ElemtXpos = PrRadius * cos(ElemtApos); % [m]
        ElemtZpos = PrRadius * sin(ElemtApos); % [m]
        
        % Focal point cartesian position
        Angle = PosS / (PrRadius);
        PosX  = (PosF + PrRadius) * cos(Angle);
        PosZ  = (PosF + PrRadius) * sin(Angle);
        
% ============================================================================ %
        
    otherwise
        
        ErrMsg = ['The ' upper(class(obj)) ' setDelays function is not yet ' ...
            'implemented for ' lower(system.probe.Type) ' probes.'];
        error(ErrMsg);
        
end

% ============================================================================ %

% Estimate and rescale the delays
Delays(1:NbElemts) = 0 ;
Delays(TxElemts) = sqrt((ElemtXpos(TxElemts) - PosX).^2 + (ElemtZpos(TxElemts) - PosZ).^2) ...
    * 1e6 / SoundSpeed; % [us]

Delays(TxElemts) = max(Delays(TxElemts)) - Delays(TxElemts);
tof2Focus = max(Delays(TxElemts));

% Set to 0 delays < TxClock
Delays(Delays < 1/system.hardware.ClockFreq) = 0;

% ============================================================================ %

% Update the delays
obj = obj.setParam('Delays', Delays);
obj = obj.setParam('tof2Focus', tof2Focus);

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