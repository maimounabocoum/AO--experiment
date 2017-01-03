% REMOTE.TPC.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the REMOTE.MODE instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the REMOTE.MODE instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.TPC.
%   It cannot be used without all methods of the remoteclass REMOTE.TPC and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
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

% Build the generic COMMON.REMOTEOBJ structure
if ( nargout == 2 )
    [Fields Labels] = buildRemote@common.remoteobj(obj, varargin{1:end});
else
    Fields = buildRemote@common.remoteobj(obj, varargin{1:end});
end

% ============================================================================ %
% ============================================================================ %

%% Dedicated Remote structure fields

Fields{end+1} = int32(1);  % mode
Fields{end+1} = single(1); % txeRatio

% ============================================================================ %

%% Check output arguments

if ( obj.NbRemotePars ~= size(Fields, 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
else
    varargout{1} = Fields;
    
    % Export Labels
    if ( nargout == 2 )
        % Additional label
        Labels{end+1} = 'mode';
        Labels{end+1} = 'txeRatio';
        
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