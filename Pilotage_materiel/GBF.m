classdef GBF < Measurement_tool
    %GBF Summary of this class goes here
    %   Detailed explanation goes here
      
    properties
        Nb_channels; % Number of channels
        Frequency; %Values of channel 1 and 2
        Shape; %Shape of channel 1 and 2
        Vpp; % Voltage peak to peak of channel 1 and 2
        Voffset; % Offset voltage of channel 1 and 2
        Phase; % Phase of channel 1 and 2
        State; % State of channel 1 and 2
        %     BurstMode; % state mode
        %     BurstInterval; %time interval between two bursts
        %     BurstNcycles; % number of cycles
    end
    
    properties(Access  = private)
        delay_command = 0; % Increase this value in constructor if the commands are not taken into account
    end
    
    methods
        function obj = GBF(info1,info2,info3,info4)
            obj@Measurement_tool(info1,info2,info3,info4);
            init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
            obj = init(obj);
        end
        function obj = init_GBF_RIGOL_DG1022(obj)
            obj.open_communication;
            obj.Nb_channels = 2;
            obj.delay_command = 0.05;
            %         obj.State = obj.State;
            %         obj.Frequency = obj.Frequency;
            %         obj.Shape = obj.Shape; %Shape of channel 1 and 2
            %         obj.Vpp = obj.Vpp; % Voltage peak to peak of channel 1 and 2
            %         obj.Voffset = obj.Voffset; % Offset voltage of channel 1 and 2
            %         obj.Phase = obj.Phase; % Phase of channel 1 and 2
        end
        function obj = init_GBF_TEKTRONIX_AFG3101C(obj)
            obj.open_communication;
            obj.Nb_channels = 1;
        end
        function obj = init_GBF_AGILENT_33220A(obj)
            obj.open_communication;
            obj.Nb_channels = 1;
        end
        function nb_channels = get.Nb_channels(obj)
            
            nb_channels = obj.Nb_channels;
        end
        function obj = set.Frequency(obj,frequency)
            fprintf(obj.tool,['FREQuency ',num2str(frequency)]);
        end
        function frequency = get.Frequency(obj)
            pause(obj.delay_command);
            frequency = str2num(query(obj.tool,['FREQuency?']));
        end
        function obj = set.Shape(obj,shape)
            fprintf(obj.tool,['APPLy:',upper(shape)]);
        end
        function shape = get.Shape(obj)
            tmp = strsplit(query(obj.tool,['FUNCtion?']),':');
            shape =  strtrim(char(tmp(2)));
        end
        function obj = set.Vpp(obj,vpp)
            fprintf(obj.tool,['VOLTage ',num2str(vpp)]);
        end
        function vpp = get.Vpp(obj)
            pause(obj.delay_command);
            vpp = str2num(query(obj.tool,['VOLTage?']));
        end
        function obj = set.Voffset(obj,voffset)
            fprintf(obj.tool,['VOLTage:OFFSet ',num2str(voffset)]);
        end
        function voffset = get.Voffset(obj)
            pause(obj.delay_command);
            voffset = str2num(query(obj.tool,['VOLTage:OFFSet?']));
        end
        function obj = set.Phase(obj,phase)
            fprintf(obj.tool,['PHASe ',num2str(phase)]);
        end
        function phase = get.Phase(obj)
            pause(obj.delay_command);
            phase = str2num(query(obj.tool,['PHASe?']));
        end
        function obj = set.State(obj,state)
            if ischar(state)
                if strcmpi(state,'on')
                    fprintf(obj.tool,['OUTPut ',upper('on')]);
                else
                    if strcmpi(state,'off')
                        fprintf(obj.tool,['OUTPut ',upper('off')]);
                    else
                        error('command not valid');
                    end
                end
            else
                if state==1
                    fprintf(obj.tool,['OUTPut ',upper('on')]);
                else
                    if state==0
                        fprintf(obj.tool,['OUTPut ',upper('off')]);
                    else
                        error('command not valid');
                    end
                end
            end
        end
        function state = get.State(obj)
            tmp = strtrim(query(obj.tool,['OUTPut?']));
            if strcmpi(tmp,'0') state = 'off';
            elseif strcmpi(tmp,'1') state = 'on'; end
        end
        %     function obj = set.BurstMode(obj,burstMode)
        %       if ischar(burstMode)
        %         if strcmpi(burstMode,'on')
        %             fprintf(obj.tool,['BURSt ',upper('on')]);
        %             fprintf(obj.tool,['TRIGger:SEQuence:SOURce ','TIMer']);
        %         else
        %             if strcmpi(burstMode,'off')
        %                 fprintf(obj.tool,['BURSt ',upper('off')]);
        %             else
        %                 error('command not valid');
        %             end
        %         end
        %       else
        %         if burstMode==1
        %             fprintf(obj.tool,['BURSt ',upper('on')]);
        %             fprintf(obj.tool,['TRIGger:SEQuence:SOURce ','TIMer']);
        %         else
        %             if burstMode==0
        %                 fprintf(obj.tool,['BURSt ',upper('off')]);
        %             else
        %                 error('command not valid');
        %             end
        %         end
        %       end
        %     end
        %     function burstMode = get.BurstMode(obj)
        %       tmp = strtrim(query(obj.tool,['BURSt?']));
        %       if strcmpi(tmp,'0') burstMode = 'off';
        %       elseif strcmpi(tmp,'1') burstMode = 'on'; end
        %     end
        %     function obj = set.BurstInterval(obj,burstInterval)
        %       fprintf(obj.tool,['TRIGger:SEQuence:TIMer ',num2str(burstInterval), 'ms']);
        %     end
        %     function burstInterval = get.BurstInterval(obj)
        %       burstInterval = str2num(query(obj.tool,['TRIGger:SEQuence:TIMer?']));
        %     end
        %     function obj = set.BurstNcycles(obj,burstNcycles)
        %       fprintf(obj.tool,['BURSt:NCYCles ',num2str(burstNcycles)]);
        %     end
        %     function burstNcycles = get.BurstNcycles(obj)
        %       burstNcycles = str2num(query(obj.tool,['BURSt:NCYCles?']));
        %     end
        function parameters = config(obj)
            parameters.Nb_channels = obj.Nb_channels;
            parameters.Frequency = obj.Frequency;
            parameters.Vpp = obj.Vpp;
            parameters.Voffset = obj.Voffset;
            parameters.Phase = obj.Phase;
        end
        function delete(obj)
            obj.close_communication;
        end
    end
end

