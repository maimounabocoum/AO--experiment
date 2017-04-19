% USSE.LTE.GETMEASURECURRENTTPC (PUBLIC)
%   Sets the Magna Power voltage.
%
%   OBJ = OBJ.GETMEASCURRENTTPC() gets the current measured by the Magna Power.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/09/07


function current = getMeasCurrentTpc(obj)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' getMeasCurrentTpc function needs 1 ' ...
        'output argument corresponding to a double '];
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

%read Current 
Msg.message = 'MEAS:CURR?';
Msg.endLine = 1; % 0 = '' - 1 = '\r' - 2 = '\n'
Msg.timeout = 400; % 400 for instance
Msg.name    = 'rs232_write_and_read';
Status      = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'Meass current issue on Magn apower ';
    error(ErrMsg);
else 
   %disp(Status.data_receive); 
   current = str2double( Status.data_receive);
end


% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'getMeasCurrentTpc');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end