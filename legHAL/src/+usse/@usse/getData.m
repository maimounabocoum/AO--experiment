% USSE.USSE.GETDATA (PUBLIC)
%   Wait for data and retrieve them.
%
%   BUFFER = OBJ.GETDATA() returns the structure BUFFER containing the acquired
%   data as well as several data descriptors.
%
%   BUFFER = OBJ.GETDATA(PARNAME, PARVALUE, ...) returns the structure BUFFER
%   with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - REALIGN (int32) enables the realignment of RF data.
%       0 = no realignment, 1 = realignment
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function buf = getData(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

global global_usse_getData;
global_usse_getData.Timeout_occured = 0;

% Start error handling
try

Popup = obj.getParam('Popup');

% ============================================================================ %
% ============================================================================ %
global_usse_getData.Timeout = common.constants.GetDataTimeout;
Timeout_message = '';

status_type_data = { ... % key, message, action_stop_sequence_now
      'data_not_available', 'The sequence was stopped.', 1 ...
    ; 'data_not_available_and_seq_stop', 'The sequence was stopped because of the sequence timeout.', 1 ...
    ; 'data_host_buffer_full', 'The sequence was stopped because no host buffer are available and dropping frames is not authorized.', 1 ...
    ; 'alert_trigin_timeout', 'The sequence was stopped because no trig in signal was received', 1 ...
    };

%% General controls on the method

% Check function syntax
if nargout ~= 1
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getData function needs 1 ' ...
        'output argument corresponding to the buffer for data.'];
    error(ErrMsg);
    
elseif rem(nargin - 1, 2) == 1
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getData function needs an ' ...
        'even number of input arguments: \n' ...
        '    - REALIGN realigns RF data if set to 1.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Retrieve input arguments
Realign = 0; % 1: realigned only, 2: realign + not realigned

if nargin > 1
    for k = 1 : 2 : (nargin - 1)
        switch lower(varargin{k})
            
            case 'realign'
                Realign = varargin{k+1};
                
            case 'timeout'
                global_usse_getData.Timeout = varargin{k+1};

            case 'data_timeout'
                if ischar( varargin{k+1} )
                    Timeout_message = varargin{k+1};
                else
                    ErrMsg = [ 'The ' varargin{k} ' property must be set to a valid string value.' ];
                    error(ErrMsg);
                end

            otherwise
                
                % test if parameter is defining a new message
                message_id = find( strcmp( varargin{k}, status_type_data(:,1) ), 1, 'first' );
                if ~isempty( message_id )
                    if ischar( varargin{k+1} )
                        status_type_data { message_id, 2 } = varargin{k+1} ;
                    else
                        ErrMsg = [ 'The ' varargin{k} ' property must be set to a valid string value.' ];
                        error(ErrMsg);
                    end

                else
                    % Build the prompt of the help dialog box
                    str_cr = sprintf('\n');
                    ErrMsg = [ 'The ' upper(varargin{k}) ' property does ' ...
                        'not belong to the input arguments of the ' ...
                        upper(class(obj)) ' getData function: ' str_cr ...
                        '    - - REALIGN realigns RF data if set to 1.' str_cr ...
                        '    - - TIMEOUT sets the getData() time out in s.' str_cr ...
                        '    - - DATA_TIMEOUT sets the message when TIMEOUT occurs.' str_cr ...
                        '    - - DATA_NOT_AVAILABLE sets the message when the sequence was stopped.' str_cr ...
                        '    - - DATA_NOT_AVAILABLE_AND_SEQ_STOP sets the message when the sequence was stopped because of the sequence timeout.' str_cr ...
                        '    - - DATA_HOST_BUFFER_FULL sets the message when the sequence was stopped because no host buffer are available and dropping frames is not authorized.' str_cr ...
                        ];
                    error(ErrMsg);
                end
        end
    end
end

if isempty( Timeout_message )
    Timeout_message = [ 'getData Timeout after ' num2str(global_usse_getData.Timeout) ' s' ] ;
end

% ============================================================================ %
% ============================================================================ %

%% Control the remote server connection

% Check the existence of the remote server
if isempty(obj.Server.addr)
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getData function needs an IP ' ...
        'address to be defined.'];
    error(ErrMsg);
end

% ============================================================================ %

if Popup == 1
    % Control if the sequence should be stopped
    if ishandle(obj.StopDlg)

        Button     = findobj(obj.StopDlg, 'Tag', 'StopSeq');
        ButtonName = get(Button, 'String');
        if strcmpi(ButtonName(1:5), 'Start')

            % Build the prompt of the help dialog box
            ErrMsg = 'The sequence was manually stopped.';
            error(ErrMsg);

        end

    else

        % Build the prompt of the help dialog box
        ErrMsg = 'The sequence was stopped before retrieving all data.';
        error(ErrMsg);

    end
end

% ============================================================================ %

% Get remote output format
Msg    = struct('name', 'get_status');
Msg    = remoteSendMessage(obj.Server, Msg);
Format = strtrim(Msg.outputformat);

% Check the data type exists
DataFormat = obj.getParam('DataFormat');
if ~strcmpi(Format, DataFormat)
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The output format ' upper(Format) ' is not supported.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Wait and retrieve data

