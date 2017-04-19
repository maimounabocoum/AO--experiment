% COMMON.REMOTEOBJ.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the COMMON.REMOTEOBJ instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the COMMON.REMOTEOBJ instance.
%
%   Note - This function is defined as a method of the class COMMON.REMOTEOBJ.
%   It cannot be used without all methods of the class COMMON.REMOTEOBJ and the
%   superclass COMMON.OBJECT developed by SuperSonic Imagineand without a system
%   with a REMOTE server running.
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
        '    2. the output field labels (optional).'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Control the MATLAB INTERFACE
if ( nargin ~= 2 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function was not ' ...
        'called by a supported MATLAB INTERFACE'];
    error(ErrMsg);
    
elseif ( ~isnumeric(varargin{1}) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function was not ' ...
        'called by a supported MATLAB INTERFACE'];
    error(ErrMsg);
    
elseif ( length(unique(varargin{1})) ~= 5 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function was not ' ...
        'called by a supported MATLAB INTERFACE'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Export all remote parameters

% Determine the index of all remote parameters
varargout{1} = struct;
Idx = find(cell2mat(obj.Pars(:,4)) == 1);

% Loop over all remote parameters
if ( ~isempty(Idx) )
    Fields = cell(1, length(Idx));
    TmpPar = obj.Pars(Idx, 3);
    for k = 1 : length(Idx)
        Fields{k} = TmpPar{k}.Value;
    end
    
    varargout{1} = Fields;
    
    % Export Labels
    if ( nargout == 2 )
        Labels(1,:) = obj.Pars(Idx, 1);
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