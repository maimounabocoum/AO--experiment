% USSE.USSE.INITIALIZEREMOTE (PUBLIC)
%   Initialize the remote server.
%
%   OBJ = OBJ.INITIALIZEREMOTE() initializes the remote server characterized by
%   the SERVER variable of the USSE.USSE instance.
%
%   OBJ = OBJ.INITIALIZEREMOTE(PARNAME, PARVALUE, ...) initializes the remote
%   server with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - IPaddress (char) sets the IP address of the remote server.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/10

function obj = initializeRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check function syntax
if nargout ~= 1
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' initializeRemote function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif rem(nargin - 1, 2) == 1
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' initializeRemote function needs ' ...
        'an even number of input arguments: \n' ...
        '    - IPaddress sets the IP address of the remote server.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Init input arguments
InitPath     = 1;
IPaddress    = '';
InitSequence = 1;
InitRxFreq   = 60;
InitTGC      = 500; % best if next event has either a TGC of 0 or 1000
GetConnectedProbes = 0;
Debug = 0;

% Retrieve input arguments
if nargin > 1
    for k = 1 : 2 : (nargin - 1)
        switch varargin{k}

            case 'InitPath'
                InitPath = varargin{k+1};

            case 'IPaddress'
                IPaddress = varargin{k+1};

            case 'InitSequence'
                InitSequence = varargin{k+1};

            case 'InitRxFreq'
                InitRxFreq = varargin{k+1};

            case 'InitTGC'
                InitTGC = varargin{k+1};
                
            case 'GetConnectedProbes'
                GetConnectedProbes = varargin{k+1};

            case 'Debug'
                Debug = varargin{k+1};

            otherwise
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(varargin{k}) ' property does ' ...
                    'not belong to the input arguments of the ' ...
                    upper(class(obj)) ' initializeRemote function: \n' ...
                    '    - IPaddress sets the IP address of the remote server.'];
                error(ErrMsg);

        end
    end
end

% ============================================================================ %

% Check IPADDRESS variable
if ~isempty(IPaddress)
    
    if ~ischar(IPaddress)
        % Build the prompt of the help dialog box
        ErrMsg = ['The IPaddress should be a character value corresponding ' ...
            'to the remote server IP address.'];
        error(ErrMsg);
        
    end
    
    if strcmpi(IPaddress, 'local')
        obj.Server.type = 'local';     % extern / local
        obj.Server.addr = '127.0.0.1'; % IP address (local: 127.0.0.1)
        
    elseif length(strfind(IPaddress, '.')) == 3
        obj.Server.type = 'extern';    % extern / local
        obj.Server.addr = IPaddress; % IP address
        
    else
        % Build the prompt of the help dialog box
        ErrMsg = ['The IPaddress value is not supported. It can be set to:\n' ...
            '  - LOCAL if the remote server is on the same computer,\n' ...
            '  - XXX.XXX.XXX.XXX IP addresses where X are figures.'];
        error(ErrMsg);
        
    end
    
elseif isempty(obj.Server.addr)
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' initializeRemote function needs ' ...
        'an IP address to be defined.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Check the status of the system and look for the right libRemote to use

if InitPath

    lib_dir_name = 'libRemote';

    A = which('common.legHAL');
    lib_dir = [ A(1:end-25) '/../lib/' ];
    all_libs = dir ( [ lib_dir lib_dir_name '*' ] );

    for n = 1:length(all_libs)
        lib_path = all_libs(n).name;

        % remove old libClientCommonRemote from path
        C = textscan( path, ['%s'], 'Delimiter',pathsep );
        for n_lib = 1:length( C{1} )
            if ~isempty( regexp( C{1}{n_lib}, lib_dir_name ) )
                disp( [ 'Removing path ' C{1}{n_lib} ] )
                rmpath ( C{1}{n_lib} )
            end
        end

        % add path to test
        addpath( [ lib_dir lib_path ] )
        % check
        C = textscan( path, ['%s' lib_dir_name '%s'], 'Delimiter',pathsep );
        current_path = C{1}{1}; % only first found

        % Get system status
        Msg    = struct('name', 'get_status');
        warning off
        Status = remoteSendMessage(obj.Server, Msg);
        warning on

        if strcmpi(Status.type, 'ack')
            disp( [ 'Found a valid ' lib_dir_name ' in ' current_path ] )
            break
        end
    end

    % Message could not be sent
    if ~strcmpi(Status.type, 'ack')
        if strcmpi( Status.type, 'bad_message_validity' )
            ErrMsg = 'Unable to find a libRemote compatible with the one running on the host.';
        else
            ErrMsg = 'The REMOTE server is not running on the host.';
        end
        error(ErrMsg);
    end

else
     % Get system status
     Msg    = struct('name', 'get_status');
     Status = remoteSendMessage(obj.Server, Msg);
     
     if ~strcmpi(Status.type, 'ack')
         ErrMsg = 'The REMOTE server is not running on the host.';
         error(ErrMsg);
     end
            
