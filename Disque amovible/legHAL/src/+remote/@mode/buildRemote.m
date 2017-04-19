% REMOTE.MODE.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   FIELDS = OBJ.BUILDREMOTE() returns the mandatory field content (FIELDS) for
%   the REMOTE.MODE instance.
%
%   [FIELDS LABELS] = OBJ.BUILDREMOTE() returns the field labels (LABELS) and
%   the mandatory field content (FIELDS) for the REMOTE.MODE instance.
%
%   Note - This function is defined as a method of the remoteclass REMOTE.MODE.
%   It cannot be used without all methods of the remoteclass REMOTE.MODE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/02

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
% ============================================================================ %

%% Build the HOSTBUFFERSIZE, CHANNELSIZE and HOSTBUFFERIDX fields

% Retrieve ModeRx parameter
IdxModeRx = find(strcmp('ModeRx', Labels), 1, 'first');
SamplesCH = double(sum(Fields{IdxModeRx}(1, :)));

% ============================================================================ %

% Dedicated Remote structure fields

% Initialize variables
if ( SamplesCH == 0 )
    BlockSize = 0;
elseif ( SamplesCH >  4096 )
    BlockSize = 16384;
elseif ( SamplesCH > 2048 )
    BlockSize = 8192;
else
    BlockSize = 4096;
end

% Determine minimum # of blocks
MiniNBlocks = ceil(2 * SamplesCH / BlockSize);

% Determine minimum prime number of blocks
if MiniNBlocks >= 3
    MiniTmp = MiniNBlocks + 20;
    Primes  = primes(MiniTmp);
    while Primes(end) < MiniNBlocks
        MiniTmp = MiniTmp + 10;
        Primes  = primes(MiniTmp);
    end
    MiniNBlocks = Primes(min(sort(find(Primes >= MiniNBlocks))));
end

% Add fields to the REMOTE structure
Fields{end+1} = int32( max(1, MiniNBlocks) * BlockSize ...       % channelSize
    .* ones(1, obj.getParam('NbHostBuffer')) );
Fields{end+1} = int32(system.hardware.NbRxChan * Fields{end});   % hostBufferSize
Fields{end+1} = int32( (1:obj.getParam('NbHostBuffer')) - 1 ); % hostBufferIdx

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
        Labels{end+1} = 'channelSize';
        Labels{end+1} = 'hostBufferSize';
        Labels{end+1} = 'hostBufferIdx';
        
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