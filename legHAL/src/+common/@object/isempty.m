% COMMON.OBJECT.ISEMPTY (PUBLIC)
%   Check if COMMON.OBJECT is correctly defined.
%
%   SUCCESS = OBJ.ISEMPTY() returns TRUE if at least one of the instance
%   parameters has no defined value.
%
%   Note - This function is defined as a method of the class COMMON.OBJECT. It
%   cannot be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function Success = isempty(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check the method syntax
if ( nargin ~= 1 && nargin ~= 2 )
    
    % Return error
    ErrMsg = ['The ' upper(class(obj)) ' isempty function requires one or no ' ...
        'argument.'];
    error(ErrMsg);
    
end

debug = false;
if ( nargin == 2 )
    debug = true;
end

% ============================================================================ %
% ============================================================================ %

%% Check all parameters of the instance

% Initialize
Success = false;

% Check within PARS
Idx = strfind(obj.Pars(:,2), '.');
Tmp = obj.Pars(:,3);
for k = 1 : length(Idx)

    if ( isempty(Idx{k}) ) % PARAMETER or REMOTEPAR objects
        
        if ( isempty(Tmp{k}.Value) )
            if debug
                disp( [ 'Value of PARAMETER ' obj.Pars(k,1) ' is empty' ] )
            end
            Success = true;
            return;
        end
        
    else % OBJECT or REMOTEOBJ objects
        
        if ( iscell(Tmp{k}) )
            for m = 1 : length(Tmp{k})
                
                if ( Tmp{k}{m}.isempty() )
                    if debug
                        disp( [ 'Value of PARAMETER ' obj.Pars(k,1) '{' num2str(m) '} is empty' ] )
                    end
                    Success = true;
                    return;
                end
                
            end
        elseif ( Tmp{k}.isempty() )
            if debug
                disp( [ 'Value of PARAMETER ' obj.Pars(k,1) ' is empty' ] )
            end
            Success = true;
            return;
        end
        
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
            common.legHAL.GetException(Exception, class(obj), 'isEmpty');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end