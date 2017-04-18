% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef CK
    properties (Constant)
        UNKNOWN = 0 % Unknown/invalid coupling
        DCV = 1 % Volt DC
        ACV = 2 % Volt AC
        DCA = 4 % Ampere DC
        ACA = 8 % Ampere AC
        OHM = 16 % Ohm
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.CK
            switch value
                case CK.UNKNOWN
                    result = 'UNKNOWN';
                case CK.DCV
                    result = 'DCV';
                case CK.ACV
                    result = 'ACV';
                case CK.DCA
                    result = 'DCA';
                case CK.ACA
                    result = 'ACA';
                case CK.OHM
                    result = 'OHM';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
