function set_probe_temperature_alarm_threshold( obj, temperature )
    obj = obj.setParam('ProbeTemperatureAlarmTreshold', temperature);
    
    poly_temp = [ 0.000541437 0.00228943 -12.1675 810.747 ];
    digitalVal = polyval( poly_temp, temperature ) * 2^6; % hex2dec('4540');

    obj.i2c_enable();

    msgRcv = obj.i2c('opcode', 'shi_analog_output', 'startStopFlag', '1', 'data', hex2dec('12') );
    msgRcv = obj.i2c('opcode', 'shi_analog_output', 'startStopFlag', '2', 'rw16Bits', '1', 'data', digitalVal );
end