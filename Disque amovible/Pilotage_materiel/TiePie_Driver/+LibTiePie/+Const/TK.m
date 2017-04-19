% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef TK
    properties (Constant)
        UNKNOWN = 0 % Unknown/invalid trigger kind
        RISINGEDGE = 1 % Rising edge
        FALLINGEDGE = 2 % Falling edge
        INWINDOW = 4 % Inside window
        OUTWINDOW = 8 % Outside window
        ANYEDGE = 16 % Any edge
        ENTERWINDOW = 32 % Enter window
        EXITWINDOW = 64 % Exit window
        PULSEWIDTHPOSITIVE = 128 % Positive pulse width
        PULSEWIDTHNEGATIVE = 256 % Negative pulse width
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.TK
            switch value
                case TK.UNKNOWN
                    result = 'UNKNOWN';
                case TK.RISINGEDGE
                    result = 'RISINGEDGE';
                case TK.FALLINGEDGE
                    result = 'FALLINGEDGE';
                case TK.INWINDOW
                    result = 'INWINDOW';
                case TK.OUTWINDOW
                    result = 'OUTWINDOW';
                case TK.ANYEDGE
                    result = 'ANYEDGE';
                case TK.ENTERWINDOW
                    result = 'ENTERWINDOW';
                case TK.EXITWINDOW
                    result = 'EXITWINDOW';
                case TK.PULSEWIDTHPOSITIVE
                    result = 'PULSEWIDTHPOSITIVE';
                case TK.PULSEWIDTHNEGATIVE
                    result = 'PULSEWIDTHNEGATIVE';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
