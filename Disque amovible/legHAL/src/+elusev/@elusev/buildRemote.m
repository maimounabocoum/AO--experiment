% ELUSEV.ELUSEV.BUILDREMOTE (PUBLIC)
%   Build the associated remote structure.
%
%   STRUCT = OBJ.BUILDREMOTE() returns the remote structure STRUCT containing
%   all mandatory remote fields for the ELUSEV.ELUSEV instance.
%
%   [OBJ STRUCT] = OBJ.BUILDREMOTE() returns the updated ELUSEV.ELUSEV instance
%   OBJ and the remote structure STRUCT.
%
%   Note - This function is defined as a method of the remoteclass
%   ELUSEV.ELUSEV. It cannot be used without all methods of the remoteclass
%   ELUSEV.ELUSEV and all methods of its superclass COMMON.REMOTEOBJ developed
%   by SuperSonic Imagine and without a system with a REMOTE server running.
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

%% Check syntax

if ( (nargout ~= 1) && (nargout ~= 2) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Application of triggers

% Retrieve trigger parameters
TrigIn       = obj.getParam('TrigIn');
TrigOut      = obj.getParam('TrigOut');
TrigOutDelay = obj.getParam('TrigOutDelay');
TrigAll      = obj.getParam('TrigAll');

% ============================================================================ %

% Control the trigger out
if ( TrigOut == 0 )
    TrigOutDelay = 0;
    obj = obj.setParam('TrigOutDelay', 0);
end

% ============================================================================ %
% ============================================================================ %

%% Build the associated remote structure
ParsName = obj.Pars(:,1);

% Export TX
ParName      = 'tx';
Idx          = strcmp( ParsName, ParName ) ;

Tmp = obj.Pars(Idx, 3);
if ~isempty(Tmp{1})
    
    % Initialization
    NbTmp     = length(Tmp{1});
    FieldsTmp = cell(NbTmp, Tmp{1}{1}.NbRemotePars);
    LabelsTmp = cell(1, Tmp{1}{1}.NbRemotePars);

    % Extract fields
    [FieldsTmp(1,:) LabelsTmp(1,:)] = Tmp{1}{1}.buildRemote(varargin{1:end});
    for k = 2 : NbTmp
        FieldsTmp(k,:) = Tmp{1}{k}.buildRemote(varargin{1:end});
    end

    % Build the remote mandatory field
    Struct.tx = cell2struct(FieldsTmp, LabelsTmp, 2);
    
end

% ============================================================================ %

% Export TW
ParName = 'tw';
Idx = strcmp( ParsName, ParName ) ;

Tmp = obj.Pars(Idx, 3);
if ~isempty(Tmp{1})
    
    % Initialization
    NbTmp     = length(Tmp{1});
    FieldsTmp = cell(NbTmp, Tmp{1}{1}.NbRemotePars);
    LabelsTmp = cell(1, Tmp{1}{1}.NbRemotePars);
    
    % Extract fields
    [FieldsTmp(1,:) LabelsTmp(1,:)] = Tmp{1}{1}.buildRemote(varargin{1:end});
    for k = 2 : NbTmp
        FieldsTmp(k,:) = Tmp{1}{k}.buildRemote(varargin{1:end});
    end
    
    % Build the remote mandatory field
    Struct.tw = cell2struct(FieldsTmp, LabelsTmp, 2);
    
end

% ============================================================================ %

% Export RX
ParName = 'rx';
Idx = strcmp( ParsName, ParName ) ;

Tmp = obj.Pars( Idx, 3 );
if ~isempty(Tmp{1})
    
    % Initialization
    NbTmp     = length(Tmp{1});
    FieldsTmp = cell(NbTmp, Tmp{1}{1}.NbRemotePars);
    LabelsTmp = cell(1, Tmp{1}{1}.NbRemotePars);
    
    % Extract fields
    [FieldsTmp(1,:) LabelsTmp(1,:)] = Tmp{1}{1}.buildRemote(varargin{1:end});
    for k = 2 : NbTmp
        FieldsTmp(k,:) = Tmp{1}{k}.buildRemote(varargin{1:end});
    end
    
    % Build the remote mandatory field
    Struct.rx = cell2struct(FieldsTmp, LabelsTmp, 2);
    
end

% ============================================================================ %

% Export FC
ParName = 'fc';
Idx = strcmp( ParsName, ParName ) ;

Tmp = obj.Pars(Idx, 3);
if ~isempty(Tmp{1})
    
    % Initialization
    NbTmp     = length(Tmp{1});
    FieldsTmp = cell(NbTmp, Tmp{1}{1}.NbRemotePars);
    LabelsTmp = cell(1, Tmp{1}{1}.NbRemotePars);
    
    % Extract fields
    [FieldsTmp(1,:) LabelsTmp(1,:)] = Tmp{1}{1}.buildRemote(varargin{1:end});
    for k = 2 : NbTmp
        FieldsTmp(k,:) = Tmp{1}{k}.buildRemote(varargin{1:end});
    end
    
    % Build the remote mandatory field
    Struct.fc = cell2struct(FieldsTmp, LabelsTmp, 2);
    
end

% ============================================================================ %

% Export EVENT
ParName = 'event';
Idx = strcmp( ParsName, ParName ) ;

Tmp = obj.Pars(Idx, 3);
if ~isempty(Tmp{1})
    
    % Initialization
    NbTmp     = length(Tmp{1});
    FieldsTmp = cell(NbTmp, Tmp{1}{1}.NbRemotePars);
    LabelsTmp = cell(1, Tmp{1}{1}.NbRemotePars);
    
    % Extract fields
    Tmp{1}{1} = Tmp{1}{1}.setParam( ... % triggers on first event
        'waitExtTrig', TrigIn, 'genExtTrig', TrigOut, ...
        'genExtTrigDelay', TrigOutDelay);
    [FieldsTmp(1,:) LabelsTmp(1,:)] = Tmp{1}{1}.buildRemote(varargin{1:end});
    for k = 2 : NbTmp
        if ( TrigAll == 1 ) % triggers on all events
            Tmp{1}{k} = Tmp{1}{k}.setParam('waitExtTrig', TrigIn, ...
                'genExtTrig', TrigOut, 'genExtTrigDelay', TrigOutDelay);
        end
        FieldsTmp(k,:) = Tmp{1}{k}.buildRemote(varargin{1:end});
    end
    obj.Pars{Idx, 3} = Tmp{1};
    
    % Build the remote mandatory field
    Struct.event = cell2struct(FieldsTmp, LabelsTmp, 2);
    
end

% ============================================================================ %
% ============================================================================ %

%% Check output arguments

if ( isempty(fieldnames(Struct)) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
else
    
    % One output argument
    varargout{1} = Struct;
    
    % Two output arguments
    if ( nargout == 2 )
        varargout{2} = varargout{1};
        varargout{1} = obj;
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