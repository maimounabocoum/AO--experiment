% USSE.USSE.SELECTHARDWARE (PUBLIC)
%   Selects the system hardware.
%
%   OBJ = OBJ.SELECTHARDWARE() selects the system hardware.
%
%   Note - This function is defined as a method of the remoteclass USSE.USSE. It
%   cannot be used without all methods of the remoteclass USSE.USSE and all
%   methods of its superclass COMMON.REMOTEOBJ developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/17

function obj = selectHardware(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

if ( nargout ~= 1 )

    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' selectHardware function needs 1 ' ...
        'output argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);

elseif ( (nargin ~= 1) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' selectHardware function does not ' ...
        'need any input argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% New system selection

% Build the list of available systems
Path    = which('system.hardware');
Idx     = strfind(Path, '@hardware') - 1;
ListDir = dir([Path(1:Idx) '+config']);
Systems = {};
NewPath = {};
for k = 1 : length(ListDir)
    if ( strfind(ListDir(k).name, 'hw_') )
        Systems{end+1} = ListDir(k).name(4:end-2);
        NewPath{end+1} = [Path(1:Idx) '+config/' ListDir(k).name];
    end
end

% ============================================================================ %

% Control of the hardware list and selection
if ( length(Systems) > 1 )
    
    System = selectHW(Systems);
    
elseif ( isempty(Systems) )
    
    % Build the prompt of the help dialog box
    ErrMsg = 'There are no hardwares in the config directory.';
    error(ErrMsg);
    
else
    
    System = Systems{1};
    
end

% ============================================================================ %
% ============================================================================ %

%% Update the selected hardware

% Change of hardware
if ( ~strcmpi(System, system.hardware.Tag) )
    
    % Build the Hardware path
    OldPath = Path;
    
    % Build the new hardware path
    Idx      = strfind(NewPath, System);
    FilePath = [];
    for k = 1 : length(Idx)
        if ( ~isempty(Idx{k}) )
            if ( isempty(FilePath) )
                FilePath = NewPath{k};
            else
                
                % Build the prompt of the help dialog box
                ErrMsg = ['There are several identical hardwares in ' ...
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

    % Message after change
    if ( Status )
        
        % Build the prompt of the help dialog box
        ErrMsg = ['You need to clear all variables to apply the hardware ' ...
            'changes, i.e. clear all command.'];
        error(ErrMsg);
        
    else
        
        % Build the prompt of the help dialog box
        ErrMsg = 'The new hardware could not be loaded.';
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
            common.legHAL.GetException(Exception, class(obj), 'selectHardware');
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

%% Nested function to select the hardware

function System = selectHW(ListSystems)

% ============================================================================ %

% Default value
System = ListSystems{1};

% Build the selection dialog box
[Select Success] = listdlg( ...
    'ListString', ListSystems, ...
    'SelectionMode', 'single', ...
    'ListSize', [200 100], ...
    'InitialValue', 1, ...
    'Name', 'HARDWARE selection', ...
    'PromptString', 'Select the hardware');

% Retrieve the selection
if ( Success )
    System = ListSystems{Select};
end

% ============================================================================ %

end