% REMOTE.FC.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the REMOTE.FC instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the REMOTE.FC instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.FC. It
%   cannot be used without all methods of the remoteclass REMOTE.FC and all
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
% ============================================================================ %

%% Set the digital filter coefficients

% Retrieve parameters
Bandwidth = double(obj.getParam('Bandwidth'));

% Build the data field
if ( Bandwidth == -1 )
    
    Fields{1,1} = repmat([0 0 0 0 0 1], 1, system.hardware.NbRxChan); % data
    
else
    
    [~, Idx] = min(abs(obj.DABFilterCoeff(:, 1) - Bandwidth/100));
    obj      = obj.setParam('Bandwidth', 100 * obj.DABFilterCoeff(Idx, 1));
    
    Fields{1,1} = ... % data
        repmat(obj.DABFilterCoeff(Idx, 2:7), 1, system.hardware.NbRxChan);
    
end

% ============================================================================ %

% Check output arguments
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
        Labels{1,1} = 'data';
        
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