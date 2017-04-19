function set_ld_alarm_threshold( obj, ld, nb_tx, freq_mhz )
    
    marging_coef = 1.15; % 10 % ?
    volt_to_dac_coef = 1024/2.5;
    
    if ld == 1
        poly_nb_tx(1,:) = [  0.00000194  -0.00072752   0.01483333 ];
        poly_nb_tx(2,:) = [ -0.00001088   0.00521411  -0.08266667 ];
        poly_nb_tx(3,:) = [  0.00000397   0.00254012   0.082      ];
        ld_addr = '14'; % DAC ch3 curr LD1

    elseif ld == 2
        poly_nb_tx(1,:) = [ -0.00000469   0.00022974  -0.0025     ];
        poly_nb_tx(2,:) = [  0.0000255   -0.00005605   0.01266667 ];
        poly_nb_tx(3,:) = [ -0.00003539   0.00849456  -0.01566667 ];
        ld_addr = '16'; % DAC ch3 curr LD1

    else
        error( [ 'Bad LD : ' num2str(ld) ', must be 1 or 2' ] )

    end

    obj.setParam('ldAlarmTreshold_nbTx', nb_tx );
    obj.setParam('ldAlarmTreshold_freq', freq_mhz );

    poly_freq = [ 0 0 0 ]; for n=1:3; poly_freq(n) = polyval( poly_nb_tx(n,:), nb_tx ) ; end
    volt_thr_value = polyval( poly_freq, freq_mhz ) * marging_coef;
    dac_val = ( volt_thr_value * volt_to_dac_coef ) * 2^6; % 2^6 to shiftleft by 6

    obj.i2c_enable();
    msgRcv = obj.i2c('opcode', 'shi_analog_output', 'startStopFlag', '1', 'data', hex2dec(ld_addr) );
    msgRcv = obj.i2c('opcode', 'shi_analog_output', 'startStopFlag', '2', 'rw16Bits', '1', 'data', dac_val );

end