% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef PID
    properties (Constant)
        NONE = 0 % Unknown/invalid ID
        COMBI = 2 % Combined instrument
        HS4 = 15 % Handyscope HS4
        HP3 = 18 % Handyprobe HP3
        HS4D = 20 % Handyscope HS4-DIFF
        HS5 = 22 % Handyscope HS5
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.PID
            switch value
                case PID.NONE
                    result = 'NONE';
                case PID.COMBI
                    result = 'COMBI';
                case PID.HS4
                    result = 'HS4';
                case PID.HP3
                    result = 'HP3';
                case PID.HS4D
                    result = 'HS4D';
                case PID.HS5
                    result = 'HS5';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
