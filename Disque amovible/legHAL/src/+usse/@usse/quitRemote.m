% USSE.USSE.QUITREMOTE (PUBLIC)
%   Switch the system to user level.
%
%   OBJ = OBJ.QUITREMOTE() switches the system to user level.
%
%   OBJ = OBJ.INITIALIZEREMOTE(PARNAME, PARVALUE, ...) initializes the remote
%   server with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - IPADDRESS (char) sets the IP address of the remote server.
%     - IMAGINGMODE (char) sets the imaging mode.
%       B = B-mode, COL - color, SWE = elastography, PW = power doppler mode
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/10

function obj = quitRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' quitRemote function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif ( rem(nargin - 1, 2) == 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' quitRemote function needs ' ...
        'an even number of input arguments: \n' ...
        '    - IPADDRESS sets the IP address of the remote server,\n'
        '    - IMAGINGMODE sets the imaging mode (B/COL/SWE/PW).'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Retrieve input arguments
IPaddress   = '';
ImagingMode = 'B';
if ( nargin > 1 )
    for k = 1 : 2 : (nargin - 1)
        switch lower(varargin{k})
            
            case 'IPaddress'
                IPaddress = varargin{k+1};
                
            case 'imagingmode'
                ImagingMode = varargin{k+1};
                
            otherwise
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(varargin{k}) ' property does ' ...
                    'not belong to the input arguments of the ' ...
                    upper(class(obj)) ' quitRemote function: \n' ...
                    '    - IPADDRESS sets the IP address of the ' ...
                    'remote server,\n'
                    '    - IMAGINGMODE sets the imaging mode (B/COL/SWE/PW).'];
                error(ErrMsg);
                
        end
    end
end

% ============================================================================ %

% Check IPADDRESS variable
if ( ~isempty(IPaddress) )
    
    if ( ~ischar(IPaddress) )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The IPADDRESS should be a character value corresponding ' ...
            'to the remote server IP address.'];
        error(ErrMsg);
        
    end
    
    if ( strcmpi(IPaddress, 'local') )
        
        obj.Server.type = 'local';     % extern / local
        obj.Server.addr = '127.0.0.1'; % IP address (local: 127.0.0.1)
        
    elseif ( length(strfind(IPaddress, '.')) == 3 )
        
        obj.Server.type = 'extern';    % extern / local
        obj.Server.addr = IPaddress; % IP address
        
    else
        
        % Build the prompt of the help dialog box
        ErrMsg = ['The IPaddress value is not supported. It can be set to:\n' ...
            '  - LOCAL if the remote server is on the same computer,\n' ...
            '  - XXX.XXX.XXX.XXX IP addresses where X are figures.'];
        error(ErrMsg);
        
    end
    
elseif ( isempty(obj.Server.addr) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' quitRemote function needs an IP ' ...
        'address to be defined.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Check the IMAGINGMODE variable
if ( ~ischar(ImagingMode) )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The IMAGINGMODE should be a character value (B, COL, SWE, PW).';
    error(ErrMsg);
    
elseif ( ~strcmpi(ImagingMode, 'B') && ~strcmpi(ImagingMode, 'COL') ...
        && ~strcmpi(ImagingMode, 'SWE') && ~strcmpi(ImagingMode, 'PW') )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The IMAGINGMODE cannot be set to ' upper(ImagingMode) '. It ' ...
        'should be set to: B, COL, SWE or PW.'];
    error(ErrMsg);
    
else
    
    ImagingMode = upper(ImagingMode);
    
end

% ============================================================================ %

% Check the REMOTE system address
if ( isempty(obj.Server.addr) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' loadSequence function needs the ' ...
        'IP address of the remote server.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Set the remote server to system level

% Get system status
Msg    = struct('name', 'get_status');
Status = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE server is not running on the host.';
    error(ErrMsg);
end

% ============================================================================ %

% Set the REMOTE level to user_coarse
Msg = struct('name', 'set_level', 'level', 'user_coarse');
Status = remoteSendMessage(obj.Server, Msg);

if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The host REMOTE status could not be set to USER_COARSE.';
    error(ErrMsg);
end

% ============================================================================ %

% Unfreeze the system
Msg    = struct('name', 'freeze', 'active', 0);
Status = remoteSendMessage(obj.Server, Msg);

if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The host could not be unfreezed.';
    error(ErrMsg);
end

% ============================================================================ %

% Restore B-mode
Msg.name        = 'set_user_sequence';
Msg.mode_action = 'value';
Msg.mode_value  = ImagingMode;
Status          = remoteSendMessage(obj.Server, Msg);

if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = ['The system could not be set to the ' ImagingMode ' imaging ' ...
        'mode.'];
    error(ErrMsg);
end

% Wait for imaging mode transition
pause(0.5);

% ============================================================================ %

% Freeze the system
Msg    = struct('name', 'freeze', 'active', 1);
Status = remoteSendMessage(obj.Server, Msg);

if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The host could not be freezed.';
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
            common.legHAL.GetException(Exception, class(obj), 'quitRemote');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end