% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef MM
    properties (Constant)
        UNKNOWN = 0 % Unknown/invalid mode
        STREAM = 1 % Stream mode
        BLOCK = 2 % Block mode
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.MM
            switch value
                case MM.UNKNOWN
                    result = 'UNKNOWN';
                case MM.STREAM
                    result = 'STREAM';
                case MM.BLOCK
                    result = 'BLOCK';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
