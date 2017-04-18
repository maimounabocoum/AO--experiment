% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef TK < uint64
    enumeration
        UNKNOWN ( 0 ) % Unknown/invalid trigger kind
        RISINGEDGE ( 1 ) % Rising edge
        FALLINGEDGE ( 2 ) % Falling edge
        INWINDOW ( 4 ) % Inside window
        OUTWINDOW ( 8 ) % Outside window
        ANYEDGE ( 16 ) % Any edge
        ENTERWINDOW ( 32 ) % Enter window
        EXITWINDOW ( 64 ) % Exit window
        PULSEWIDTHPOSITIVE ( 128 ) % Positive pulse width
        PULSEWIDTHNEGATIVE ( 256 ) % Negative pulse width
    end
end
