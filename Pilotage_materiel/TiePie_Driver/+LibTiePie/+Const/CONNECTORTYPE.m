% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef CONNECTORTYPE
    properties (Constant)
        UNKNOWN = 0
        BNC = 1
        BANANA = 2
        POWERPLUG = 4
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.CONNECTORTYPE
            switch value
                case CONNECTORTYPE.UNKNOWN
                    result = 'UNKNOWN';
                case CONNECTORTYPE.BNC
                    result = 'BNC';
                case CONNECTORTYPE.BANANA
                    result = 'BANANA';
                case CONNECTORTYPE.POWERPLUG
                    result = 'POWERPLUG';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
