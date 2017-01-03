
classdef rs232 < common.object

% ============================================================================ %
% ============================================================================ %

properties ( SetAccess = 'private', GetAccess = 'public' )
    % USSE
    srv % put as parameter ? but which class (usse.usse, usse.lte, ... ) ?
end

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
   varargout = initalize(obj, varargin) % build class RS232
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )

%     ret = get_interface ( obj ) % to add ?
    ret = connect ( obj )
    ret = disconnect ( obj )
    ret = read ( obj )
    ret = write ( obj, message )
    ret = write_and_read ( obj, message )
    check_status( obj, msg, status )    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = rs232( srv, varargin )

        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
%                 varargin = { ...
%                     'TPC', ...
%                     'default power control', ...
%                     varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'TPC', ...
                'default power control', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.object(varargin{1:end});
        
        obj.srv = srv;
    end
end

% ============================================================================ %
% ============================================================================ %

end