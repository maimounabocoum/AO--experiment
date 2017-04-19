% USSE.CONTROLSEQUENCE (PUBLIC)
%   Control if a sequence has been manually stopped.
%
%   STOP = CONTROLSEQUENCE() returns 1 if a sequence has been stopped manually,
%   i.e. the STOP button of the dialog box has been pressed.
%
%   Note - This function is defined as a global method of USSE package. It
%   cannot be used without all methods of the remoteclass USSE.USSE developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/22

function varargout = controlSequence(varargin)
   
% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if nargout ~= 1

    % Build the prompt of the help dialog box
    ErrMsg = 'The controlSequence function needs an input argument.';
    error(ErrMsg);

elseif nargin ~= 0

    % Build the prompt of the help dialog box
    ErrMsg = 'The controlSequence function des not need any input argument.';
    error(ErrMsg);

end

% ============================================================================ %

% Initialize the output argument
varargout{1} = false;

% disp( 'controlSequence pause' )
pause(common.constants.GetDataPause);

global global_usse_getData;
if toc(global_usse_getData.time) > global_usse_getData.Timeout
    global_usse_getData.Timeout_occured = 1;
    warning( [ 'getData Timeout after ' num2str(common.constants.GetDataTimeout) ' s' ] )
    varargout{1} = true;
end

% ============================================================================ %
% ============================================================================ %

%% Check the existing stop sequence dialog boxes

% Retrieve the figure handle
Dlg = findobj('Tag', 'USSE.USSE.StopDlg');
if isempty(Dlg)

    varargout{1} = true;

% ============================================================================ %

else

    % TODO: find why this doesn't work
%     
%     % Retrieve the button handle and name
%     Button = cell( 1, length(Dlg) ); ButtonName = cell(1, length(Dlg) );
%     for k = 1 : length(Dlg)
%         Button{k}     = findobj(Dlg(k), 'Tag', 'StopSeq');
%         ButtonName{k} = get(Button{k}, 'String');
% 
%         if strcmpi(ButtonName{k}(1:5), 'Start')
%             varargout{1} = true;
%         end
%     end
% 
%     % Stop all running sequences
%     if varargout{1}
%         for k = 1 : length(Button)
%             set(Button(k), 'Enable', 'off');
%         end
%     end

end

% ============================================================================ %
% ============================================================================ %

end
