% USSE.USSE.STARTSEQUENCE (PUBLIC)
%   Start the loaded ultrasound sequence.
%
%   OBJ = OBJ.STARTSEQUENCE() starts the loaded ultrasound sequence.
%
%   OBJ = OBJ.STARTSEQUENCE(PARNAME, PARVALUE, ...) starts the loaded ultrasound
%   sequence with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - WAIT (int32) wait parameters.
%       0 = start immediatly, 1 = wait for previous sequence to stop
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function obj = startSequence(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if nargout ~= 1
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' startSequence function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif rem(nargin - 1, 2) == 1
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' startSequence function needs ' ...
        'an even number of input arguments: \n' ...
        '    - "Wait" : wait for previous sequence stop.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Retrieve arguments
Wait = 1;
if nargin > 1
    for k = 1 : 2 : (nargin - 1)
        switch lower(varargin{k})
            
            case 'wait'
                Wait = varargin{k+1};
                
            otherwise
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(varargin{k}) ' property does not ' ...
                    'belong to the input arguments of the ' ...
                    upper(class(obj)) ' startSequence function: \n' ...
                    '    - "Wait" : wait for previous sequence stop if set ' ...
                    'to 1.'];
                error(ErrMsg);
                
        end
    end
end

% ============================================================================ %

% Check the REMOTE system address
if isempty(obj.Server.addr)
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' startSequence function needs the ' ...
        'IP address of the remote server.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Control if a remote sequence was loaded and is still running

% Get system status
Msg    = struct('name', 'get_status');
Status = remoteSendMessage(obj.Server, Msg);

% Remote sequence was loaded
if ~strcmpi(strtrim(Status.rfsequencetype), 'remote')
    
    Msg    = 'The remote sequence is not loaded. Do you want to load it?';
    Choice = questdlg(Msg, 'Start Sequence', 'Yes', 'No', 'Yes');
    
    switch Choice
        
        case 'Yes'
            obj = obj.loadSequence();
            
        otherwise
            % Build the prompt of the help dialog box
            ErrMsg = 'The remote sequence should be loaded...';
            error(ErrMsg);
            
    end
end

% ============================================================================ %

Popup = obj.getParam('Popup');

% Sequence is running?
if str2num(Status.rfsequencerunning)

	if Popup == 1
		ChoiceMsg = 'A sequence is already running, do you want to restart it ?';
		Choice    = questdlg(ChoiceMsg, 'Start Sequence', 'Yes', 'Wait', 'Wait');

		switch Choice
		    case 'Yes'
		        Wait = 0;

		    case 'Wait'
		        Wait = 1;
		end
	end

	if Wait == 0

		warning( 'A sequence is running, stopping it' )
        obj = obj.stopSequence( 'Wait', 0 );

	elseif Wait == 1

		WarningMsg = 'A sequence is still running, waiting it ends';

		warning( WarningMsg )

        obj = obj.stopSequence( 'Wait', 1 );

    end
    
end

% ============================================================================ %
% ============================================================================ %

%% Start the sequence

% Start loaded sequence
Msg = struct('name', 'start_stop_sequence', 'start', 1);
Status = remoteSendMessage(obj.Server, Msg);

% Sequence was not correctly started
if ~strcmpi(Status.type, 'ack')
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE sequence could not be started.';
    error(ErrMsg);
    
end

% % ============================================================================ %

if Popup == 1
    % Create the stop window figure
    obj.StopDlg = figure( ...
        'WindowStyle', 'normal', ...
        'DockControls', 'off', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none', ...
        'NumberTitle', 'off', ...
        'Name', 'Sequence is running...', ...
        'Tag', 'USSE.USSE.StopDlg');

    % Set the position
    Position    = get(obj.StopDlg, 'Position');
    Position(3) = 250;
    Position(4) = 50;
    set(obj.StopDlg, 'Position', Position);

    % Add stop button
    uicontrol( ...
        'Parent', obj.StopDlg, ...
        'Style', 'pushbutton', ...
        'String', 'Stop Sequence', ...
        'Position', [35 10 180 30], ...
        'Callback', @(src, evnt)callbacks(obj, src, evnt), ...
        'Tag', 'StopSeq');

    % Show the dialog box
    set(obj.StopDlg, 'Visible', 'on');
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if isempty(Exception.identifier)
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'startSequence');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end