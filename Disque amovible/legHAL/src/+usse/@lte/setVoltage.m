% USSE.LTE.SETVOLTAGE (PUBLIC)
%   Sets the Magna Power voltage.
%
%   OBJ = OBJ.SETVOLTAGE(VOLTAGE) sets the Magna Power voltage to VOLTAGE.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/09/07

function obj = setVoltage(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' setVoltage function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif ( nargin ~= 2 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltage function needs 1 ' ...
        'input argument corresponding to the voltage (0V to 16V).'];
    error(ErrMsg);
    
elseif ( ~isnumeric(varargin{1}) )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltage function needs 1 ' ...
        'input argument corresponding to the voltage (0V to 16V).'];
    error(ErrMsg);
    
elseif ( (varargin{1} < 0) || (varargin{1} > 16) )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setVoltage function needs 1 ' ...
        'input argument corresponding to the voltage (0V to 16V).'];
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
%read IDN 
Msg.message = '*IDN?';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'read IDN issue on Magna power ';
    error(ErrMsg);
else 
   disp(strtrim(Status.data_receive)); 
end

% Sets magna to remote control
Msg.message = 'CONF:SETPT 3';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The Magna Power could not be set to the remote mode.';
    error(ErrMsg);
end

% ============================================================================ %

% Apply the new voltage

% Start Magna Power
Msg.message = 'OUTP:START';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The Magna Power could not be started.';
    error(ErrMsg);
end
% read status
Msg.message = 'STAT:QUES:COND?';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The questionnable regiter of the Magna Power could not be read.';
    error(ErrMsg);
else
    ques_cond = dec2hex(str2num(Status.data_receive), 3);
    disp(['Magna questionnable regiter value (before set voltage): 0x', num2str(ques_cond)]);
end

% Clear alarms
Msg.message = 'OUTP:PROT:CLE';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The alarms of the Magna Power could not be cleared.';
    error(ErrMsg);
end

% Set new voltage
Msg.message = ['VOLT ' num2str(varargin{1})];
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = ['The voltage of the Magna Power could not be set to ' ...
        num2str(varargin{1}) ' V.'];
    error(ErrMsg);
end
% read status
Msg.message = 'STAT:QUES:COND?';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The questionnable regiter of the Magna Power could not be read.';
    error(ErrMsg);
else
    ques_cond = dec2hex(str2num(Status.data_receive), 3);
    disp(['Magna questionnable regiter value (after set voltage): 0x', num2str(ques_cond)]);
end
% ============================================================================ %

if ( varargin{1} == 0 )
    
    % Start Magna Power
    Msg.message = 'OUTP:STOP';
    Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
    Msg.timeout = 400; % 400 for instance
    Msg.name    = 'rs232_write_and_read';
    Status      = remoteSendMessage(obj.Server, Msg);
    
    % Message could not be sent
    if ( ~strcmpi(Status.type, 'ack') )
        % Build the prompt of the help dialog box
        ErrMsg = 'The Magna Power could not be stopped.';
        error(ErrMsg);
    end
    
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'setVoltage');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end