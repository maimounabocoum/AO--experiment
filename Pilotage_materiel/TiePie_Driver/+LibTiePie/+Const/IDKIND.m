% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef IDKIND
    properties (Constant)
        PRODUCTID = 1 % dwId parameter is a \ref PID_ "product id".
        INDEX = 2 % dwId parameter is an index.
        SERIALNUMBER = 4 % dwId parameter is a serial number.
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.IDKIND
            switch value
                case IDKIND.PRODUCTID
                    result = 'PRODUCTID';
                case IDKIND.INDEX
                    result = 'INDEX';
                case IDKIND.SERIALNUMBER
                    result = 'SERIALNUMBER';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
