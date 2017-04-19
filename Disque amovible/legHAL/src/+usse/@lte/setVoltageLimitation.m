% USSE.LTE.SETVOLTAGELIMITATION (PUBLIC)
%   Sets the Magna Power voltage limitation which raise an alarm.
%
%   OBJ = OBJ.SETVOLTAGELIMITATION(VOLTAGE) sets the Magna Power voltage limitation to VOLTAGE.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

function obj = setVoltageLimitation(obj, varargin)
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check function syntax
if ( nargout ~= 1 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltageLimitation function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif ( nargin ~= 2 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltageLimitation function needs 1 ' ...
        'input argument corresponding to the voltage limitation (1.6V to 17.6V).'];
    error(ErrMsg);
    
elseif ( ~isnumeric(varargin{1}) )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltageLimitation function needs 1 ' ...
        'input argument corresponding to the voltage limitation (1.6V to 17.6V).'];
    error(ErrMsg);
    
elseif ( (varargin{1} < 1.6) || (varargin{1} > 17.6) )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltageLimitation function needs 1 ' ...
        'input argument corresponding to the voltage limitation (1.6V to 17.6V).'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Check the existence of the remote server
if ( isempty(obj.Server.addr) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getData function needs an IP ' ...
        'address to be defined.'];
    error(ErrMsg);
end

% Get system status
Msg    = struct('name', 'get_status');
Status = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE server is not running on the host.';
    error(ErrMsg);
end

% The level should be system
if ( ~strcmpi(strtrim(Status.level), 'system') )
    obj = obj.initializeRemote();
end

% ============================================================================ %
% ============================================================================ %

%% Communicate with the Magna Power

% Connect the Magna Power
Msg.name      = 'rs232_connect';
Msg.device    = 'ttyUSB0';
Msg.bauderate = 19200;
Msg.bitData   = 8;
Msg.bitArret  = 1;
Msg.parity    = 0;
Status        = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The Magna Power could not be connected to the remote server.';
    error(ErrMsg);
end

% ============================================================================ %
% get current limitation max and min and the current value
Msg.message = 'VOLT:PROT? MAX';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

%Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    Build the prompt of the help dialog box
    ErrMsg = 'get max voltage limitation issue on Magna power ';
    error(ErrMsg);
else 
   data = str2double (Status.data_receive);
   disp(['voltage prot max ',num2str(data), ' V']); 
end

Msg.message = 'VOLT:PROT? MIN';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'get min voltage limitation issue on Magna power ';
    error(ErrMsg);
else 
    data = str2double (Status.data_receive);
   disp(['voltage prot min ',num2str(data),' V']); 
end
% 
Msg.message = 'VOLT:PROT?';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'get Voltage limitation issue on Magna power ';
    error(ErrMsg);
else 
   data = str2double (Status.data_receive);
   disp(['voltage prot before set ',num2str(data), ' V']); 
end
% 
% Set current limitation
Msg.message = ['VOLT:PROT ' num2str(varargin{1})];
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = ['The voltage limitation of the Magna Power could not be set to ' ...
        num2str(varargin{1}) ' V.'];
    error(ErrMsg);
end


% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'setVoltageLimitation');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end