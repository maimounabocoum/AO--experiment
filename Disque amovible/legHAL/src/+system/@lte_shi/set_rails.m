function set_rails( obj, rails_sides )
    obj.i2c_enable();

    pause = obj.delay_rel_on + obj.delay_rail_sel ;
    msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec('1210')+rails_sides, 'pause', pause );
    pause = obj.delay_rel_on ;
    msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec('1200')+rails_sides, 'pause', pause );

end