% USSE.USSE.CALLBACKS (PROTECTED)
%   Manages GUIs callbacks.
%
%   OBJ.CALLBACKS(SRC, EVENT) manages GUIs callbacks coming from the SRC handles
%   and corresponding to the EVENT event.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/22

function varargout = callbacks(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( nargout ~= 0 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' callbacks function does not need ' ...
        'any output argument.'];
    error(ErrMsg);
    
elseif ( (nargin ~= 3) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' callbacks function needs two ' ...
        'input arguments:\n' ...
        '1. the handle of the control,\n' ...
        '2. the event that called the method.'];
    error(ErrMsg);

end

% ============================================================================ %

% Empty output argument
varargout = [];

% ============================================================================ %
% ============================================================================ %

%% Callback behavior

% Retrieve parameters
Tag = get(varargin{1}, 'Tag');

switch Tag

% ============================================================================ %

    case 'StopSeq'
        
        ButtonName = get(varargin{1}, 'String');
        
        if ( strcmpi(ButtonName(1:4), 'Stop') )
            
            set(varargin{1}, 'String', 'Start Sequence');
            set(varargin{1}, 'Enable', 'off');
            
        else
            
            set(varargin{1}, 'String', 'Stop Sequence');
            set(varargin{1}, 'Enable', 'on');
            
        end

% ============================================================================ %

    otherwise
        
        disp(['Tag ' Tag ' is unknown...']);

% ============================================================================ %

end

% ============================================================================ %
% ============================================================================ %

end