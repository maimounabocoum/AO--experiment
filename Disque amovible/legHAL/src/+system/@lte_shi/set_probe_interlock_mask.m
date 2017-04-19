function set_probe_interlock_mask( obj, mask )
    obj = obj.setParam( 'ProbeInterlockMask', mask )

    obj.i2c_enable();

    msgRcv = obj.i2c('opcode', 'shi_digital_input', 'rw16Bits', '1', 'data', hex2dec('0500')+2*mask );
end