% COMMON.OBJECT.SETPARAM (PUBLIC)
%   Set the value of PARSNAME to PARSVALUE.
%
%   OBJ = OBJ.SETPARAM(PARSNAME, PARSVALUE...) set the value PARSVALUE to the
%   parameter PARSNAME.
%
%   Note - This function is defined as a method of the class COMMON.OBJECT. It
%   cannot be used without all methods of the class COMMON.OBJECT developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/22

function obj = setParam(obj, varargin)
   
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
    ErrMsg = ['The ' upper(class(obj)) ' setParam function requires an ' ...
        'even number of arguments:\n' ...
        '    1. 1st parameter name,\n' ...
        '    2. new value of the 1st parameter,\n' ...
        '    3. ...'];
    error(ErrMsg);
    
elseif ( rem(nargin, 2) == 0 )
    
    % Return error
    ErrMsg = ['The ' upper(class(obj)) ' setParam function requires an ' ...
        'even number of arguments:\n', ...
        '    1. 1st parameter name,\n', ...
        '    2. new value of the 1st parameter,\n', ...
        '    3. ...'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Set the several parameters

% Initialize
ParName = varargin(1:2:end);

% Determine parameter location
LengthParName  = length(ParName);

if size( obj.Pars, 1 ) == 0  
    Idx = [];
        
else
    
    % Reformat the ParName
    ParsName = obj.Pars(:,1);

    % Locate the parameter
    Idx    = zeros(1, LengthParName);
    for k = 1 : LengthParName
        
        if ~ischar ( ParName{k} )
            ErrMsg = [ 'The parameter names must be valid strings' ];
            error(ErrMsg);
        end
        
        tmp = find( strcmp( ParsName, ParName{k} ) );

        if isempty(tmp)
            % Return error
            ErrMsg = ['The parameter ' ParName{k} ...
                ' does not belong to the current ' upper(class(obj)) ' object.'];
            
            tmp2 = find( strcmpi( ParsName, ParName{k} ) );
            
            if ~isempty( tmp2 )
                ErrMsg = [ ErrMsg ' Try to use ' char(obj.Pars(tmp2,1)) ' instead.' ];
            end
            
            error(ErrMsg);
        else
            Idx(k) = tmp;
        end
    end
    
end

if ( ~isempty(find(Idx == 0, 1, 'first')) )
    
    % Return error
    ErrMsg = ['The parameter ' upper(find(Idx == 0, 1, 'first')) ' does ' ...
        'not belong to the current ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Sets the new value
TmpPar  = obj.Pars(Idx, 3);
VarType = obj.Pars(Idx, 2);
for k = 1 : length(Idx)
    
    TmpVal  = varargin{2*k};
    if ( isa(TmpPar{k}, 'common.parameter') )
        
        TmpPar{k} = TmpPar{k}.setValue(TmpVal);
        
    elseif ( isa(TmpPar{k}, 'common.object') )
        
        if ( isa(TmpVal, VarType{k}) )
            if ( TmpVal.isempty() )
                
                % Return error
                ErrMsg = ['The new value for parameter ' ...
                    upper(ParName{k}) ' is empty and could not be added.'];
                error(ErrMsg);
                
            else
                
                TmpPar{k} = TmpVal;
                
            end
        end
        
    elseif ( iscell(TmpPar{k}) )
        
        if ( isa(TmpVal, VarType{k}) )
            
            if ( TmpVal.isempty() )
                
                % Return error
                ErrMsg = ['The new value for parameter ' ...
                    upper(ParName{k}) ' is empty and could not be added.'];
                error(ErrMsg);
                
            else
                
                TmpPar{k}{end+1} = TmpVal;
                
            end
            
        elseif ( iscell(TmpVal) )
            
            ParDim = length(TmpPar{k});
            TmpPar{k} = [TmpPar{k} repmat({[]}, [1, length(TmpVal)])];
            for l = 1 : length(TmpVal)
                
                if ( isa(TmpVal{l}, VarType{k}) )
                    
                    if ( TmpVal{l}.isempty() )
                        
                        % Return error
                        ErrMsg = ['The new value for parameter ' ...
                            upper(ParName{k}) ' is empty and could not ' ...
                            'be added.'];
                        error(ErrMsg);
                        
                    end
                    
                else
                    
                    % Return error
                    ErrMsg = ['The parameter ' upper(ParName{k}) ...
                        ' should be a ' upper(VarType{k}) ' object and ' ...
                        'not a ' upper(class(TmpVal{l})) ' object.'];
                    error(ErrMsg);
                    
                end
            end
            
            % Add the new values
            TmpPar{k}((ParDim + 1) : end) = TmpVal(:);
            
        else
            
            % Return error
            ErrMsg = ['The parameter ' upper(ParName{k}) ' should be a ' ...
                upper(VarType{k}) ' object and not a ' upper(class(TmpVal)) ...
                ' object.'];
            error(ErrMsg);
            
        end
        
    else
        
        % Return error
        ErrMsg = ['The parameter ' upper(ParName{k}) ' should be a ' ...
            'COMMON.PARAMETER, COMMON.OBJECT, CELL or their subclasses.'];
        error(ErrMsg);
        
    end
    
end

% Update the object
obj.Pars(Idx, 3) = TmpPar;

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'setParam');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end