function set_rel( obj, rails_sides, hydro )
    obj.i2c_enable();

    if hydro
        a = 0;
    else
        a = 1;
    end

    msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec('1370')+a, 'pause', obj.delay_rel_on );
    msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec('1300')+a, 'pause', obj.delay_cmd_rel );

    for n={ '1310', '1320', '1340', '1380' }
        msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec(n)+rails_sides, 'pause', obj.delay_rel_on );
        msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec('1300')+rails_sides, 'pause', obj.delay_cmd_rel );
    end
    pause( obj.delayI2C );
end