% RF data
if strcmpi(DataFormat, 'RF')
    
    % Buffer initialization
    buf.data          = int16(0);
    buf.alignedOffset = uint32(0);
    buf.mode          = uint32(0);
    
    % Get RF data
    if Popup == 1
        controlSequenceFunction = 'usse.controlSequencePopup';
    else
        global_usse_getData.time = tic;
        controlSequenceFunction = 'usse.controlSequence';
    end

    if strcmp(obj.Server.addr, '127.0.0.1')
        Status = remoteGetShmRFData(obj.Server, buf, controlSequenceFunction );
    else
        Status = remoteGetRFData(obj.Server, buf, controlSequenceFunction );
    end

    if global_usse_getData.Timeout_occured % strcmp(Status.type, 'data_not_available') && 
        
        Msg    = struct('name', 'get_status');
        Msg    = remoteSendMessage(obj.Server, Msg);
        if isfield( Msg, 'alert' ) % for libRemote old versions that don't have 'alert' field
            if strcmp( Msg.alert, 'HWC_DMA_TIMEOUT_ALERT_4' )
                message_id = find( strcmp( 'alert_trigin_timeout', status_type_data(:,1) ), 1, 'first' );
                ErrMsg = status_type_data{ message_id, 2 };
                error(ErrMsg);
            end
        end

        ClassName = class(obj);
        ClassName(findstr(ClassName, '.')) = ':';
        ErrId = [upper(ClassName) ':' upper('getData')];
        NewException = ...
            MException(ErrId, Timeout_message);
        throw(NewException);
    end
    
    % Check status
    message_id = find( strcmp( strtrim(Status.type), status_type_data(:,1) ), 1, 'first' );
    
    if ~isempty( message_id )
        if status_type_data{ message_id,3 }
            obj = obj.stopSequence( 'Wait', 0 );
        end

        ErrMsg = status_type_data{ message_id, 2 };
        error(ErrMsg);

    end
    
    if ~strcmpi(strtrim(Status.type), 'ack')
        obj = obj.stopSequence( 'Wait', 0 );

        ErrMsg = 'An unknown error occured.';
        error(ErrMsg);

    end

    % Check data dimensions / buffer control
    if buf.data == 0

        % Build the prompt of the help dialog box
        ErrMsg = 'Empty data were retrieved.';
        error(ErrMsg);

    end
    
    % Realign data
    if Realign > 0

        % Alignment constants
        AlignOffset   = int32(buf.alignedOffset / 2);
        ChannelOffset = ...
            int32( obj.RemoteStruct.mode(buf.mode + 1).channelSize(1) / 2 );
        NbFirings     = ...
            length( obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1,:) );

        % Realigned buffer
        Data = buf.data(AlignOffset + 1 ...
            : AlignOffset + (ChannelOffset * system.hardware.NbRxChan));

        if Realign == 1
            buf = rmfield(buf, 'data');
        end
        Data = reshape(Data, [ChannelOffset system.hardware.NbRxChan]);

        % Buffer of the realigned data
        PiezoBuffer = zeros(...
            max(obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1,:)), ...
            system.probe.NbElemts, NbFirings, 'int16');

        % Relignment of data regarding rx channels
        Id0Samp = 0;
        for k = 1 : NbFirings

            % Constant values
            NSamples = obj.RemoteStruct.mode(buf.mode + 1).ModeRx(1, k);
            RxId     = obj.RemoteStruct.mode(buf.mode + 1).ModeRx(3, k);

            % Reshape data
            tmpIdx = mod(obj.InfoStruct.rx(RxId).Channels - 1, system.hardware.NbRxChan) + 1;
            PiezoBuffer(1:NSamples, obj.InfoStruct.rx(RxId).Channels, k) = ...
                Data(Id0Samp + (1:NSamples), tmpIdx);
            Id0Samp  = Id0Samp + NSamples;

        end

        clear Data;
        if Realign == 1
            buf.data = PiezoBuffer;
        elseif Realign == 2
            buf.RFdata = PiezoBuffer;
        end

    end

% ============================================================================ %

% BF data
elseif strcmpi(DataFormat, 'BF')
    
    % Buffer initialization
    buf.data       = int16(0);
    buf.nline      = uint32(0);
    buf.nsample    = uint32(0);
    buf.bytesample = uint32(0);
    
    % Get BF data
    remoteGetBFData(obj.Server, buf);
    
% ============================================================================ %

% Other data format
else
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The output format ' upper(DataFormat) ' is not supported.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    if Popup == 1
        % Close the stop dialog box
        if ishandle(obj.StopDlg)
            delete(obj.StopDlg);
            obj.StopDlg = [];
        end

        if ~isempty(obj.StopDlg)
            obj.StopDlg = [];
        end
    end

    % Exception in this method
    if isempty(Exception.identifier)
        
        test = ...
            strcmpi(strtrim(Exception.message), ...
            ['while waiting for data, communication exception: Conversion ' ...
            'to double from cell is not possible.']);

        % Emit the new exception
        if test
            ClassName = class(obj);
            ClassName(findstr(ClassName, '.')) = ':';
            ErrId = [upper(ClassName) ':' upper('getData')];
            NewException = ...
                MException(ErrId, 'The data transfer was manually stopped.');
            NewException = addCause(NewException, Exception);

        else
            NewException = ...
                common.legHAL.GetException(Exception, class(obj), 'getData');
        end
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end
