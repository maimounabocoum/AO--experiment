% REMOTE.EVENT.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the REMOTE.EVENT instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the REMOTE.EVENT instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.EVENT.
%   It cannot be used without all methods of the remoteclass REMOTE.EVENT and
%   all methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic
%   Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( (nargout ~= 1) && (nargout ~= 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function requires 1 ' ...
        'or 2 output argument:\n' ...
        '    1. the output fields,\n' ...
        '    1. the output field labels (optional).'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Control of genExtTrigDelay
GenExtTrig = obj.getParam('genExtTrig');
if ( GenExtTrig == 0 )
    obj = obj.setParam('genExtTrigDelay', 0);
end

% ============================================================================ %

% Build the generic COMMON.REMOTEOBJ structure
[Fields Labels] = buildRemote@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %

% Scale genExtTrig duration & delay
IdxGenExtTrig              = find(strcmp('genExtTrig', Labels), 1, 'first');
Fields{IdxGenExtTrig}      = int32(Fields{IdxGenExtTrig} * 1000);
IdxGenExtTrigDelay         = find(strcmp('genExtTrigDelay', Labels), 1, 'first');
Fields{IdxGenExtTrigDelay} = int32(Fields{IdxGenExtTrigDelay} * 1000);

% ============================================================================ %
% ============================================================================ %

%% Additional fields

% Fields to be computed later
Fields{end+1} = int32(1); % tgcId
Fields{end+1} = int32(1); % modeId
Fields{end+1} = int32(0); % pauseForEndDma
Fields{end+1} = int32(0); % jumpToEventId
Fields{end+1} = int32(1); % incrementLocalBufAddr

% ============================================================================ %

% Period extend mode or not
IdxDuration = find(strcmp('duration', Labels), 1, 'first');
if ( Fields{IdxDuration} > 2048 )
    Fields{IdxDuration} = int32(ceil(Fields{IdxDuration} / 5000) * 5000);
    Fields{end+1}       = int32(1); % periodExtend
else
    Fields{end+1} = int32(0); % periodExtend
end

% ============================================================================ %

% Add NOOPMULTIPLIER field
Fields{end+1} = int32(1);

% ============================================================================ %

% Check output arguments
if ( obj.NbRemotePars ~= size(Fields, 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
else
%     varargout{1} = Struct;
    varargout{1} = Fields;
    
    % Export Labels
    if ( nargout == 2 )
        % Additional label
        Labels{end+1} = 'tgcId';
        Labels{end+1} = 'modeId';
        Labels{end+1} = 'pauseForEndDma';
        Labels{end+1} = 'jumpToEventId';
        Labels{end+1} = 'incrementLocalBufAddr';
        Labels{end+1} = 'periodExtend';
        Labels{end+1} = 'noopMultiplier';
        
        varargout{2} = Labels;
    end
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'buildRemote');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end