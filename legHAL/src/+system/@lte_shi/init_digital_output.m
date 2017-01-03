function init_digital_output( obj )
    obj.i2c_enable();
    
    for n={ '0A42', '0000', '0100', '1210', '1200' }
        msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec(n) );
    end
end