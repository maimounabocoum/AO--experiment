% USSE.USSE.STOPSYSTEM (PUBLIC)
%   Stop the remote host.
%
%   OBJ = OBJ.STOPSYSTEM() stops the remote host.
%
%   OBJ = OBJ.STOPSYSTEM(PARNAME, PARVALUE, ...) stops the remote host with
%   parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - IPADDRESS (char) sets the IP address of the remote server.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/12/08

function obj = stopSystem(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' stopSystem function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif ( rem(nargin - 1, 2) == 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' stopSystem function needs  an ' ...
        'even number of input arguments: \n' ...
        '    - IPADDRESS sets the IP address of the remote server.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Retrieve input arguments
IPaddress = '';
if ( nargin > 1 )
    for k = 1 : 2 : (nargin - 1)
        switch varargin{k}
            
            case 'IPaddress'
                IPaddress = varargin{k+1};
                
            otherwise
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(varargin{k}) ' property does ' ...
                    'not belong to the input arguments of the ' ...
                    upper(class(obj)) ' stopSystem function: \n' ...
                    '    - IPaddress sets the IP address of the remote server.'];
                error(ErrMsg);
                
        end
    end
end

% ============================================================================ %

% Check IPaddress variable
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
    ErrMsg = ['The ' upper(class(obj)) ' stopSystem function needs  an IP ' ...
        'address to be defined.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Stop the system

% Set to user level
obj = obj.quitRemote();

% ============================================================================ %

% Stops the system
Msg    = struct('name', 'quit_requested');
Status = remoteSendMessage(obj.Server, Msg);

if ( ~strcmpi(Status.type, 'ack') )
    % Build the prompt of the help dialog box
    ErrMsg = 'The host could not be stopped.';
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
            common.legHAL.GetException(Exception, class(obj), 'stopSystem');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end