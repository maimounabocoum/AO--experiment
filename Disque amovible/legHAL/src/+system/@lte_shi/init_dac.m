function init_dac( obj )
    obj.i2c_enable();
    
    for n={ '10', '12' }
        msgRcv = obj.i2c('opcode', 'shi_analog_output', 'startStopFlag', '1', 'data', hex2dec(n) );
        msgRcv = obj.i2c('opcode', 'shi_analog_output', 'startStopFlag', '2', 'rw16Bits', '1', 'data', hex2dec('4540') );
    end

    obj.set_ld_alarm_threshold( 1, obj.getParam('ldAlarmTreshold_nbTx'), obj.getParam('ldAlarmTreshold_freq') );
    obj.set_ld_alarm_threshold( 2, obj.getParam('ldAlarmTreshold_nbTx'), obj.getParam('ldAlarmTreshold_freq') );
end