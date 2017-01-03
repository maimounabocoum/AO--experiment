
function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'system.lte_magna';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize COMMON.REMOTEOBJ superclass
obj = initialize@common.object(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% 
Par = common.parameter( ...
    'Voltage', ...
    'double', ...
    'set the voltage of the power supply', ...
    { [0 16] }, ...
    { 'Power Supply Voltage' }, ...
    obj.Debug, current_class );

Par = Par.setValue(0); % Linux 1st serial port

% Add parameter to the object parameters
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