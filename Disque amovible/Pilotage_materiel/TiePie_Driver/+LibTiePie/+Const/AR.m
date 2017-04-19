% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef AR
    properties (Constant)
        UNKNOWN = 0 % Unknown/invalid mode
        DISABLED = 1 % Resolution does not automatically change.
        NATIVEONLY = 2 % Highest possible native resolution for the current sample frequency is used.
        ALL = 4 % Highest possible native or enhanced resolution for the current sample frequency is used.
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.AR
            switch value
                case AR.UNKNOWN
                    result = 'UNKNOWN';
                case AR.DISABLED
                    result = 'DISABLED';
                case AR.NATIVEONLY
                    result = 'NATIVEONLY';
                case AR.ALL
                    result = 'ALL';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
