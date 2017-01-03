function report_and_clear_alarms( obj, varargin )
    clear = 1;
    display = 1;
    if nargin >= 2
        if varargin{1} == 0
            clear = 0;
        end
        if nargin >= 3
            if varargin{2} == 0
                display = 0;
            end
        end
    end
    
    if display
        if clear
            WarnTitle = 'LIVER:REPORT_AND_CLEAR_SHI_ALARMS';
        else 
            WarnTitle = 'LIVER:REPORT_AND_SHI_ALARMS';        
        end;

        obj.i2c_enable();

        % port A
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '1', 'data', hex2dec('0E'), 'pause', 0 );
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '2', 'read', '1' );

        flags_portA = uint8(str2double(msgRcv.data));
        if bitget(flags_portA,8) == 1
            warning(WarnTitle, 'SHI alarm: cabinet overheat');
        end
        if bitget(flags_portA,7) == 1
            warning(WarnTitle, 'SHI alarm: therapy probe overheat');
        end
        if bitget(flags_portA,6) == 1
            warning(WarnTitle, 'SHI alarm: short circuit 2');
        end
        if bitget(flags_portA,5) == 1
            warning(WarnTitle, 'SHI alarm: short circuit 1');
        end
        if bitget(flags_portA,4) == 1
            warning(WarnTitle, 'SHI alarm: curr_LD2');
        end
        if bitget(flags_portA,3) == 1
            warning(WarnTitle, 'SHI alarm: curr_LD1');
        end
        if bitget(flags_portA,2) == 1
            warning(WarnTitle, 'SHI alarm: HV problem');
        end
        if bitget(flags_portA,1) == 1
            warning(WarnTitle, 'SHI alarm: MAGNA problem');
        end

        % port B
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '1', 'data', hex2dec('0F'), 'pause', 0 );
        msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '2', 'read', '1' );

        flags_portB = uint8(str2double(msgRcv.data));
        if bitget(flags_portB,8) == 1
            warning(WarnTitle, 'SHI alarm: GPB7');
        end
        if bitget(flags_portB,7) == 1
            warning(WarnTitle, 'SHI alarm: GPB6');
        end
        if bitget(flags_portB,6) == 1
            warning(WarnTitle, 'SHI alarm: GPB5');
        end
        if bitget(flags_portB,5) == 1
            warning(WarnTitle, 'SHI alarm: GPB4');
        end
        if bitget(flags_portB,4) == 1
            warning(WarnTitle, 'SHI alarm: GPB3');
        end
        if bitget(flags_portB,3) == 1
            warning(WarnTitle, 'SHI alarm: Therapy probe connected/disconnected');
        end
        if bitget(flags_portB,2) == 1
            warning(WarnTitle, 'SHI alarm: Imaging probe connected/disconnected');
        end
        if bitget(flags_portB,1) == 1
            warning(WarnTitle, 'SHI alarm: GPB0');
        end
    end

    if clear == 1
        disp( 'clearing shi alarms' );

        for n = { '10', '11' }
            msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '1', 'data', hex2dec(n), 'pause', 0 );
            msgRcv = obj.i2c('opcode', 'shi_digital_input', 'startStopFlag', '2', 'read', '1' );
        end
    end
end