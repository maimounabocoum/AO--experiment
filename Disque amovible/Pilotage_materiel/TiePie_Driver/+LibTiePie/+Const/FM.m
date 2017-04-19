% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef FM
    properties (Constant)
        UNKNOWN = 0
        SIGNALFREQUENCY = 1
        SAMPLEFREQUENCY = 2
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.FM
            switch value
                case FM.UNKNOWN
                    result = 'UNKNOWN';
                case FM.SIGNALFREQUENCY
                    result = 'SIGNALFREQUENCY';
                case FM.SAMPLEFREQUENCY
                    result = 'SAMPLEFREQUENCY';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
