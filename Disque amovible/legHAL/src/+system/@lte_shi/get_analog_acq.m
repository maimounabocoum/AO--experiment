function acq = get_analog_acq( obj )
    obj.i2c_enable();

    poly_temp_Im = [ -3.52547e-9 2.35737e-5 -0.0774284 117.25 ];
    poly_temp_Th = [ -3.52262e-9 2.28564e-5 -0.0709922 105.353 ] ;
    
    acq = zeros(4,8);
    meas = zeros(4,8);
    
    for mux_sels = 0:3
        msgRcv = obj.i2c('opcode', 'shi_digital_output', 'rw16Bits', '1', 'data', hex2dec('1300')+mux_sels, 'pause', obj.delay_mux_sels );

        obj.i2c_enable(); % useless ?

        for ch=1:8
            obj.i2c_enable();

            msgRcv = obj.i2c('opcode', 'shi_analog_input', 'data', sprintf('%i',132+16*(ch-1)) );
            msgRcv = obj.i2c('opcode', 'shi_analog_input', 'rw16Bits', '1', 'read', '1' );

            meas(mux_sels+1,ch) = sscanf(msgRcv.data,'%i');
        end
    end

    % convertions
    acq(1, 1:4) = meas(1, 1:4) / obj.V_HV_conv;
    acq(1, 5:8) = meas(1, 5:8) / obj.I_HV_conv;
    
    acq(2, 1)   = meas(2, 1) / obj.minusV5_conv;
    acq(2, 2)   = meas(2, 2) / obj.V5_5_conv;
    acq(2, 3:4) = meas(2, 3:4);
    acq(2, 5)   = meas(2, 5) / obj.V5_conv;
    acq(2, 6)   = meas(2, 6) / obj.minusV5_conv;
    acq(2, 7)   = meas(2, 7) / obj.V5_5_conv;
    acq(2, 8)   = meas(2, 8) / obj.V12_conv;
    
    acq(3, 1:3) = polyval( poly_temp_Im, meas(3,1:3) );
    acq(3, 4:8) = polyval( poly_temp_Th, meas(3,4:8) );
    
    acq(4, 1:4) = polyval( poly_temp_Th, meas(4,1:4) );
    acq(4, 5:8) = meas(4,5:8) / obj.user_conv;
end