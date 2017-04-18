% MatlabLibTiePie - Matlab bindings for LibTiePie library
%
% Copyright (c) 2012-2015 TiePie engineering
%
% Website: http://www.tiepie.com/LibTiePie

classdef GS
    properties (Constant)
        STOPPED = 1 % The signal generation is stopped.
        RUNNING = 2 % The signal generation is running.
        BURSTACTIVE = 4 % The generator is operating in burst mode.
        WAITING = 8 % The generator is waiting for a burst to be started.
    end
    methods (Static)
        function result = toString(value)
            import LibTiePie.Const.GS
            switch value
                case GS.STOPPED
                    result = 'STOPPED';
                case GS.RUNNING
                    result = 'RUNNING';
                case GS.BURSTACTIVE
                    result = 'BURSTACTIVE';
                case GS.WAITING
                    result = 'WAITING';
                otherwise
                    error('Unknown value');
            end
        end
    end
end
