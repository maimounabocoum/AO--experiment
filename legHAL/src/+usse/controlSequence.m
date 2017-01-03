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
    ErrMsg = 'The controlSequence function needs an output argument.';
    error(ErrMsg);
    
elseif nargin ~= 0
    
    % Build the prompt of the help dialog box
    ErrMsg = 'The controlSequence function does not need any input argument.';
    error(ErrMsg);

end

% ============================================================================ %

% Initialize the output argument
varargout{1} = false;

% disp( 'controlSequence pause' )
pause(common.constants.GetDataPause);

global global_usse_getData;
toc_time = toc(global_usse_getData.time);

if toc_time > global_usse_getData.Timeout
    global_usse_getData.Timeout_occured = 1;
    varargout{1} = true;
end

% ============================================================================ %
% ============================================================================ %

end
