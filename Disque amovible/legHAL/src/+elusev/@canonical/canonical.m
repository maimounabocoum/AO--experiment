
classdef canonical < elusev.elusev
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    obj = initalize(obj, varargin) % builds the ELUSEV.PULSE_CANONIC object
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    obj       = setValue(obj, varargin)    % set the value of the ELUSEV.PULSE_CANONIC object.
    varargout = buildRemote(obj, varargin) % build the remote structure.
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = canonical(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~strcmpi(varargin{1}, 'elusev') )
                varargin = {'elusev', 'canonical elusev', varargin{1:end}};
            end
        else
            varargin = {'elusev', 'canonical elusev', varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@elusev.elusev(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end