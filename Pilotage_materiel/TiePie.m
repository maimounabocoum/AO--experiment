classdef TiePie < Measurement_tool
  %OSCILLO Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Nb_points; % Nb points on xscale
    Nb_channels; % Nb of channels used
    Resolution;
    State_channels;
    Acquisition_time;
    Sample_Frequency;
    Yscale1; %[V] (0.2, 0.4, 0.8, 2, 4, 8, 20, 40, 80)
    Yscale2; %[V] (0.2, 0.4, 0.8, 2, 4, 8, 20, 40, 80)
    Yscale3;
    Yscale4;
    Pt_Yscale1;
    Pt_Yscale2;
    Pt_Yscale3;
    Pt_Yscale4;
    Trigger_Level1;
    Trigger_Level2;
    Trigger_Level3;
    Trigger_Level4;
    Trigger_EXT1;
    Trigger_Start;
    Trigger_Armed;
    
    Frequency; %Values of channel 1 and 2
    Shape; %Shape of channel 1 and 2
    Vpp; % Voltage peak to peak of channel 1 and 2
    Voffset; % Offset voltage of channel 1 and 2
    Phase; % Phase of channel 1 and 2
    State; % State of channel 1 and 2
    BurstCount;
    
  end
  
  methods
    function obj=TiePie(info1,info2,info3,info4)
      obj = obj@Measurement_tool(info1,info2,info3,info4);
      init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
      obj = init(obj);
    end
    function obj = init_TiePie_TIEPIE_HS5(obj)
      % Open LibTiePie and display library info if not yet opened:
      import LibTiePie.Const.PID
      import LibTiePie.Const.TIID
      import LibTiePie.Const.TOID
      import LibTiePie.Enum.*
      % Open LibTiePie:
      LibTiePie = LibTiePie.Library;
      
      % Search for devices:
      LibTiePie.DeviceList.update();
      
      if (LibTiePie.DeviceList.Count < str2num(obj.address))
          error(['Adress TiePie is not accessible']);
      end
      
      clear scp;
      clear gen;
      item = LibTiePie.DeviceList.getItemByIndex((str2num(obj.address)-1));
      if item.canOpen(DEVICETYPE.OSCILLOSCOPE) && item.canOpen(DEVICETYPE.GENERATOR)
          scp = item.openOscilloscope();
          if ismember(MM.BLOCK, scp.MeasureModes)
            gen = item.openGenerator();
          else
            error(['GBF not avalaible']);
          end
      end
      
      clear item
      obj.tool.scp = scp;
      obj.tool.gen = gen;
      clear scp;
      clear gen; 
      
      %if exist('obj.tool.scp', 'var')
        % Set measure mode:
        obj.tool.scp.MeasureMode = MM.BLOCK;

        % Set sample frequency:
        obj.tool.scp.SampleFrequency = 1e6; % 1 MHz

        % Set record length:
        obj.tool.scp.RecordLength = 10000; % 10000 Samples

        % Set pre sample ratio:
        obj.tool.scp.PreSampleRatio = 0; % 0 %

        % For all channels:
        for ch = obj.tool.scp.Channels
            % Enable channel to measure it:
            ch.Enabled = true;

            % Set range:
            ch.Range = 8; % 8 V

            % Set coupling:
            ch.Coupling = CK.DCV; % DC Volt

            % Release reference:
            clear ch;
            
            % Set trigger off
            ch.Trigger.Enabled = false;
        end

        % Set trigger timeout:
        obj.tool.scp.TriggerTimeOut = -1; % infinite
        
        % Disable all channel trigger sources:
        for ch = obj.tool.scp.Channels
            ch.Trigger.Enabled = false;
            clear ch;
        end
      obj.Nb_channels = 2;
    end
    
    %% Oscillo
    function obj = set.Nb_points(obj,nb_points)
      if (nb_points <= obj.tool.scp.RecordLengthMax)
        obj.tool.scp.RecordLength = nb_points;
      else
        warning(['Nb_points limited to ' num2str(obj.tool.scp.RecordLengthMax/length(find(obj.State_channels==1)))])
        obj.tool.scp.RecordLength = obj.tool.scp.RecordLengthMax; 
      end
      obj.Nb_points = obj.tool.scp.RecordLength;
    end
    function nb_points = get.Nb_points(obj)
       nb_points = obj.tool.scp.RecordLength;
    end
    function resolution = get.Resolution(obj)
      resolution = obj.tool.scp.Resolution;
    end
    function obj = set.Resolution(obj,resolution)
      if ~(resolution == round(resolution))
          error(['The resolution must be a integer']);
      end
      if ~(length(find(resolution == obj.tool.scp.Resolutions))==1)
          error(['Available values are 8,12,14,16']);
      end
      obj.tool.scp.Resolution = resolution;
    end    
    function obj = set.Yscale1(obj,yscale)
      obj.tool.scp.Channels(1).Range = yscale;
    end
    function yscale1 = get.Yscale1(obj)
      yscale1 = obj.tool.scp.Channels(1).Range;
    end
    function obj = set.Yscale2(obj,yscale)
      obj.tool.scp.Channels(2).Range = yscale;
    end
    function yscale2 = get.Yscale2(obj)
      yscale2 = obj.tool.scp.Channels(2).Range;
    end
    function obj = set.Yscale3(obj,yscale)
      obj.tool.scp.Channels(3).Range = yscale;
    end
    function yscale3 = get.Yscale3(obj)
      yscale3 = obj.tool.scp.Channels(3).Range;
    end
    function obj = set.Yscale4(obj,yscale)
      obj.tool.scp.Channels(4).Range = yscale;
    end
    function yscale4 = get.Yscale4(obj)
      yscale4 = obj.tool.scp.Channels(4).Range;
    end
    function obj = set.Acquisition_time(obj,acq_time)
      error('command not available');
    end
    function acq_time = get.Acquisition_time(obj)
      acq_time = obj.tool.scp.RecordLength/obj.tool.scp.SampleFrequency;
    end
    function obj = set.Sample_Frequency(obj,sample_freq)
      if (sample_freq <= obj.tool.scp.SampleFrequencyMax)
        obj.tool.scp.SampleFrequency = sample_freq;
      else
        warning(['Sample frequency limited to ' num2str(obj.tool.scp.RecordLengthMax/length(find(obj.State_channels==1)))])
        obj.tool.scp.SampleFrequency = obj.tool.scp.SampleFrequencyMax;
      end
      obj.Sample_Frequency = obj.tool.scp.SampleFrequency;
    end
    function sample_freq = get.Sample_Frequency(obj)
      sample_freq = obj.tool.scp.SampleFrequency;
    end
    function pt_yscale1 = get.Pt_Yscale1(obj)
      if(obj.State_channels(1)==1)
        fprintf(obj.tool.scp,['DATA:SOURCE CH' num2str(1)]);
        fprintf(obj.tool.scp,'WFMOutpre:YMUlt?');  % LSB sur l'axe y
        pt_yscale1 = str2num(fscanf(obj.tool.scp));
      else
        pt_yscale1 =0;
      end
    end
    function pt_yscale2 = get.Pt_Yscale2(obj)
      if(obj.State_channels(2)==1)
        fprintf(obj.tool.scp,['DATA:SOURCE CH' num2str(2)]);
        fprintf(obj.tool.scp,'WFMOutpre:YMUlt?');  % LSB sur l'axe y
        pt_yscale2 = str2num(fscanf(obj.tool.scp));
      else
        pt_yscale2 =0;
      end
    end
    function pt_yscale3 = get.Pt_Yscale3(obj)
      if(obj.State_channels(3)==1)
        fprintf(obj.tool.scp,['DATA:SOURCE CH' num2str(3)]);
        fprintf(obj.tool.scp,'WFMOutpre:YMUlt?');  % LSB sur l'axe y
        pt_yscale3 = str2num(fscanf(obj.tool.scp));
      else
        pt_yscale3 =0;
      end
    end
    function pt_yscale4 = get.Pt_Yscale4(obj)
      if(obj.State_channels(4)==1)
        fprintf(obj.tool.scp,['DATA:SOURCE CH' num2str(4)]);
        fprintf(obj.tool.scp,'WFMOutpre:YMUlt?');  % LSB sur l'axe y
        pt_yscale4 = str2num(fscanf(obj.tool.scp));
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
      fprintf(obj.tool.scp,['TRIGger:A:LEVel:CH',num2str(1),'?']);
      trigger_level = str2num(fscanf(obj.tool.scp));
    end
    function trigger_level = get.Trigger_Level2(obj)
      fprintf(obj.tool.scp,['TRIGger:A:LEVel:CH',num2str(2),'?']);
      trigger_level = str2num(fscanf(obj.tool.scp));
    end
    function trigger_level = get.Trigger_Level3(obj)
      fprintf(obj.tool.scp,['TRIGger:A:LEVel:CH',num2str(3),'?']);
      trigger_level = str2num(fscanf(obj.tool.scp));
    end
    function trigger_level = get.Trigger_Level4(obj)
      fprintf(obj.tool.scp,['TRIGger:A:LEVel:CH',num2str(4),'?']);
      trigger_level = str2num(fscanf(obj.tool.scp));
    end
    function obj = set.Trigger_Level1(obj,trigger_level)
      % Disable all channel trigger sources:
      for ch = obj.tool.scp.Channels
        ch.Trigger.Enabled = false;
        clear ch;
      end
      % Enable trigger source:
      obj.tool.scp.Channels(1).Trigger.Enabled = true; % Ch 1
      % Kind:
      obj.tool.scp.Channels(1).Trigger.Kind = 1; % Rising edge
      % Level:
      obj.tool.scp.Channels(1).Trigger.Levels(1) = trigger_level; %
      % Hysteresis:
      obj.tool.scp.Channels(1).Trigger.Hystereses(1) = 0.05; % 5 %
    end
    function obj = set.Trigger_Level2(obj,trigger_level)
      % Disable all channel trigger sources:
      for ch = obj.tool.scp.Channels
        ch.Trigger.Enabled = false;
        clear ch;
      end
      % Enable trigger source:
      obj.tool.scp.Channels(2).Trigger.Enabled = true; % Ch 1
      % Kind:
      obj.tool.scp.Channels(2).Trigger.Kind = 1; % Rising edge
      % Level:
      obj.tool.scp.Channels(2).Trigger.Levels(1) = trigger_level; %
      % Hysteresis:
      obj.tool.scp.Channels(2).Trigger.Hystereses(1) = 0.05; % 5 %
    end
    function obj = set.Trigger_Level3(obj,trigger_level)
      % Disable all channel trigger sources:
      for ch = obj.tool.scp.Channels
        ch.Trigger.Enabled = false;
        clear ch;
      end
      % Enable trigger source:
      obj.tool.scp.Channels(3).Trigger.Enabled = true; % Ch 1
      % Kind:
      obj.tool.scp.Channels(3).Trigger.Kind = 1; % Rising edge
      % Level:
      obj.tool.scp.Channels(3).Trigger.Levels(1) = trigger_level; %
      % Hysteresis:
      obj.tool.scp.Channels(3).Trigger.Hystereses(1) = 0.05; % 5 %
    end
    function obj = set.Trigger_Level4(obj,trigger_level)
      % Disable all channel trigger sources:
      for ch = obj.tool.scp.Channels
        ch.Trigger.Enabled = false;
        clear ch;
      end
      % Enable trigger source:
      obj.tool.scp.Channels(4).Trigger.Enabled = true; % Ch 1
      % Kind:
      obj.tool.scp.Channels(4).Trigger.Kind = 1; % Rising edge
      % Level:
      obj.tool.scp.Channels(4).Trigger.Levels(1) = trigger_level; %
      % Hysteresis:
      obj.tool.scp.Channels(4).Trigger.Hystereses(1) = 0.05; % 5 %
    end
    function obj = set.Trigger_EXT1(obj,trigger_level)
        if(trigger_level)
          obj.tool.scp.TriggerInputs(1).Enabled=1;
          obj.tool.scp.TriggerInputs(1).Kind=1; % rising=1, falling=2 (kinds for EXTi trigger inputs)
        else
          obj.tool.scp.TriggerInputs(1).Enabled=0;
        end
    end
    function obj = set.Trigger_Armed(obj,trig)
      if (trig == 1 )%|| strcmpi(trig,'ON'))
        % Start measurement:
        obj.tool.scp.start();
      else
         warning(['Command not valid']);
      end
    end
    function trig = get.Trigger_Armed(obj)
        if(obj.tool.scp.IsRunning)
            trig = 'Armed';
        elseif((obj.tool.scp.IsTriggered))
            trig = 'Value available';
        else
            trig = 'Is waiting instruction';
        end
    end
    function obj = set.Trigger_Start(obj,trig_start)
        fprintf(obj.tool.scp,['HORizontal:DELay:TIMe ' num2str(trig_start)]);
    end
    function trig_start = get.Trigger_Start(obj)
      trig_start = 1;
    end
    function obj = set.State_channels(obj,State_channels)
      if (length(State_channels)==obj.Nb_channels)
        for ii=1:obj.Nb_channels
          if (State_channels(ii)==1)
            obj.tool.scp.Channels(ii).Enabled = true;
          else
            obj.tool.scp.Channels(ii).Enabled = false;
          end
        end
      end
    end
    function State_Channels = get.State_channels(obj)
      for ii=1:obj.Nb_channels
        State_Channels(ii) = obj.tool.scp.Channels(ii).Enabled;
      end
    end
    function data_channels = Data_channels(obj,id_channel)   
        % Wait for measurement to complete:
        if (obj.tool.scp.IsDataReady)
            % Get data:
            arData = obj.tool.scp.getData;

            if (exist('id_channel', 'var'))
                if(obj.State_channels(id_channel) == 1)
                    data_channels = arData(:,1);
                else
                    warning(['Channel not activated']);
                end
            else
                data_channels = single(zeros(obj.Nb_channels,obj.Nb_points));
                for id=1:obj.Nb_channels
                    if(obj.State_channels(id) == 1) 
                        data_channels(id,:) = arData(:,id);
                    end
                end
            end
        else
            warning(['Data not available (trigger, delay to acquire)'])
            data_channels = 0;
        end
    end
    
    %% GBF
    function obj = set.Frequency(obj,frequency)
      obj.tool.gen.Frequency = frequency;
    end
    function frequency = get.Frequency(obj)
      frequency = obj.tool.gen.Frequency;
    end
    function obj = set.Shape(obj,shape)
      import LibTiePie.Const.PID
      import LibTiePie.Const.TIID
      import LibTiePie.Const.TOID
      import LibTiePie.Enum.*
      if ischar(shape)
          switch shape
              case 'SINE'
                  obj.tool.gen.SignalType = ST.SINE;
              case 'TRIANGULAR'
                  obj.tool.gen.SignalType = ST.TRIANGLE;
              case 'SQUARE'
                  obj.tool.gen.SignalType = ST.SQUARE;
              case 'BURST_SINE'
                  obj.tool.gen.SignalType = ST.SINE;
                  obj.tool.gen.Mode = GM.BURST_COUNT;                  
              case 'BURST_TRIANGULAR'
                  obj.tool.gen.SignalType = ST.TRIANGLE;
                  obj.tool.gen.Mode = GM.BURST_COUNT;
              case 'BURST_SQUARE'
                  obj.tool.gen.SignalType = ST.SQUARE;
                  obj.tool.gen.Mode = GM.BURST_COUNT;
          end
      else
          error(['Available configuration are SINE, TRIANGULAR, SQUARE, BURST_SINE, BURST_TRIANGULAR, BURST_SQUARE']);
      end
    end
    function shape = get.Shape(obj)
      shape =  obj.tool.gen.SignalType;
    end
    function obj = set.Vpp(obj,vpp)
       obj.tool.gen.Amplitude = vpp/2;
    end
    function vpp = get.Vpp(obj)
      vpp = 2*obj.tool.gen.Amplitude;
    end
    function obj = set.Voffset(obj,voffset)
       obj.tool.gen.Offset = voffset;
    end
    function voffset = get.Voffset(obj)
      voffset = obj.tool.gen.Offset;
    end
    function obj = set.Phase(obj,phase)
      fprintf(obj.tool,['PHASe ',num2str(phase)]);
    end
    function phase = get.Phase(obj)
      phase = str2num(query(obj.tool,['PHASe?']));
    end
    function obj = set.BurstCount(obj,burstcount)
       obj.tool.gen.BurstCount = burstcount;
    end
    function burstcount = get.BurstCount(obj)
      burstcount = obj.tool.gen.BurstCount;
    end
    function obj = set.State(obj,state)
      if ischar(state)
        if strcmpi(state,'on')
            obj.tool.gen.stop();
            obj.tool.gen.OutputOn = false;
            obj.tool.gen.OutputOn = true;
            obj.tool.gen.start();
        elseif strcmpi(state,'off')
            obj.tool.gen.stop();
            obj.tool.gen.OutputOn = false;
        else
            error('command not valid');
        end
      else
        if state==1
            obj.tool.gen.stop();
            obj.tool.gen.OutputOn = false;
            obj.tool.gen.OutputOn = true;
            obj.tool.gen.start();
        elseif state==0
            obj.tool.gen.stop();
            obj.tool.gen.OutputOn = false;
        else
            error('command not valid');
        end
      end
    end
    function state = get.State(obj)
      tmp = obj.tool.gen.OutputOn;
      if tmp == 0 state = 'off'; 
      elseif tmp == 1 state = 'on'; end
    end
    
    %% Config 
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
    function delete(obj)
        
    end
  end
end