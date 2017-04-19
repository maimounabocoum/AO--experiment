% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef ST
    properties (Constant)
        UNKNOWN = 0
        SINE = 1
        TRIANGLE = 2
        SQUARE = 4
        DC = 8
        NOISE = 16
        ARBITRARY = 32
        PULSE = 64
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.ST
            switch value
                case ST.UNKNOWN
                    result = 'UNKNOWN';
                case ST.SINE
                    result = 'SINE';
                case ST.TRIANGLE
                    result = 'TRIANGLE';
                case ST.SQUARE
                    result = 'SQUARE';
                case ST.DC
                    result = 'DC';
                case ST.NOISE
                    result = 'NOISE';
                case ST.ARBITRARY
                    result = 'ARBITRARY';
                case ST.PULSE
                    result = 'PULSE';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
