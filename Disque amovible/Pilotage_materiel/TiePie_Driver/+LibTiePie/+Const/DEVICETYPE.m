% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef DEVICETYPE
    properties (Constant)
        OSCILLOSCOPE = 1 % Oscilloscope
        GENERATOR = 2 % Generator
        I2CHOST = 4 % I2C Host
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.DEVICETYPE
            switch value
                case DEVICETYPE.OSCILLOSCOPE
                    result = 'OSCILLOSCOPE';
                case DEVICETYPE.GENERATOR
                    result = 'GENERATOR';
                case DEVICETYPE.I2CHOST
                    result = 'I2CHOST';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
