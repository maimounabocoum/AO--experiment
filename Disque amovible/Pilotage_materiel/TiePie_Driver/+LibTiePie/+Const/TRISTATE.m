% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef TRISTATE
    properties (Constant)
        UNDEFINED = 0 % Undefined
        FALSE = 1 % False
        TRUE = 2 % True
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.TRISTATE
            switch value
                case TRISTATE.UNDEFINED
                    result = 'UNDEFINED';
                case TRISTATE.FALSE
                    result = 'FALSE';
                case TRISTATE.TRUE
                    result = 'TRUE';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
