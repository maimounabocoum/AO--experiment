% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef GM
    properties (Constant)
        UNKNOWN = 0
        CONTINUOUS = 1
        BURST_COUNT = 2
        GATED_PERIODS = 4
        GATED = 8
        GATED_PERIOD_START = 16
        GATED_PERIOD_FINISH = 32
        GATED_RUN = 64
        GATED_RUN_OUTPUT = 128
        BURST_SAMPLE_COUNT = 256
        BURST_SAMPLE_COUNT_OUTPUT = 512
        BURST_SEGMENT_COUNT = 1024
        BURST_SEGMENT_COUNT_OUTPUT = 2048
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.GM
            switch value
                case GM.UNKNOWN
                    result = 'UNKNOWN';
                case GM.CONTINUOUS
                    result = 'CONTINUOUS';
                case GM.BURST_COUNT
                    result = 'BURST_COUNT';
                case GM.GATED_PERIODS
                    result = 'GATED_PERIODS';
                case GM.GATED
                    result = 'GATED';
                case GM.GATED_PERIOD_START
                    result = 'GATED_PERIOD_START';
                case GM.GATED_PERIOD_FINISH
                    result = 'GATED_PERIOD_FINISH';
                case GM.GATED_RUN
                    result = 'GATED_RUN';
                case GM.GATED_RUN_OUTPUT
                    result = 'GATED_RUN_OUTPUT';
                case GM.BURST_SAMPLE_COUNT
                    result = 'BURST_SAMPLE_COUNT';
                case GM.BURST_SAMPLE_COUNT_OUTPUT
                    result = 'BURST_SAMPLE_COUNT_OUTPUT';
                case GM.BURST_SEGMENT_COUNT
                    result = 'BURST_SEGMENT_COUNT';
                case GM.BURST_SEGMENT_COUNT_OUTPUT
                    result = 'BURST_SEGMENT_COUNT_OUTPUT';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
