classdef Oscillo < Measurement_tool
  %OSCILLO Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Nb_points; % Nb points on xscale
    Nb_channels; % Nb of channels used
    X_division;
    Y_division;
    Resolution;
    State_channels;
    Xscale;
    Yscale1;
    Yscale2;
    Yscale3;
    Yscale4;
    Pt_Xscale;
    Pt_Yscale1;
    Pt_Yscale2;
    Pt_Yscale3;
    Pt_Yscale4;
    Offset_Yscale1;
    Offset_Yscale2;
    Offset_Yscale3;
    Offset_Yscale4;
    Trigger_Level1;
    Trigger_Level2;
    Trigger_Level3;
    Trigger_Level4;
    Trigger_Start;
    Trigger_Armed;
  end
  
  methods
    function obj=Oscillo(info1,info2,info3,info4)
      obj = obj@Measurement_tool(info1,info2,info3,info4);
      init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
      obj = init(obj);
    end
    function obj = init_Oscillo_TEKTRONIX_DPO3034(obj)
      obj.Nb_channels = 4;
      obj.open_communication;
      obj.X_division = 5+5;
      obj.Y_division = 4+4;
    end
	function obj = init_Oscillo_TEKTRONIX_DPO2034(obj)
      obj.Nb_channels = 4;
      obj.open_communication;
      obj.X_division = 5+5;
      obj.Y_division = 4+4;
    end
    function obj = set.Nb_points(obj,nb_points)
      fprintf(obj.tool,['HORizontal:RECOrdlength ',num2str(nb_points)]);
      obj.close_communication;
      set(obj.tool, 'InputBufferSize', 20*nb_points); %20 bits
      obj.open_communication;
    end
    function nb_points = get.Nb_points(obj)
      nb_points = str2num(query(obj.tool,['HORizontal:RECOrdlength?']));
      if (get(obj.tool, 'InputBufferSize') ~= nb_points*20)
        obj.Nb_points = nb_points;
      end
    end
    function resolution = get.Resolution(obj)
      resolution = str2num(query(obj.tool,['WFMInpre:BIT_Nr?']));
    end
    function obj = set.Resolution(obj,resolution)
      warning(['Command not available']);
    end    
    function obj = set.Xscale(obj,xscale)
      fprintf(obj.tool,['HORizontal:SCAle ',num2str(xscale)]);
    end
    function xscale = get.Xscale(obj)
      xscale = str2num(query(obj.tool,['HORizontal:SCAle?']));
    end
    function obj = set.Yscale1(obj,yscale)
      fprintf(obj.tool,['CH',num2str(1),':SCAle ',num2str(yscale)]);
    end
    function yscale1 = get.Yscale1(obj)
      yscale1 = str2num(query(obj.tool,['CH',num2str(1),':SCAle?']));
    end
    function obj = set.Yscale2(obj,yscale)
      fprintf(obj.tool,['CH',num2str(2),':SCAle ',num2str(yscale)]);
    end
    function yscale2 = get.Yscale2(obj)
      yscale2 = str2num(query(obj.tool,['CH',num2str(2),':SCAle?']));
    end
    function obj = set.Yscale3(obj,yscale)
      fprintf(obj.tool,['CH',num2str(3),':SCAle ',num2str(yscale)]);
    end
    function yscale3 = get.Yscale3(obj)
      yscale3 = str2num(query(obj.tool,['CH',num2str(3),':SCAle?']));
    end
    function obj = set.Yscale4(obj,yscale)
      fprintf(obj.tool,['CH',num2str(4),':SCAle ',num2str(yscale)]);
    end
    function yscale4 = get.Yscale4(obj)
      yscale4 = str2num(query(obj.tool,['CH',num2str(4),':SCAle?']));
    end
    function pt_xscale = get.Pt_Xscale(obj)
      pt_xscale = (obj.Xscale * obj.X_division)/obj.Nb_points; %% X_division = 10 for DP20 et DP30
    end
    function obj = set.Pt_Xscale(obj,pt_xscale)
      error('command not available');
    end
    function pt_yscale1 = get.Pt_Yscale1(obj)
      if(obj.State_channels(1)==1)
        fprintf(obj.tool,['DATA:SOURCE CH' num2str(1)]);
        pt_yscale1 = str2num(query(obj.tool,'WFMOutpre:YMUlt?'));  % LSB sur l'axe y
      else
        pt_yscale1 =0;
      end
    end
    function pt_yscale2 = get.Pt_Yscale2(obj)
      if(obj.State_channels(2)==1)
        fprintf(obj.tool,['DATA:SOURCE CH' num2str(2)]);
        pt_yscale2 = str2num(query(obj.tool,'WFMOutpre:YMUlt?'));  % LSB sur l'axe y
      else
        pt_yscale2 =0;
      end
    end
    function pt_yscale3 = get.Pt_Yscale3(obj)
      if(obj.State_channels(3)==1)
        fprintf(obj.tool,['DATA:SOURCE CH' num2str(3)]);
        pt_yscale3 = str2num(query(obj.tool,'WFMOutpre:YMUlt?'));  % LSB sur l'axe y
      else
        pt_yscale3 =0;
      end
    end
    function pt_yscale4 = get.Pt_Yscale4(obj)
      if(obj.State_channels(4)==1)
        fprintf(obj.tool,['DATA:SOURCE CH' num2str(4)]);
        pt_yscale4 = str2num(query(obj.tool,'WFMOutpre:YMUlt?'));  % LSB sur l'axe y
      else
        pt_yscale4 =0;
      end
    end
    function obj = set.Pt_Yscale1(obj,yscale)
      error('command not available');
    end
    function obj = set.Pt_Yscale2(obj,yscale)
      error('command not available');
    end
    function obj = set.Pt_Yscale3(obj,yscale)
      error('command not available');
    end
    function obj = set.Pt_Yscale4(obj,yscale)
      error('command not available');
    end
    function trigger_level = get.Trigger_Level1(obj)
      trigger_level = str2num(query(obj.tool,['TRIGger:A:LEVel:CH',num2str(1),'?']));
    end
    function trigger_level = get.Trigger_Level2(obj)
      trigger_level = str2num(query(obj.tool,['TRIGger:A:LEVel:CH',num2str(2),'?']));
    end
    function trigger_level = get.Trigger_Level3(obj)
      trigger_level = str2num(query(obj.tool,['TRIGger:A:LEVel:CH',num2str(3),'?']));
    end
    function trigger_level = get.Trigger_Level4(obj)
      trigger_level = str2num(query(obj.tool,['TRIGger:A:LEVel:CH',num2str(4),'?']));
    end
    function obj = set.Trigger_Level1(obj,trigger_level)
      fprintf(obj.tool,['TRIGger:A:LEVel:CH',num2str(1),' ',num2str(trigger_level)]);
    end
    function obj = set.Trigger_Level2(obj,trigger_level)
      fprintf(obj.tool,['TRIGger:A:LEVel:CH',num2str(2),' ',num2str(trigger_level)]);
    end
    function obj = set.Trigger_Level3(obj,trigger_level)
      fprintf(obj.tool,['TRIGger:A:LEVel:CH',num2str(3),' ',num2str(trigger_level)]);
    end
    function obj = set.Trigger_Level4(obj,trigger_level)
      fprintf(obj.tool,['TRIGger:A:LEVel:CH',num2str(4),' ',num2str(trigger_level)]);
    end
    function obj = set.State_channels(obj,State_channels)
      if (length(State_channels)==obj.Nb_channels)
        for ii=1:obj.Nb_channels
          if (State_channels(ii)==1)
            fprintf(obj.tool,['SELect:CH', num2str(ii), ' ON']);
          else
            fprintf(obj.tool,['SELect:CH', num2str(ii), ' OFF']);
          end
        end
      end
    end
    function offset_yscale = get.Offset_Yscale1(obj)
      offset_yscale = str2num(query(obj.tool,['CH' num2str(1) ':POSition?']));
    end
    function offset_yscale = get.Offset_Yscale2(obj)
      offset_yscale = str2num(query(obj.tool,['CH' num2str(2) ':POSition?']));
    end
    function offset_yscale = get.Offset_Yscale3(obj)
      offset_yscale = str2num(query(obj.tool,['CH' num2str(3) ':POSition?']));
    end
    function offset_yscale = get.Offset_Yscale4(obj)
      offset_yscale = str2num(query(obj.tool,['CH' num2str(4) ':POSition?']));
    end
    function obj = set.Offset_Yscale1(obj,offset_yscale)
      fprintf(obj.tool,['CH' num2str(1) ':POSition ' num2str(offset_yscale/obj.Yscale1)]);
    end
    function obj = set.Offset_Yscale2(obj,offset_yscale)
      fprintf(obj.tool,['CH' num2str(2) ':POSition ' num2str(offset_yscale/obj.Yscale2)]);
    end
    function obj = set.Offset_Yscale3(obj,offset_yscale)
      fprintf(obj.tool,['CH' num2str(3) ':POSition ' num2str(offset_yscale/obj.Yscale3)]);
    end
    function obj = set.Offset_Yscale4(obj,offset_yscale)
      fprintf(obj.tool,['CH' num2str(4) ':POSition ' num2str(offset_yscale/obj.Yscale4)]);
    end
    function obj = set.Trigger_Armed(obj,trig)
      if (trig == 1 )%|| strcmpi(trig,'ON'))
        fprintf(obj.tool,['ACQuire:STATE ON']);
      elseif (trig == 0 )%|| strcmpi(trig,'OFF'))
        fprintf(obj.tool,['ACQuire:STATE OFF']);
      else
