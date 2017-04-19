%Copyright 2010 Supersonic Imagine
%$Revision: 2.00$  $Date: 2010/Sept/06$
%M-File function.
%Liver therapy specific functions

function h = Liver

% Liver constants
h.delayI2C       = 0.0003;        % delay between i2C commands
h.delay_rel_on   = 0.005;         % delay to toggle a relay
h.delay_cmd_rel  = 0.010;         % delay between 2 relay commands
h.delay_mux_sels = 0.0003;         % delay for mux selection
h.delay_rail_sel = 1;              % delay for rails selection to have no alram at 36 volt in image mode see HW-256 form more details  1s to fix the issue on linux
h.rel_im         = hex2dec('0F');
h.rel_th         = 0;
h.rails_im       = hex2dec('0F'); % all rails on ASTEC side
h.rails_th       = 0;             % all rails on MAGNA side
h.ihv_lb         = 16.5;          % imaging HV lower bound (V)
h.ihv_lb_limit   = 22.0;          % imaging HV lower limit due tothe current limitation issue on Tpc board (V) see HW-256
h.ihv_hb         = 39.5;          % imaging HV higher bound (V)
h.thhv_lb        = 0;             % therapy HV lower bound (V)
h.thhv_hb        = 16;            % therapy HV higher bound (V)
h.thhv_losses    = 1.5;           % therapy HV losses between MAGNA and pulsers

% Analog conversions constants
h.V_HV_conv    = 3276/38;
h.I_HV_conv    = 3276/50;
h.V5_conv      = 3276/5;
h.minusV5_conv = 1500/-5;
h.V12_conv     = 3276/12;
h.V5_5_conv    = 3288/5.5;
h.user_conv    = 3276/2;

% =========================================================================== %

% List of methods
h.init_ihv                     = @init_ihv;
h.init_rel                     = @init_rel;
h.init_rails                   = @init_rails;
h.report_and_clear_shi_alarms  = @report_and_clear_shi_alarms;
h.init_normal_mode             = @init_normal_mode;             % therapy mode
h.init_normal_mode_with_hydro  = @init_normal_mode_with_hydro;  % therapy mode with 1st RxChan for hydro
h.init_imaging_mode            = @init_imaging_mode;            % imaging mode
h.init_imaging_with_MAGNA_mode = @init_imaging_with_MAGNA_mode; % imaging mode with Magna power


% Additional methods
h.set_probe_interlock_mask                  = @set_probe_interlock_mask;
h.analog_acq                                = @analog_acq;
h.analog_acq_display                        = @analog_acq_display;
h.set_therapy_probe_celsius_alarm_threshold = ...
    @set_therapy_probe_celsius_alarm_threshold;
h.Th_temp_conv                 = @Th_temp_conv;                 % convert temperature
h.set_ld_alarm_threshold = @set_ld_alarm_threshold;
% Methods for test
h.init_DO  = @init_DO;
h.init_DI  = @init_DI;
h.init_DAC = @init_DAC;

% opcode = 'shi_tpc', 'shi_digital_output', 'shi_digital_input',
% 'shi_analog_output', shi_analog_input'

% =========================================================================== %
% =========================================================================== %

function init_ihv (srv, ihv)
% init_ihv (srv,ihv)
% to set the imaging HV
% srv is remote server
% ihv is the imaging hv between 22.0 and 39.5 V

    if ihv > h.ihv_hb || ihv < h.ihv_lb_limit;
        warning('LIVER:INIT_IHV', ['init_ihv: Wanted imaging HV=' ...
            num2str(ihv) 'V out of bounds:[' num2str(h.ihv_lb_limit) ':' ...
            num2str(h.ihv_hb) ']V. Cmd not executed.']);
        return;
    end;

    dac_value  = uint16(65535/(h.ihv_hb-h.ihv_lb)*(ihv-h.ihv_lb));
    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.data          = hex2dec('30');  % mandatory parameter, string ATTENTION BUG si trop grand:adresse bouffée
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msg.opcode        = 'shi_tpc';
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    msg.data          = sprintf('%i',dac_value);  % mandatory parameter, string
    msg.rw16Bits      = '1';
    msg.startStopFlag = '2'; % stop only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

