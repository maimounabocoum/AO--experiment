% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef CO
    properties (Constant)
        DISABLED = 1 % No clock output
        SAMPLE = 2 % Sample clock
        FIXED = 4 % Fixed clock
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.CO
            switch value
                case CO.DISABLED
                    result = 'DISABLED';
                case CO.SAMPLE
                    result = 'SAMPLE';
                case CO.FIXED
                    result = 'FIXED';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
