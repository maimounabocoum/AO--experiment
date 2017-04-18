% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef TC
    properties (Constant)
        UNKNOWN = 0
        NONE = 1
        SMALLER = 2
        LARGER = 4
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.TC
            switch value
                case TC.UNKNOWN
                    result = 'UNKNOWN';
                case TC.NONE
                    result = 'NONE';
                case TC.SMALLER
                    result = 'SMALLER';
                case TC.LARGER
                    result = 'LARGER';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
