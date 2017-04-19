% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef TOE < uint64
    enumeration
        UNKNOWN ( 0 )
        GENERATOR_START ( 1 )
        GENERATOR_STOP ( 2 )
        GENERATOR_NEWPERIOD ( 4 )
    end
end
