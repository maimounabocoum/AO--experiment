% TODO: diff version du LTE ?
classdef lte < common.object

properties ( SetAccess = 'private', GetAccess = 'public' )
    server
    
    shi
    magna
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = lte( server, varargin )

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
                'LTE', ...
                'LTE device', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.object(varargin{1:end});
        
        obj.server  = server;
        obj.shi     = system.lte_shi( obj.server, 'LTE SHI', 'LTE SHI control' );
        obj.magna   = system.lte_magna( obj.server, 'LTE Magna', 'LTE Magna power supply' );

    end
end

end