end

% =========================================================================== %

function init_DO(srv)
% init du circuit digital output

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_digital_output';
    msg.data          = hex2dec('0A42');
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    msg.data = hex2dec('0000');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    msg.data = hex2dec('0100');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    msg.data = hex2dec('1210'); % clear alarm 
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C);
    
    msg.data = hex2dec('1200');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

end

% =========================================================================== %

function set_probe_interlock_mask(srv, theMask)
% theMask: 0:no interlock, 1: imaging probe interlock, 2: therapy probe
% interlock, 3: both interlocks

    if theMask < 0 || theMask > 3;
        warning('LIVER:SET_PROBE_INTERLOCK_MASK', ['theMask=' ...
            num2str(theMask) ' out of bounds:[' num2str(0) ':' ...
            num2str(3) ']. Cmd not executed.']);
        return;
    end;

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_digital_input';
    msg.data          = hex2dec('0500')+2*theMask;
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % GPINTENB (int mask) should be 0500+2*theMask

end

% =========================================================================== %

function init_DI(srv)
% init du circuit digital input

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_digital_input';
    msg.data          = hex2dec('0A62');
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % IOCON

    msg.data = hex2dec('00FF');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % port A pins as inputs

    msg.data = hex2dec('01FF');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % port B pins as inputs

    %msg.data = hex2dec('04C3'); % pas de shi fault sur curent_ld1 et ld2
    msg.data = hex2dec('04CF'); % all alarm tested (FAULT1 and 2 not implemented) 
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % GPINTENA (int mask) should be 04CF

    msg.data = hex2dec('0506');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % GPINTENB (int mask) should be 0506

    msg.data = hex2dec('06FD');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % DEFVALA (no alarm value)

    msg.data = hex2dec('08FF');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % INTCONA (1:int on level, 0:int on change)

    msg.data = hex2dec('0900');
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C); % INTCONB (1:int on level, 0:int on change)

    %%% msg.data string ou pas string ????? Il doit faire un class(msg.data)
    %%% pour eviter les pbs

    % port A
    msg.read          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msg.data          = hex2dec('10');
    msgRcv            = remoteSendMessage(srv,msg); % INTCAPA

    msg.read          = '1';
    msg.data          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '2'; % stop only
    msg.data          = '0';
    msgRcv            = remoteSendMessage(srv,msg);
    pause(h.delayI2C); % INTCAPA

    % port B
    msg.read          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msg.data          = hex2dec('11');
    msgRcv            = remoteSendMessage(srv,msg); % INTCAPB

    msg.read          = '1';
    msg.data          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '2'; % stop only
    msg.data          = '0';
    msgRcv            = remoteSendMessage(srv,msg);
    pause(h.delayI2C); % INTCAPB

end

% =========================================================================== %

function init_DAC(srv)
% init des seuils d'alarme

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name   = 'i2c_rw';
    msg.read   = '0';
    msg.opcode = 'shi_analog_output';

    % DAC ch0 temp CAB
    msg.data          = hex2dec('10');  % mandatory parameter, string ATTENTION BUG si trop grand:adresse bouffée
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    %%%%msg.data=hex2dec('FFFF');  %%%% pour tester les interruptions
    msg.data          = hex2dec('4540');
    msg.rw16Bits      = '1';
    msg.startStopFlag = '2'; % stop only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    % DAC ch1 temp PRB
    msg.data          = hex2dec('12');
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    %%%%msg.data=hex2dec('FFFF');  %%%% pour tester les interruptions
    msg.data          = hex2dec('4540');
    msg.rw16Bits      = '1';
    msg.startStopFlag = '2'; % stop only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    % DAC ch3 curr LD1 and LD2
    set_ld_alarm_threshold(srv, 1,128,4) % set the LD1 current alarm for 128 tx at 4 mhz
    set_ld_alarm_threshold(srv, 2,128,4) % set the LD2 current alarm for 128 tx at 4 mhz