c         warning(['Command not valid']);
      end
    end
    function trig = get.Trigger_Armed(obj)
      trig = query(obj.tool,['TRIGger:STATE?']);
    end
    function obj = set.Trigger_Start(obj,trig_start)
        fprintf(obj.tool,['HORizontal:DELay:TIMe ' num2str(trig_start)]);
    end
    function trig_start = get.Trigger_Start(obj)
      trig_start = str2num(query(obj.tool,['HORizontal:DELay:TIMe?']));
    end    
    function State_Channels = get.State_channels(obj)
      for ii=1:obj.Nb_channels
        State_Channels(ii) = str2num(query(obj.tool,['SELect:CH',num2str(ii),'?']));
      end
    end
    function data_channels = Data_channels(obj,id_channel)   
        if (exist('id_channel', 'var'))
            data_channels = zeros(length(id_channel),obj.Nb_points);
            for ii=1:length(id_channel)          
                if(obj.State_channels(id_channel(ii)) == 1)
                    data_channels(ii,:) = (eval(['obj.Pt_Yscale',num2str(id_channel(ii))]) * obj.acq_oscillo(id_channel(ii)))-eval(['obj.Offset_Yscale',num2str(id_channel(ii))]);
                else
                    warning(['Channel ',num2str(id_channel(ii)),' not activated']);
                end
            end
        else
            data_channels = zeros(obj.Nb_channels,obj.Nb_points);
            for id=1:obj.Nb_channels
                if(obj.State_channels(id) == 1) 
                    data_channels(id,:) = (eval(['obj.Pt_Yscale',num2str(id)]) * obj.acq_oscillo(id))-eval(['obj.Offset_Yscale',num2str(id)]);
                end
            end
        end
    end
    function signal_channel = acq_oscillo(obj, chan_acq)
        nb_points = obj.Nb_points;
        signal_channel=zeros(nb_points,1);
        maxCurve=2040000; % valeur maximale d'un point de la courbe pour un scope 8bit de dynamique
        fprintf(obj.tool,'DATA:SOURCE CH%i',chan_acq);
        fprintf(obj.tool,'DATA:ENCDG ASCII');
        fprintf(obj.tool,'DATA:START %i',1);
        fprintf(obj.tool,'DATA:STOP %i',nb_points);
        s = query(obj.tool,'CURVE?');
        [tmp_signal,b]=sscanf(s,'%f,');
        if size(tmp_signal,1)==nb_points;
            signal_channel = tmp_signal;
            max_tmp_signal=max(tmp_signal);
            if max(tmp_signal) > maxCurve;
              warning('acq_oscillo: CH%i saturation meas=%g > max=%g. Changer de calibre', chan_acq, maxa, maxCurve);
            end
        else
            warning('acq_oscillo: points manquants: demandés=%i obtenus=%i\n', nb_points, size(tmp_signal,1));
        end
    end
    function save_config(obj)
      root = pwd;
      cd('.\config_tools\');
      [file,path] = uiputfile('*.mat','Save Config');
      if ~strcmp(file,'')
        Nb_points = obj.Nb_points;
        Nb_channels = obj.Nb_channels;
        State_channels = obj.State_channels;
        Xscale = obj.Xscale;
        for ii=1:obj.Nb_channels
          eval(['Yscale',num2str(ii),' = ','obj.Yscale',num2str(ii),';']);
          eval(['Offset_Yscale',num2str(ii),' = ','obj.Offset_Yscale',num2str(ii),';']);
          eval(['Trigger_Level',num2str(ii),' = ','obj.Trigger_Level',num2str(ii),';']);
        end
        Trigger_Start = obj.Trigger_Start;
        save([path file],'Nb_points','Nb_channels','State_channels','Xscale','Yscale1','Yscale2','Yscale3','Yscale4','Offset_Yscale1','Offset_Yscale2','Offset_Yscale3','Offset_Yscale4','Trigger_Start','Trigger_Level1','Trigger_Level2','Trigger_Level3','Trigger_Level4');
      end
      cd(root);
    end
    function restore_config(obj)     
      [file,path] = uigetfile;
      tmp = matfile([path file]);
        obj.Nb_points = tmp.Nb_points;
        obj.Nb_channels = tmp.Nb_channels;
        obj.State_channels = tmp.State_channels;
        obj.Xscale = tmp.Xscale;
      for ii=1:obj.Nb_channels
        eval(['obj.Yscale',num2str(ii),' = ','tmp.Yscale',num2str(ii),';']);
        eval(['obj.Offset_Yscale',num2str(ii),' = ','tmp.Offset_Yscale',num2str(ii),';']);
        eval(['obj.Trigger_Level',num2str(ii),' = ','tmp.Trigger_Level',num2str(ii),';']);
      end
      obj.Trigger_Start = tmp.Trigger_Start;
    end
    function Display(obj)
        disp(['Nb_points : ',num2str(obj.Nb_points)]);
        disp(['Xscale : ',num2str(obj.Xscale),' s']);
        for ii=1:obj.Nb_channels
            if(obj.State_channels(ii) == 1) 
                disp(['Yscale1 : ',num2str(eval(['obj.Yscale',num2str(ii)])),' V/div']);
                disp(['Yscale2 : ',num2str(eval(['obj.Pt_Yscale',num2str(ii)])),' V/pt']);
            end
        end
    end
    function parameters=config(obj)     
      parameters.Nb_points = obj.Nb_points;
      parameters.Nb_channels = obj.Nb_channels;
      parameters.State_channels = obj.State_channels;
      parameters.Xscale = obj.Xscale;
      parameters.Trigger_Start = obj.Trigger_Start;
      for ii=1:obj.Nb_channels
        eval(['parameters.Yscale',num2str(ii),' = ','obj.Yscale',num2str(ii),';']);
        eval(['parameters.Offset_Yscale',num2str(ii),' = ','obj.Offset_Yscale',num2str(ii),';']);
        eval(['parameters.Trigger_Level',num2str(ii),' = ','obj.Trigger_Level',num2str(ii),';']);
      end
    end
    function delete(obj)
        obj.close_communication;
    end
  end  
end

