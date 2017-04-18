% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef CS
    properties (Constant)
        EXTERNAL = 1 % External clock
        INTERNAL = 2 % Internal clock
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.CS
            switch value
                case CS.EXTERNAL
                    result = 'EXTERNAL';
                case CS.INTERNAL
                    result = 'INTERNAL';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