end

% =========================================================================== %

function init_rel(srv, rel_sides, hydro)
% bascule des relais

    if rel_sides < 0 || rel_sides > h.rel_im;
        warning('LIVER:INIT_REL', ['rel_sides=' num2str(rel_sides) ' out ' ...
            'of bounds:[' num2str(0) ':' num2str(h.rel_im) ']. Cmd not ' ...
            'executed.']);
        return;
    end;

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_digital_output';

    if hydro

        msg.data = hex2dec('1370')+0;
        msgRcv   = remoteSendMessage(srv, msg);
        pause(h.delay_rel_on);

        msg.data = hex2dec('1300')+0;
        msgRcv   = remoteSendMessage(srv, msg);
        pause(h.delay_cmd_rel);

    else

        msg.data = hex2dec('1370')+1;
        msgRcv   = remoteSendMessage(srv, msg);
        pause(h.delay_rel_on);

        msg.data = hex2dec('1300')+1;
        msgRcv   = remoteSendMessage(srv, msg);
        pause(h.delay_cmd_rel);

    end

    msg.data = hex2dec('1310') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_rel_on);

    msg.data = hex2dec('1300') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_cmd_rel);

    msg.data = hex2dec('1320') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_rel_on);

    msg.data = hex2dec('1300') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_cmd_rel);

    msg.data = hex2dec('1340') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_rel_on);

    msg.data = hex2dec('1300') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_cmd_rel);

    msg.data = hex2dec('1380') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delay_rel_on);

    msg.data = hex2dec('1300') + rel_sides;
    msgRcv   = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

end

% =========================================================================== %
function set_ld_alarm_threshold(srv, ld,nb_tx,freq_mhz)
% init des seuils d'alarme
    if ld < 1 || ld > 2;
        warning('LIVER:set_ld_alarm_threshold', ...
            ['ld=' num2str(ld) ' out of bounds:[' num2str(1) ':' ...
            num2str(2) ']. Cmd not executed.']);
        return;
    end;
    if nb_tx < 1 || nb_tx > 128;
        warning('LIVER:set_ld_alarm_threshold', ...
            ['nb_tx=' num2str(nb_tx) ' out of bounds:[' num2str(1) ':' ...
            num2str(128) ']. Cmd not executed.']);
        return;
    end;
    if freq_mhz < 0 || freq_mhz > 4;
        warning('LIVER:set_ld_alarm_threshold', ...
            ['freq_mhz=' num2str(freq_mhz) ' out of bounds:[' num2str(0) ':' ...
            num2str(4) ']. Cmd not executed.']);
        return;
    end;
    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name   = 'i2c_rw';
    msg.read   = '0';
    msg.opcode = 'shi_analog_output';

    % DAC ch3 curr LD1
    if ld == 1
        volt_thr_value = (0.00000194*nb_tx*nb_tx-0.00072752*nb_tx+0.01483333)*freq_mhz*freq_mhz...
        +(-0.00001088*nb_tx*nb_tx+0.00521411*nb_tx-0.08266667)*freq_mhz...
        +(0.00000397*nb_tx*nb_tx+0.00254012*nb_tx+0.082);
        volt_thr_value = volt_thr_value*1.15; % marging = 10% *1.15
        dac_val = ((volt_thr_value * 1024)/2.5 )*2^6; % 2^6 to shiftleft by 6
        msg.data          = hex2dec('14');
        msg.rw16Bits      = '0';
        msg.startStopFlag = '1'; % start only
        msgRcv            = remoteSendMessage(srv, msg);
        pause(h.delayI2C);

        msg.data          = dac_val; 
        msg.rw16Bits      = '1';
        msg.startStopFlag = '2'; % stop only
        msgRcv            = remoteSendMessage(srv, msg);
        pause(h.delayI2C);
    else 
        % DAC ch4 curr LD2
        volt_thr_value = (-0.00000469*nb_tx*nb_tx+0.00022974*nb_tx-0.0025)*freq_mhz*freq_mhz...
        +(0.0000255*nb_tx*nb_tx-0.00005605*nb_tx+0.01266667)*freq_mhz...
        +(-0.00003539*nb_tx*nb_tx+0.00849456*nb_tx-0.01566667);
        volt_thr_value = volt_thr_value*1.15; % marging = 10% *1.10
        dac_val = ((volt_thr_value * 1024)/2.5 )*2^6; % 2^6 to shiftleft by 6
        msg.data          = hex2dec('16');
        msg.rw16Bits      = '0';
        msg.startStopFlag = '1'; % start only
        msgRcv            = remoteSendMessage(srv, msg);
        pause(h.delayI2C);
        msg.data          = dac_val;
        msg.rw16Bits      = '1';
        msg.startStopFlag = '2'; % stop only
        msgRcv            = remoteSendMessage(srv, msg);
        pause(h.delayI2C);
    end

