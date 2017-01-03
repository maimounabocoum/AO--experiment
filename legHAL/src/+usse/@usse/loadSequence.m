% USSE.USSE.LOADSEQUENCE (PUBLIC)
%   Load the ultrasound sequence.
%
%   OBJ = OBJ.LOADSEQUENCE() loads the ultrasound sequence of the USSE.USSE
%   instance.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/09

function obj = loadSequence(obj, varargin)

% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

if ( nargout ~= 1 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' loadSequence function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);

elseif ( (nargin ~= 1) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' loadSequence function does not ' ...
        'need any input argument.'];
    error(ErrMsg);
    
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

% Check if the host is initialized

% Get system status
Msg    = struct('name', 'get_status');
Status = remoteSendMessage(obj.Server, Msg);

% Message could not be sent
if ( ~strcmpi(Status.type, 'ack') )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE server is not running on the host.';
    error(ErrMsg);
    
elseif ( ~strcmpi(strtrim(Status.level), 'system') )
    
    obj = obj.initializeRemote();
    
end

% Check if a sequence has been built
if ( isempty(obj.RemoteStruct) )
    
    obj = obj.buildRemote();
    
end

% ============================================================================ %
% ============================================================================ %

%% Load the sequence

% Compression mode
Comp.name               = 'load_sequence';
Comp.compressed         = 0;
Comp.compression_engine = 'gz';
Comp.compression_level  = 1;

% Control sequence
RemoteStruct = obj.RemoteStruct;
TmpKey = length(RemoteStruct.event) * 42 ...
    + (length(RemoteStruct.rx))^2 * 42 ...
    - length(RemoteStruct.tpc);
RemoteStruct.general = setfield(RemoteStruct.general, 'key', int32(TmpKey));

% Load sequence on system
Status = remoteSendSequence(obj.Server, RemoteStruct, Comp);
clear RemoteStruct;

% Sequence correctly loaded
if ( strcmpi(Status.type, 'seq_key_false') )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The REMOTE sequence was not loaded with a supported legHAL ' ...
        'package.'];
    error(ErrMsg);
    
elseif ( ~strcmpi(Status.type, 'ack') )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE sequence was not correctly loaded.';
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
            common.legHAL.GetException(Exception, class(obj), 'loadSequence');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end