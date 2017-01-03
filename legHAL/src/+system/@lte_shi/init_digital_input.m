function init_digital_input( obj )
    obj.i2c_enable();
    
    for n={ '0A62', '00FF', '01FF', '04CF', '0506', '06FD', '08FF', '0900' }
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'rw16Bits', '1', 'data', hex2dec(n) );
    end
    
    for n={ '10', '11' }
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '1', 'data', hex2dec(n), 'pause', 0 );
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'read', '1', 'startStopFlag', '2', 'data', hex2dec(n) );
    end
end