end

function set_therapy_probe_celsius_alarm_threshold(srv, celsius)

    if celsius < 10 || celsius > 70;
        warning('LIVER:SET_THERAPY_PROBE_CELSIUS_ALARM_THRESHOLD', ...
            ['celsius=' num2str(celsius) ' out of bounds:[' num2str(10) ':' ...
            num2str(70) ']. Cmd not executed.']);
        return;
    end;

    digitalVal = round(0.000541437 * celsius^3 + 0.00228943 * celsius^2 ...
        - 12.1675 * celsius + 810.747);

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.opcode        = 'shi_analog_output';
    msg.data          = hex2dec('12');
    msg.rw16Bits      = '0';
    msg.startStopFlag ='1'; % start only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

    %%%%msg.data=hex2dec('FFFF');  %%%% pour tester les interruptions
    msg.data          = digitalVal*64; % hex2dec('4540');
    msg.rw16Bits      ='1';
    msg.startStopFlag = '2'; % stop only
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delayI2C);

end

% =========================================================================== %

function init_rails(srv, rails_sides)
% init des rails HV

    if rails_sides < 0 || rails_sides > h.rails_im;
        warning('LIVER:INIT_RAILS', ['rails_sides=' num2str(h.rails_sides) ...
            ' out of bounds:[' num2str(0) ':' num2str(h.rails_im) ']. Cmd ' ...
            'not executed.']);
        return;
    end;

    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_digital_output';
    msg.data          = hex2dec('1210') + rails_sides; % reset during setting to not have fault, see HW256 for more details
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delay_rel_on + h.delay_rail_sel);
    msg.data          = hex2dec('1200') + rails_sides;
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delay_rel_on);

end

% =========================================================================== %

