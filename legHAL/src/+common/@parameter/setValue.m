% COMMON.PARAMETER.SETVALUE (PUBLIC)
%   Set the value of the COMMON.PARAMETER object.
%
%   OBJ = OBJ.SETVALUE(VALUE) sets the value of the COMMON.PARAMETER
%   instance to VALUE.
%
%   Note - This function is defined as a method of the class COMMON.PARAMETER.
%   It cannot be used without all methods of the class COMMON.PARAMETER
%   developed by SuperSonic Imagine and without a system with a REMOTE server
%   running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/21

function obj = setValue(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( nargin == 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setValue function requires 1 ' ...
        'argument:\n', ...
        '    1. the new value of the parameter.\n\n', ...
        'The authorized values are:\n'];
    
    % Loop on all authorized values
    for k = 1 : length(obj.AuthValues)
        ErrMsg = [ErrMsg '    - '];
        
        if isnumeric(obj.AuthValues{k}) % numeric authorized values
            
            if ( obj.AuthRange{k} ) % CHAR value for a range of values
                
                ErrMsg = [ErrMsg '[' num2str(obj.AuthValues{k}(1)) ...
                    '; ' num2str(obj.AuthValues{k}(2)) '] - '];
                
            else                   % CHAR value for single value
                
                ErrMsg = [ErrMsg num2str(obj.AuthValues{k}) ' - '];
                
            end
            
        else                        % CHAR authorized values
            
            ErrMsg = [ErrMsg obj.AuthValues{k} ' - '];
            
        end
        
        ErrMsg = [ErrMsg obj.AuthDesc{k} '.\n'];
    end
    
    % Show the help dialog box
    error(ErrMsg);
    

elseif ( nargin ~= 2 ) % wrong number of arguments
    
    % Return error
    ErrMsg = ['The  ' upper(class(obj)) '  setValue function needs only 1 ' ...
        'argument:\n' ...
        '    1. the new value of the parameter.'];
    error(ErrMsg);
    
elseif ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' getValue function requires an ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Set the new value to the parameter

NewValue = varargin{1};

% ============================================================================ %

% Control the type of the new value and set the new value
tmp = str2func(obj.Type);

% PARAMETER is numeric
if ( isnumeric(tmp([])) )
    
    % New value is not numeric
    if ( ~isnumeric(NewValue) )
        
        % Return error
        ErrMsg = ['The new value of ' upper(obj.Name) ' should be numeric ' ...
            'as expected for this parameter (' upper(obj.Type) ' object).'];
        error(ErrMsg);
        
    end
    
    % Control if NEWVALUE is in the same type of authorized values
    Idx = zeros(size(NewValue));
    for k = 1 : length(obj.AuthRange)
        if ( obj.AuthRange{k} == 1 )
            Idx = Idx + k .* ((NewValue >= obj.AuthValues{k}(1)) ...
                & (NewValue <= obj.AuthValues{k}(2)));
        else
            Idx = Idx + k .* (NewValue == obj.AuthValues{k});
        end
    end
    Idx = unique(Idx(:));
    if ( length(Idx) ~= 1 ) % distinct range of authorized values
        
        % Return error
        ErrMsg = [ 'The new values of ' upper(obj.Name) ' is ' num2str(NewValue) ', it cannot belong to ' ...
            'distinct ranges of authorized values:' ];
        
        for k = 1 : length(obj.AuthValues)
            if ( obj.AuthRange{k} )
                ErrMsg = [ErrMsg '   - [' num2str(obj.AuthValues{k}) '] : ' ...
                    obj.AuthDesc{k} '.\n'];
            else
                ErrMsg = [ErrMsg '   - ' num2str(obj.AuthValues{k}) ' : ' ...
                    obj.AuthDesc{k} '.\n'];
            end
        end
        
        error(ErrMsg);
        
    elseif ( Idx ~= 0 )     % sets the new value
        
        obj.Value = cast(NewValue, obj.Type);
        
        % Display debug mode
        if ( obj.Debug )
            if ( length(NewValue) == 1 )
                disp([upper(obj.Name) ' is set to ' num2str(obj.Value) '.']);
            elseif ( isvector(NewValue) )
                plot(obj.Value);
                title(upper(obj.Name));
                drawnow;
                pause(0.5);
            elseif ( length(size(squeeze(obj.Value))) == 2 )
                imagesc(squeeze(obj.Value));
                title(upper(obj.Name));
                drawnow;
                pause(0.5);
            else
                disp([upper(obj.Name) ' is set to a ' ...
                    num2str(length(size(squeeze(obj.Value)))) '-dimension ' ...
                    'value..']);
            end
        end
        
    else                    % new value is not authorized
        
        % Return error
        ErrMsg = ['The new value of ' upper(obj.Name) ' (' num2str(NewValue) ') does not belong to ' ...
            'any authorized values:\n'];
        
        for k = 1 : length(obj.AuthValues)
            if ( obj.AuthRange{k} )
                ErrMsg = [ErrMsg '   - [' num2str(obj.AuthValues{k}) '] : ' ...
                    obj.AuthDesc{k} '.\n'];
            else
                ErrMsg = [ErrMsg '   - ' num2str(obj.AuthValues{k}) ' : ' ...
                    obj.AuthDesc{k} '.\n'];
            end
        end
        
        error(ErrMsg);
        
    end
    
% ============================================================================ %

% PARAMETER is a CHAR object
else
    
    % New value is not a CHAR value
    if ( ~ischar(NewValue) )
        
        % Return error
        ErrMsg = ['The new value of ' upper(obj.Name) ' should be a CHAR ' ...
            'value.'];
        error(ErrMsg);
        
    end
    
    % Set the new value
    obj.Value = NewValue;
    
        % Display debug mode
        if ( obj.Debug )
            disp([upper(obj.Name) ' is set to ' obj.Value '.']);
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
            common.legHAL.GetException(Exception, class(obj), 'setValue');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end