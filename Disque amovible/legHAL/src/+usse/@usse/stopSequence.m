% USSE.USSE.STOPSEQUENCE (PUBLIC)
%   Stop the loaded ultrasound sequence.
%
%   OBJ = OBJ.STOPSEQUENCE() stops the loaded ultrasound sequence.
%
%   OBJ = OBJ.STOPSEQUENCE(PARNAME, PARVALUE, ...) stops the loaded ultrasound
%   sequence with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - WAIT (int32) wait parameter.
%       0 = stop immediatly, 1 = wait for the sequence to end
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function obj = stopSequence(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' stopSequence function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);

elseif rem(nargin - 1, 2) == 1

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' stopSequence function needs ' ...
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
                    upper(class(obj)) ' stopSequence function: \n' ...
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
    ErrMsg = ['The ' upper(class(obj)) ' stopSequence function needs the ' ...
        'IP address of the remote server.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

Popup = obj.getParam('Popup');

%% Control if a remote sequence is still running

% Get system status
Msg    = struct('name', 'get_status');
Status = remoteSendMessage(obj.Server, Msg);

% Sequence is running ?
if str2num(Status.rfsequencerunning)

	if Popup == 1
		ChoiceMsg = 'A sequence is already running, do you want to stop it ?';
		Choice    = questdlg(ChoiceMsg, 'Stop Sequence', 'Yes', 'Wait', 'Wait');

		switch Choice
		    case 'Yes'
		        Wait = 0;

		    case 'Wait'
		        Wait = 1;
		end
	end

    if Wait == 0
        warning( 'A sequence is still running, stopping it' )

    elseif Wait == 1

        warning( 'A sequence is still running, waiting it ends' )
        while str2num( Status.rfsequencerunning )

            Status = remoteSendMessage(obj.Server, Msg);
            pause(.05);

            % Control if the sequence should be stopped
            if Popup == 1
                if ishandle(obj.StopDlg)

                    Button     = findobj(obj.StopDlg, 'Tag', 'StopSeq');
                    ButtonName = get(Button, 'String');
                    if ( strcmpi(ButtonName(1:5), 'Start') )
                        Status.rfsequencerunning = '0';
                    end

                else
                    Status.rfsequencerunning = '0';
                end
            end
        end

    end
end

% ============================================================================ %
% ============================================================================ %

%% Stop the sequence

% Stop loaded sequence
Msg = struct('name', 'start_stop_sequence', 'start', 0);
Status = remoteSendMessage(obj.Server, Msg);

% Sequence was not correctly stopped
if ~strcmpi(Status.type, 'ack')
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The REMOTE sequence could not be stopped.';
    error(ErrMsg);
    
end

% ============================================================================ %

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

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if isempty(Exception.identifier)
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'stopSequence');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end