function [flags_portA, flags_portB] = report_and_clear_shi_alarms(srv,varargin)

    if ( nargin < 2 )
        clear = true;
    elseif ( nargin == 2 )
        
        if ( ~isa(varargin{1},'logical') )
            % Build the prompt of the help dialog box
            ErrMsg = ['The report_and_clear_shi_alarms function needs 2nd ' ...
            'input argument corresponding to the clear alarm boolean true or false.'];
            error(ErrMsg);  
        end;
        clear = varargin{1};
    end;
    if clear 
        WarnTitle = 'LIVER:REPORT_AND_CLEAR_SHI_ALARMS';
    else 
        WarnTitle = 'LIVER:REPORT_AND_SHI_ALARMS';        
    end;
    
    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name   = 'i2c_rw';
    msg.opcode = 'shi_digital_input';

    % int reason port A
    msg.read          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msg.data          = hex2dec('0E');
    msgRcv            = remoteSendMessage(srv,msg); % INTFA (flags)

    msg.read          = '1';
    msg.data          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '2'; % stop only
    msg.data          = '0';
    msgRcv            = remoteSendMessage(srv,msg);
    pause(h.delayI2C); % INTFA (flags)

    flags_portA = uint8(str2num(msgRcv.data));
    if bitget(flags_portA,8) == 1;
        warning(WarnTitle, 'SHI alarm: cabinet overheat');
    end;
    if bitget(flags_portA,7) == 1;
        warning(WarnTitle, 'SHI alarm: therapy probe overheat');
    end;
    if bitget(flags_portA,6) == 1;
        warning(WarnTitle, 'SHI alarm: short circuit 2');
    end;
    if bitget(flags_portA,5) == 1;
        warning(WarnTitle, 'SHI alarm: short circuit 1');
    end;
    if bitget(flags_portA,4) == 1;
        warning(WarnTitle, 'SHI alarm: curr_LD2');
    end;
    if bitget(flags_portA,3) == 1;
        warning(WarnTitle, 'SHI alarm: curr_LD1');
    end;
    if bitget(flags_portA,2) == 1;
        warning(WarnTitle, 'SHI alarm: HV problem');
    end;
    if bitget(flags_portA,1) == 1;
        warning(WarnTitle, 'SHI alarm: MAGNA problem');
    end;

    % int reason port B
    msg.read          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '1'; % start only
    msg.data          = hex2dec('0F');
    msgRcv            = remoteSendMessage(srv,msg); % INTFB (flags)

    msg.read          = '1';
    msg.data          = '0';
    msg.rw16Bits      = '0';
    msg.startStopFlag = '2'; % stop only
    msg.data          = '0';
    msgRcv            = remoteSendMessage(srv,msg);
    pause(h.delayI2C); % INTFB (flags)

    flags_portB = uint8(str2num(msgRcv.data));
    if bitget(flags_portB,8) == 1;
        warning(WarnTitle, 'SHI alarm: GPB7');
    end;
    if bitget(flags_portB,7) == 1;
        warning(WarnTitle, 'SHI alarm: GPB6');
    end;
    if bitget(flags_portB,6) == 1;
        warning(WarnTitle, 'SHI alarm: GPB5');
    end;
    if bitget(flags_portB,5) == 1;
        warning(WarnTitle, 'SHI alarm: GPB4');
    end;
    if bitget(flags_portB,4) == 1;
        warning(WarnTitle, 'SHI alarm: GPB3');
    end;
    if bitget(flags_portB,3) == 1;
        warning(WarnTitle, 'SHI alarm: Therapy probe connected/disconnected');
    end;
    if bitget(flags_portB,2) == 1;
        warning(WarnTitle, 'SHI alarm: Imaging probe connected/disconnected');
    end;
    if bitget(flags_portB,1) == 1;
        warning(WarnTitle, 'SHI alarm: GPB0');
    end;
    if clear == true  
        disp( 'clear shi alarms');
        % clear int port A
        msg.read          = '0';
        msg.rw16Bits      = '0';
        msg.startStopFlag = '1'; % start only
        msg.data          = hex2dec('10');
        msgRcv            = remoteSendMessage(srv,msg); % INTCAPA

        msg.read          = '1';
        msg.data          = '0';
        msg.rw16Bits      = '0';
        msg.startStopFlag = '2'; % stop only
        msg.data          = '0';
        msgRcv            = remoteSendMessage(srv,msg);
        pause(h.delayI2C);

        % clear int port B
        msg.read          = '0';
        msg.rw16Bits      = '0';
        msg.startStopFlag = '1'; % start only
        msg.data          = hex2dec('11');
        msgRcv            = remoteSendMessage(srv,msg); %pause(h.delayI2C); % INTCAPB

        msg.read          = '1';
        msg.data          = '0';
        msg.rw16Bits      = '0';
        msg.startStopFlag = '2'; % stop only
        msg.data          = '0';
        msgRcv            = remoteSendMessage(srv,msg);
        pause(h.delayI2C);
    end;

end

% =========================================================================== %

