% REMOTE.RX.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the REMOTE.RX instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the REMOTE.RX instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.RX. It
%   cannot be used without all methods of the remoteclass REMOTE.RX and all
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

% Estimate the ADFilter and ADRate values
RxFreq              = obj.getParam('RxFreq');
AuthFreq            = system.hardware.ClockFreq ...
    ./ (system.hardware.ADRate * system.hardware.ADFilter);
DiffFreq          = min(AuthFreq(AuthFreq >= (1 - 1e-3) * RxFreq) - RxFreq);
[ADRate ADFilter] = find((AuthFreq - RxFreq) == DiffFreq);
[Fields{end+1} I] = max(ADFilter);                     % ADFilter
Fields{end+1}     = system.hardware.ADRate(ADRate(I)); % ADRate

% Save the RxFreq
Fields{end+1} = system.hardware.ClockFreq / (Fields{end-1} * Fields{end}); % Freq

% Control the receiving elements
RxElemts = sort(obj.getParam('RxElemts'));
if ( length(RxElemts) > system.probe.NbElemts )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' event needs at most ' ...
        num2str(system.probe.NbElemts) ' receiving elements, and ' ...
        'not ' num2str(length(RxElemts)) '.'];
    error(ErrMsg);
    
elseif length(mod(RxElemts, system.hardware.NbRxChan)) ...
        ~= length( unique( mod(RxElemts, system.hardware.NbRxChan) ) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' event needs receiving events ' ...
        'on distinct mux positions.'];
    error(ErrMsg);
    
elseif ( ~obj.getParam('HifuRx') ) % blocks of contiguous rx channels for imaging
    
    % Evaluate the first receiving channel
    Nmin = max(RxElemts(1) ...
        - round((system.hardware.NbRxChan - length(RxElemts)) / 2), 1);
    
    if ( Nmin == 1 ) % >= 1
        RxElemts = (1:system.hardware.NbRxChan);
    elseif ( (Nmin + system.hardware.NbRxChan - 1) > system.probe.NbElemts ) % <= NbElemts
        RxElemts = (1:system.hardware.NbRxChan) ...
            + (system.probe.NbElemts - system.hardware.NbRxChan);
    else
        RxElemts = (1:system.hardware.NbRxChan) - 1 + Nmin;
    end
    
end
Fields{end+1} = RxElemts; % Channels

% Build the Mux positions
Mux = zeros(1, system.hardware.NbRxChan);
Mux(mod(RxElemts - 1, system.hardware.NbRxChan) + 1) = ...
    RxElemts > system.hardware.NbRxChan;
Mux = permute(reshape(Mux, 8, []), [2 1]);
Mux = uint8(permute(bin2dec(num2str(Mux)), [2 1]));
Fields{end+1} = Mux; % lvMuxBlock

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
        % Additional labels
        Labels{end+1} = 'ADFilter';
        Labels{end+1} = 'ADRate';
        Labels{end+1} = 'Freq';
        Labels{end+1} = 'Channels';
        Labels{end+1} = 'lvMuxBlock';
        
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