end

% Check REMOTE version
Msg    = struct( ...
    'name', 'check_remote_version', ...
    'version', common.legHAL.Version );
Status = remoteSendMessage(obj.Server, Msg);
obj.ServerInfos.version = Status.server_version;
obj.ServerInfos.version

% Control the compatibility
if ~sum(strcmp(common.legHAL.SupportedVersions, obj.ServerInfos.version ) )
    % Build the prompt of the help dialog box
    ErrMsg = ['The version of this legHAL package does not support ' ...
        'server version ' Status.server_version ' of legHAL.' ];
    error(ErrMsg);
end

if GetConnectedProbes
    % Only for V6
    if  strcmp( obj.ServerInfos.version, '1.7' ) || ...
        strcmp( obj.ServerInfos.version, '1.8' ) || ...
        strcmp( obj.ServerInfos.version, '1.8.1' )

        % The level should be user_coarse
        Msg    = struct('name', 'get_status');
        Status = remoteSendMessage(obj.Server, Msg);
        if ~strcmpi(strtrim(Status.level), 'user_coarse')
            % Set the REMOTE level
            Msg = struct('name', 'set_level', 'level', 'user_coarse');
            Status = remoteSendMessage(obj.Server, Msg);

            if ~strcmpi(Status.type, 'ack')
                ErrMsg = 'The host REMOTE status could not be set to USER COARSE.';
                error(ErrMsg);
            end
        end

        % Get connected probe
        Msg    = struct( 'name', 'get_connected_probes' );
        Status = remoteSendMessage(obj.Server, Msg);
        if ~strcmpi(Status.type, 'ack')
            ErrMsg = 'Could not get the list of connected probes.';
            error(ErrMsg);
        end
        obj.ServerInfos.last_preset = Status.preset;
        obj.ServerInfos.last_probe_connected = Status.probe_connected ;
        obj.ServerInfos.probes_connected_list = Status.probes_connected_list ;
        obj.ServerInfos.serial_probes_connected_list = Status.serial_probes_connected_list ;
        obj.ServerInfos.last_target = Status.target ;

    else
        WrnMsg = 'Can''t get connected probes with this version of Aixplorer' ;
        warning ( WrnMsg );
    end
end

% ============================================================================ %
% ============================================================================ %

%% Initialize remote

% Get system status
Msg    = struct('name', 'get_status');
Status = remoteSendMessage(obj.Server, Msg);

% The level should be system
if ~strcmpi(strtrim(Status.level), 'system')
    % Freeze the system before setting the REMOTE level
    if str2double(Status.freeze) ~= 1
        Msg    = struct('name', 'freeze', 'active', 1);
        Status = remoteSendMessage(obj.Server, Msg);
        
        if ~strcmpi(Status.type, 'ack')
            % Build the prompt of the help dialog box
            ErrMsg = 'The host could not be freezed.';
            error(ErrMsg);
        end
    end
    
    % Set the REMOTE level
    Msg = struct('name', 'set_level', 'level', 'system');
    Status = remoteSendMessage(obj.Server, Msg);
    
    if ~strcmpi(Status.type, 'ack')
        % Build the prompt of the help dialog box
        ErrMsg = 'The host REMOTE status could not be set to SYSTEM.';
        error(ErrMsg);
    end
end

% Set the format of output data
Msg    = struct('name', 'set_output_format', ...
    'format', obj.getParam('DataFormat'));
Status = remoteSendMessage(obj.Server, Msg);
if ~strcmpi(Status.type, 'ack')
    % Build the prompt of the help dialog box
    ErrMsg = ['The format of output data could not be set to ' ...
        obj.getParam('DataFormat') '.'];
    error(ErrMsg);
end


% ============================================================================ %

if InitSequence == 1
    % load and run a "init bls" sequence that only receive
    % originaly a work arround for bls error on LTE when running transmit only
    % sequences just after startup (after 15 mins power off)

    ELUSEV = elusev.init_bls( 'RxFreq',single(InitRxFreq) );

    ACMO = acmo.acmo( ...
        'elusev', ELUSEV, ...
        'ControlPts', InitTGC, ...
        0);

    SEQinit = usse.usse( ...
        'acmo', ACMO, 'Popup',0, ...
        0);
    
    % Build remote structure
    [SEQinit NbAcq] = SEQinit.buildRemote();

    SEQinit = SEQinit.initializeRemote( 'IPaddress',IPaddress, 'InitSequence',0, 'GetConnectedProbes',0, 'InitPath',0 );
    SEQinit = SEQinit.loadSequence();
    SEQinit = SEQinit.startSequence();
    SEQinit = SEQinit.stopSequence( 'Wait',1 );

    disp('remote system operetional');
end

%% End error handling
catch Exception
    
    % Exception in this method
    if isempty(Exception.identifier)
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'initializeRemote');
        throw(NewException);

    % Re-emit previous exception
    else
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end