function init_normal_mode(srv)
% Liver SHI init - normal mode: rails and relay on therapy side

    h.init_ihv(srv, 22);           % tension imagerie à 22V
    h.init_DAC(srv);               % init des seuils d'alarme
    h.init_DO(srv);                % init du circuit digital output
    h.init_DI(srv);                % init du circuit digital input
    h.init_rel(srv, h.rel_th, 0);  % bascule des relais
    h.init_rails(srv, h.rails_th); % init des rails HV
    % h.report_and_clear_shi_alarms(srv);

end

% =========================================================================== %

function init_normal_mode_with_hydro(srv)
% Liver SHI init - normal mode: rails and relay on therapy side

    h.init_ihv(srv, 22);          % tension imagerie Ã  22V
    init_DAC(srv);                % init des seuils d'alarme
    init_DO(srv);                 % init du circuit digital output
    init_DI(srv);                 % init du circuit digital input
    h.init_rel(srv, h.rel_th, 1); % bascule des relais
    h.init_rails(srv,h.rails_th); % init des rails HV
    % h.report_and_clear_shi_alarms(srv);

end

% =========================================================================== %

function init_imaging_mode(srv)
% Liver SHI init - imaging  mode: rails and relay on imaging side

    h.init_ihv(srv, 36);        % tension imagerie à 36V 72 on pulser
    h.init_DAC(srv);              % init des seuils d'alarme
    h.init_DO(srv);               % init du circuit digital output
    h.init_DI(srv);               % init du circuit digital input
    h.init_rel(srv, h.rel_im, 0); % bascule des relais
    h.init_rails(srv,h.rails_im); % init des rails HV

end

% =========================================================================== %

function init_imaging_with_MAGNA_mode(srv)
% Liver SHI init - imaging  mode with MAGNA: rails on therapy side and relay on
% imaging side

    h.init_ihv(srv, 22);          % tension imagerie à 22V
    h.init_DAC(srv);              % init des seuils d'alarme
    h.init_DO(srv);               % init du circuit digital output
    h.init_DI(srv);               % init du circuit digital input
    h.init_rel(srv, h.rel_im, 0); % bascule des relais
    h.init_rails(srv,h.rails_th); % init des rails HV
    h.report_and_clear_shi_alarms(srv);
end

% =========================================================================== %

function temp = Im_temp_conv(DigAcq12bits)

    temp = -3.52547e-9 * DigAcq12bits.^3 + 2.35737e-5 * DigAcq12bits.^2 ...
        -0.0774284 * DigAcq12bits + 117.25;

end

function temp = Th_temp_conv(DigAcq12bits)

    temp = -3.52262e-9 * DigAcq12bits.^3 + 2.28564e-5 * DigAcq12bits.^2 ...
        - 0.0709922 * DigAcq12bits + 105.353;

end

% =========================================================================== %

function meas = analog_acq_eight_ch(srv, mux_sels)

    meas = zeros(1,8);

    % mux selection
    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena); % 33ms

    msg.name          = 'i2c_rw';
    msg.read          = '0';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_digital_output';
    msg.data          = hex2dec('1300')+mux_sels;
    msgRcv            = remoteSendMessage(srv, msg);
    pause(h.delay_mux_sels);

    % analog acq 8 ch
    ena.name   = 'i2c_enable';
    ena.enable = true;
    msgRcv     = remoteSendMessage(srv,ena);

    msg.name          = 'i2c_rw';
    msg.read          = '1';
    msg.rw16Bits      = '1';
    msg.startStopFlag = '0';
    msg.opcode        = 'shi_analog_input';

    for ch=1:8;

        ena.name   = 'i2c_enable';
        ena.enable = true;
        msgRcv     = remoteSendMessage(srv,ena);

        msg.name          = 'i2c_rw';
        msg.read          = '0'; % write
        msg.data          = sprintf('%i',132+16*(ch-1));
        msg.rw16Bits      = '0';
        msg.startStopFlag = '0';
        msg.opcode        = 'shi_analog_input';
        msgRcv            = remoteSendMessage(srv, msg);
        pause(h.delayI2C);

        msg.read     = '1'; % read
        msg.data     = '0';
        msg.rw16Bits = '1';
        msgRcv       = remoteSendMessage(srv, msg);
        pause(h.delayI2C);

        meas(1,ch) = sscanf(msgRcv.data,'%i');

    end

