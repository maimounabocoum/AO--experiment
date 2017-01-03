% USSE.LTE.getAlarmTpcAndClear (PUBLIC)
%   Sets the Magna Power voltage.
%
%   ques_cond = OBJ.getAlarmTpcAndClear() get the Magna Power  qustionnable register and clear alarm if varargin = true.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/09/07

function ques_cond = getAlarmTpcAndClear(obj,varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' getAlarmTpcAndClear function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif ( nargin ~= 2 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getAlarmTpcAndClear function needs 1 ' ...
        'input argument corresponding clear alarm boolean'];
    error(ErrMsg);
    
elseif ( ~isa(varargin{1},'logical') )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getAlarmTpcAndClear function needs 1 ' ...
        'input argument corresponding to the clear alarm boolean true or false.'];
    error(ErrMsg);
    
    
end

% ============================================================================ %

% Check the existence of the remote server
if ( isempty(obj.Server.addr) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getAlarmTpcAndClear function needs an IP ' ...
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
class(obj);
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
    ques_cond = str2num(Status.data_receive);
    hex_val_cond = dec2hex(ques_cond, 3);
    disp(['Magna questionnable regiter value (before set voltage): 0x', hex_val_cond]);
end
if ( varargin{1} == true)
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
    end;
end;


% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'getAlarmTpcAndClear');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end