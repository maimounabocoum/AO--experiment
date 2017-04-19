% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef TOE
    properties (Constant)
        UNKNOWN = 0
        GENERATOR_START = 1
        GENERATOR_STOP = 2
        GENERATOR_NEWPERIOD = 4
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.TOE
            switch value
                case TOE.UNKNOWN
                    result = 'UNKNOWN';
                case TOE.GENERATOR_START
                    result = 'GENERATOR_START';
                case TOE.GENERATOR_STOP
                    result = 'GENERATOR_STOP';
                case TOE.GENERATOR_NEWPERIOD
                    result = 'GENERATOR_NEWPERIOD';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
