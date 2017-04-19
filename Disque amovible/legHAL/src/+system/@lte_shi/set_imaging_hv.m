function set_imaging_hv( obj, ihv )

    ihv_lb         = 16.5; % imaging HV lower bound (V)
    ihv_hb         = 39.5; % imaging HV higher bound (V)

    obj = obj.setParam( 'imagingVoltage', ihv );

    dac_value  = uint16( 65535 / (ihv_hb - ihv_lb) * ( ihv - ihv_lb) );

    obj.i2c_enable();

    msgRcv = obj.i2c('opcode', 'shi_tpc', 'startStopFlag', '1', 'data', hex2dec('30') );
    msgRcv = obj.i2c('opcode', 'shi_tpc', 'startStopFlag', '2', 'rw16Bits', '1', 'data', sprintf('%i', dac_value) );
    
    rails_sides = obj.rails_im;
    obj.set_rails( rails_sides );
    obj.report_and_clear_alarms(1,0);
end