end

% =========================================================================== %

function acq = analog_acq_conv(meas)

    % convertions
    acq(1, 1:4) = meas(1, 1:4) / h.V_HV_conv;
    acq(1, 5:8) = meas(1, 5:8) / h.I_HV_conv;
    
    acq(2, 1)   = meas(2, 1) / h.minusV5_conv;
    acq(2, 2)   = meas(2, 2) / h.V5_5_conv;
    acq(2, 3:4) = meas(2, 3:4);
    acq(2, 5)   = meas(2, 5) / h.V5_conv;
    acq(2, 6)   = meas(2, 6) / h.minusV5_conv;
    acq(2, 7)   = meas(2, 7) / h.V5_5_conv;
    acq(2, 8)   = meas(2, 8) / h.V12_conv;
    
    acq(3, 1:3) = Im_temp_conv(meas(3,1:3));
    acq(3, 4:8) = Th_temp_conv(meas(3,4:8));
    
    acq(4, 1:4) = Th_temp_conv(meas(4,1:4));
    acq(4, 5:8) = meas(4,5:8) / h.user_conv;

end

% =========================================================================== %

function acq = analog_acq(srv)

    acq  = zeros(4,8);
    meas = zeros(4,8);

    for i=1:4;

        meas(i,:) = analog_acq_eight_ch(srv, i-1);

    end;

    acq = analog_acq_conv(meas);

end
% =========================================================================
function acq = analog_acq_display(srv)
    acq = analog_acq(srv);
    disp('analog measures :')
    fprintf('V_HVA1 %f V \n',acq(1,1));
    fprintf('V_HVB1 %f V \n',acq(1,2));    
    fprintf('V_HVA2 %f V \n',acq(1,3));       
    fprintf('V_HVB2 %f V \n',acq(1,4));
    fprintf('I_HVA1 %f A \n',acq(1,5));
    fprintf('I_HVB1 %f A \n',acq(1,6));    
    fprintf('I_HVA2 %f A \n',acq(1,7));       
    fprintf('I_HVB2 %f A \n',acq(1,8));
    disp(' ');
    fprintf('V_-5VA1 %f V \n',  acq(2,1));
    fprintf('V_+5.5VA2 %f V \n',acq(2,2));    
    fprintf('Curr LD1 %f \n', acq(2,3));       
    fprintf('Curr LD2 %f \n', acq(2,4));
    fprintf('V_+5V %f V \n',    acq(2,5));
    fprintf('V_-5VA1 %f V \n',  acq(2,6));    
    fprintf('V_+5.5VA1 %f V \n',acq(2,7));       
    fprintf('V+12V %f V \n',    acq(2,8));
    disp(' ');  
    fprintf('TEMP1 %f ?C \n', acq(3,1));
    fprintf('TEMP2 %f ?C \n', acq(3,2));    
    fprintf('TEMP3 %f ?C \n', acq(3,3));       
    fprintf('TEMP4 %f ?C \n', acq(3,4));
    fprintf('TEMP9 %f ?C \n', acq(3,5));
    fprintf('TEMP10 %f ?C \n',acq(3,6));    
    fprintf('TEMP11 %f ?C \n',acq(3,7));       
    fprintf('TEMP12 %f ?C \n',acq(3,8));
    disp(' ');
    fprintf('TEMP5 %f ?C \n',acq(4,1));
    fprintf('TEMP6 %f ?C \n',acq(4,2));    
    fprintf('TEMP7 %f ?C \n',acq(4,3));       
    fprintf('TEMP8 %f ?C \n',acq(4,4));
    fprintf('User0 %f V \n',acq(4,5));
    fprintf('User1 %f V \n',acq(4,6));    
    fprintf('User2 %f V \n',acq(4,7));       
    fprintf('User3 %f V \n',acq(4,8));    

end
        
% =========================================================================== %
% =========================================================================== %

end