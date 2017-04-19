% REMOTE.TW.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the REMOTE.TW instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the REMOTE.TW instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.TW. It
%   cannot be used without all methods of the remoteclass REMOTE.TW and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/30

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
[Fields Labels] = buildRemote@common.remoteobj(obj, varargin{1:end});

% ============================================================================ %

% Check dimension of REPEAT
IdxRepeat = find(strcmp('repeat', Labels), 1, 'first');
if ( (length(Fields{IdxRepeat}) ~= system.hardware.NbTxChan) ...
        && (length(Fields{IdxRepeat}) == 1) )
    Fields{IdxRepeat} = repmat(Fields{IdxRepeat}, [1 system.hardware.NbTxChan]);
elseif ( length(Fields{IdxRepeat}) ~= system.hardware.NbTxChan )
    % Build the prompt of the help dialog box
    ErrMsg = ['The dimension of the REPEAT parameter should be ' ...
        'equal to 1 or to the number of TX channels (' ...
        num2str(system.hardware.NbTxChan) ').'];
    error(ErrMsg);
end

% Check dimension of REPEAT256
IdxRepeat256 = find(strcmp('repeat256', Labels), 1, 'first');
if ( (length(Fields{IdxRepeat256}) ~= system.hardware.NbTxChan) ...
        && (length(Fields{IdxRepeat256}) == 1) )
    Fields{IdxRepeat256} = ...
        repmat(Fields{IdxRepeat256}, [1 system.hardware.NbTxChan]);
elseif ( length(Fields{IdxRepeat256}) ~= system.hardware.NbTxChan )
    % Build the prompt of the help dialog box
    ErrMsg = ['The dimension of the REPEAT256 parameter should be ' ...
        'equal to 1 or to the number of TX channels (' ...
        num2str(system.hardware.NbTxChan) ').'];
    error(ErrMsg);
end

% ============================================================================ %
% ============================================================================ %

%% Dedicated Remote structure fields

% Unused parameters
Fields{end+1} = 0; % data
Fields{end+1} = 0; % extendBL
Fields{end+1} = 0; % legacy

% ============================================================================ %

% Update apodization window with DUTYCYCLE
DutyCycle = obj.getParam('DutyCycle');
TxElemts  = obj.getParam('TxElemts');
if length(DutyCycle) == 1
    DutyCycle = DutyCycle .* ones(size(TxElemts));
elseif length(DutyCycle) ~= length(TxElemts)
    % Build the prompt of the help dialog box
    ErrMsg = [ 'The DUTYCYCLE is defined for ' num2str(length(DutyCycle)) ...
        'while there are ' num2str(length(TxElemts)) ' firing elements.' ];
    error(ErrMsg);
end

switch obj.getParam('ApodFct')
    case 'bartlett'
        ApodFct = 1;
    case 'blackman'
        ApodFct = 2;
    case 'connes'
        ApodFct = 3;
    case 'cosine'
        ApodFct = 4;
    case 'gaussian'
        ApodFct = 5;
    case 'hamming'
        ApodFct = 6;
    case 'hanning'
        ApodFct = 7;
    case 'welch'
        ApodFct = 8;
    otherwise
        ApodFct = 0;
end

% Build the waveform for all channels
Wf = single(obj.setWaveform());
Wf = obj.setApodization(Wf, ApodFct, DutyCycle, TxElemts);


% ============================================================================ %

% Add waveform fields to the REMOTE structure
Fields{end+1} = size(Wf,2);                                      % maxWfPoints
Fields{end+1} = ones(1, system.hardware.NbTxChan) * Fields{end}; % nbWfPoints
Fields{end+1} = reshape(permute(Wf, [2 1]), 1, []);              % wf

% ============================================================================ %
% ============================================================================ %

%% Check output arguments

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
        % Additional labels
        Labels{end+1} = 'data';
        Labels{end+1} = 'extendBL';
        Labels{end+1} = 'legacy';
        Labels{end+1} = 'maxWfPoints';
        Labels{end+1} = 'nbWfPoints';
        Labels{end+1} = 'wf';
        
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
