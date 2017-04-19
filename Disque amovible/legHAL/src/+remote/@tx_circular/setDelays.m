% REMOTE.TX_CIRCULAR.SETDELAYS (PROTECTED)
%   Build the REMOTE.TX_CIRCULAR transmit delays.
%
%   OBJ = OBJ.SETDELAYS() sets the delays of the REMOTE.TX_CIRCULAR instance.
%
%   Note - This function is defined as a method of the remoteclass
%   REMOTE.TX_CIRCULAR. It cannot be used without all methods of the remoteclass
%   REMOTE.TX_CIRCULAR and all methods of its superclass REMOTE.TX developed by
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
Delays     = zeros(1, system.hardware.NbTxChan);   %
NbElemts   = system.probe.NbElemts;                %
SoundSpeed = common.constants.SoundSpeed;          %
xApex  = 1e-3*obj.getParam('xApex');
zApex  = 1e-3*obj.getParam('zApex');

% ============================================================================ %

% Initialize variables
PrPitch = system.probe.Pitch * 1e-3; % probe pitch [m]

switch system.probe.Type
    
    case 'linear' % linear probe
        
        % Element cartesian coordinates
        ElemtXpos = ((1 : NbElemts) - 0.5) * PrPitch;     % element positions
        
        % Estimate the delays
        Delays(1:NbElemts) = sqrt((ElemtXpos-xApex).^2 + zApex^2) * 1e6 / SoundSpeed;
        
% ============================================================================ %
        
    case 'curved' % curved probe % control the circular law with Fran�ois...
        
        % Initialize parameters
        radius = system.probe.Radius*1e-3 ;
        ElemtAngle = ((1:NbElemts) - 0.5 - NbElemts/2) * PrPitch / radius; % angle piezo
        % position of the element with origin at the probe apex
        
        xPiezo = sin(ElemtAngle)*radius;
        zPiezo = cos(ElemtAngle)*radius;
        
        % Estimate the circular delay
        Delays(1:NbElemts) = ...
            sqrt((xPiezo-xApex).^2 + (zPiezo-zApex).^2) * 1e6 / SoundSpeed;
                
% ============================================================================ %
        
    otherwise
        
        ErrMsg = ['The ' upper(class(obj)) ' setDelays function is not yet ' ...
            'implemented for ' lower(system.probe.Type) ' probes.'];
        error(ErrMsg);
        
end

% ============================================================================ %

% Rescale delays
Delays(1:NbElemts) = Delays(1:NbElemts) ;

% Set to 0 delays < TxClock
Delays(Delays < 1/system.hardware.ClockFreq) = 0;

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
