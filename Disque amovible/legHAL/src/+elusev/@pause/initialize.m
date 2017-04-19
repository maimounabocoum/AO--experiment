
function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'elusev.pause';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize superclass
obj = initialize@elusev.elusev(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

Par = common.parameter( ...
    'Pause', ...
    'double', ...
    'sets the pause duration with steps of 0.2 us', ...
    {[system.hardware.MinNoop*1e-6 3600]}, ...
    {'pause duration [s]'}, ...
    obj.Debug, current_class );
Par = Par.setValue( system.hardware.MinNoop*1e-6 );
obj = obj.addParam(Par);

Par = common.parameter( ...
    'SoftIrq', ...
    'int32', ...
    'sets a  SoftIrq to reset the software timer', ...
    {[0 1]}, ...
    {'0 or 1'}, ...
    obj.Debug, current_class );
Par = Par.setValue( 0 );
obj = obj.addParam(Par);

% ============================================================================ %

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'initialize');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end
