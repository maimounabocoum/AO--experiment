% USSE.USSE.SELECTPROBE (PUBLIC)
%   Selects the probe.
%
%   OBJ = OBJ.SELECTPROBE() selects the probe.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/17

function obj = selectProbe(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

if ( nargout ~= 1 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' selectProbe function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);

elseif ( (nargin ~= 1) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' selectProbe function does not ' ...
        'need any input argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% New probe selection

% Build the list of available probes
Path    = which('system.probe');
Idx     = strfind(Path, '@probe') - 1;
ListDir = dir([Path(1:Idx) '+config' ]);
Probes  = {};
NewPath = {};
for k = 1 : length(ListDir)
    if ( strfind(ListDir(k).name, 'pr_') )
        Probes{end+1} = ListDir(k).name(4:end-2);
        NewPath{end+1} = [Path(1:Idx) '+config/' ListDir(k).name];
    end
end

old_probe = fileread(Path);

% ============================================================================ %

% Control of the hardware list and selection
if ( length(Probes) > 1 )
    
    Probe = selectPR(Probes);
    
elseif ( isempty(Probes) )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'There are no probes in the config directory.';
    error(ErrMsg);
    
else
    
    Probe = Probes{1};
    
end

% ============================================================================ %
% ============================================================================ %

%% Update the selected hardware

% TODO: change this ugly probe management
% Change of hardware
    
    % Build the Probe path
    OldPath = Path;
    
    % Build the new probe path
    Idx      = strfind(NewPath, [ 'pr_' Probe ] );
    FilePath = [];
    for k = 1 : length(Idx)
        if ( ~isempty(Idx{k}) )
            if ( isempty(FilePath) )
                FilePath = NewPath{k};
                break
            else
                
                % Build the prompt of the help dialog box
                ErrMsg = ['There are several identical probes in ' ...
                    'the config directory.'];
                error(ErrMsg);
                
            end
        end
    end
    
% ============================================================================ %

    % Copy the new hardware file
    Slash = strfind(FilePath, '\');
    if ( ~isempty(Slash) )
        FilePath(Slash) = '/';
    end
    Slash = strfind(OldPath, '\');
    if ( ~isempty(Slash) )
        OldPath(Slash) = '/';
    end
    delete(OldPath);
    [Status ~] = copyfile(FilePath, [OldPath(1:end-1) FilePath(end)]);
    
% ============================================================================ %

if isempty( dir( Path )  )
    new_probe = '';
else
    new_probe = fileread(Path);
end

if ~strcmp( new_probe, old_probe )
    % Message after change
    if ( Status )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['You need to clear all variables to apply the probe ' ...
            'changes, i.e. clear all command.'];
        error(ErrMsg);
        
    else
        
        % Build the prompt of the help dialog box
        ErrMsg = 'The new probe could not be loaded.';
        error(ErrMsg);
        
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
            common.legHAL.GetException(Exception, class(obj), 'selectProbe');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end

% ============================================================================ %
% ============================================================================ %

%% Nested functionto select the probe

function Probe = selectPR(ListProbes)

% ============================================================================ %

% Default value
Probe = ListProbes{1};

% Build the selection dialog box
[Select Success] = listdlg( ...
    'ListString', ListProbes, ...
    'SelectionMode', 'single', ...
    'ListSize', [200 100], ...
    'InitialValue', 1, ...
    'Name', 'HARDWARE selection', ...
    'PromptString', 'Select the hardware');

% Retrieve the selection
if ( Success )
    Probe = ListProbes{Select};
end

% ============================================================================ %

end