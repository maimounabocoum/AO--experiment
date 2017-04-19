function msgRcv = i2c( obj, varargin )
    % default
    delay = obj.delayI2C;
    
    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '0';
    msg.opcode        = '';
    msg.data          = '0';

    % args
    for n=1:2:length(varargin)-1
        if strcmp( varargin{n}, 'pause' )
            delay = varargin{n+1};
        else
            msg.(varargin{n}) = varargin{n+1};
        end
    end

    % exec
    msgRcv = remoteSendMessage(obj.srv, msg);
    
    pause( delay );
end