% USSE.LTE.GETDATA (PUBLIC)
%   Wait for data and retrieve them.
%
%   BUFFER = OBJ.GETDATA() returns the structure BUFFER containing the acquired
%   data as well as several data descriptors.
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function buffer = getData(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' getData function needs 1 ' ...
        'output argument corresponding to the buffer for data.'];
    error(ErrMsg);
    
elseif ( rem(nargin - 1, 2) == 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getData function needs an ' ...
        'even number of input arguments: \n' ...
        '    - REALIGN realigns RF data if set to 1.'];
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

% ============================================================================ %
% ============================================================================ %

%% Wait and retrieve data

% Get remote output format
Msg    = struct('name', 'get_status');
Msg    = remoteSendMessage(obj.Server, Msg);
Format = strtrim(Msg.outputformat);

% Check the data type exists
DataFormat = obj.getParam('DataFormat');
if ( ~strcmpi(Format, DataFormat) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The output format ' upper(Format) ' is not supported.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% RF data
if ( strcmpi(DataFormat, 'RF') )
    
    buffer = getData@usse.usse(obj, 'Realign', 1, varargin{1:end});
    
else
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The output format ' upper(DataFormat) ' is not supported.'];
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
            common.legHAL.GetException(Exception, class(obj), 'getData');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end