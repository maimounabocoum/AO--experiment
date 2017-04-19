classdef Analyseur < Measurement_tool
  %ANALYSEUR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Nb_points; % Nb points
    Start_frequency;
    Stop_frequency;
    Frequency;
    Marker_frequency;
    Reference_level;
    Average;
    Impedance;
    Mode;
  end
  
  methods
    function obj=Analyseur(info1,info2,info3,info4)
      obj = obj@Measurement_tool(info1,info2,info3,info4);
      init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
      obj = init(obj);
    end
    function obj = init_Analyseur_ROHDE_SCHWARZ_ZVL(obj)
      obj.open_communication;
      obj.Marker_frequency = (obj.Start_frequency+obj.Stop_frequency)/2;
      obj.Nb_points = 2001;
      % fprintf(obj.tool,['*RST;*CLS']);
    end
    function obj = set.Nb_points(obj,nb_points)
      obj.close_communication;
      set(obj.tool, 'InputBufferSize', 20*nb_points); %20 bits
      obj.open_communication;
      fprintf(obj.tool,['SENS1:SWEEP:POINTS ' num2str(nb_points) '; *WAI']);
    end
    function nb_points = get.Nb_points(obj)
      fprintf(obj.tool,['SENS1:SWEEP:POINTS?; *WAI']);
      nb_points = str2num(fscanf(obj.tool));
      if (get(obj.tool, 'InputBufferSize') ~= nb_points*20)
        obj.Nb_points = nb_points;
      end
    end
    function frequency = get.Frequency(obj)
      frequency = (obj.Start_frequency + [0:obj.Nb_points-1]*(obj.Stop_frequency-obj.Start_frequency)/obj.Nb_points).';
    end
    function obj = set.Frequency(obj,frequency)
      warning(['Command not available']);
    end    
    function obj = set.Start_frequency(obj,start_frequency)
        fprintf(obj.tool,['SENS1:FREQ:STAR ' num2str(start_frequency) 'Hz; *WAI']);
    end
    function start_frequency = get.Start_frequency(obj)
        fprintf(obj.tool,['SENS1:FREQ:STAR?; *WAI']);
        start_frequency = str2num(fscanf(obj.tool));
    end
    function obj = set.Stop_frequency(obj,stop_frequency)
        fprintf(obj.tool,['SENS1:FREQ:STOP ' num2str(stop_frequency) 'Hz; *WAI']);
    end
    function stop_frequency = get.Stop_frequency(obj)
        fprintf(obj.tool,['SENS1:FREQ:STOP?; *WAI']);
        stop_frequency = str2num(fscanf(obj.tool));
    end
    function obj = set.Reference_level(obj,reference_level)
        fprintf(obj.tool,['SOUR1:POW ' num2str(reference_level) 'dBm; *WAI']);
    end
    function reference_level = get.Reference_level(obj)
        fprintf(obj.tool,['SOUR1:POW?; *WAI']);
        reference_level = str2num(fscanf(obj.tool));
    end
    function obj = set.Marker_frequency(obj,marker_frequency)
        fprintf(obj.tool,['CALC1:MARK ON; *WAI']);
        fprintf(obj.tool,['CALC1:MARK1:X ' num2str(marker_frequency) 'Hz; *WAI']);
        fprintf(obj.tool,['CALC1:MARK2 ON; *WAI']);
        fprintf(obj.tool,['CALC1:MARK2:X ' num2str(marker_frequency) 'Hz; *WAI']);
%         zvl_cmd(obj.tool,'AVERAGE ON; *WAI','');
%         zvl_cmd(obj.tool,'CALC1:PAR:SDEF "TRC2", "Z-S11"; *WAI','');
%         zvl_cmd(obj.tool,'CALC1:FORM IMAG; *WAI','');
%         zvl_cmd(obj.tool,'FORM ASCII; FORM:DEXP:SOURCE FDAT; *WAI','');
%         zvl_cmd(obj.tool,'DISP:WIND1:TRAC2:FEED "TRC2"; *WAI','');
    end
    function marker_frequency = get.Marker_frequency(obj)
        fprintf(obj.tool,['CALC1:MARK1:X?; *WAI']);
        marker_frequency = str2num(fscanf(obj.tool));
    end
    function obj = set.Mode(obj,mode)
        switch mode
            case 'S11'
                fprintf(obj.tool,'CALC1:PAR:MEAS "TRC1", "Z-S11"; *WAI');
                fprintf(obj.tool,'CALC1:FORM REAL; *WAI');
                fprintf(obj.tool,'FORM ASCII; FORM:DEXP:SOURCE FDAT; *WAI');
                fprintf(obj.tool,'CALC1:PAR:MEAS "TRC2", "Z-S11"; *WAI');
                fprintf(obj.tool,'CALC1:FORM IMAG; *WAI');
                fprintf(obj.tool,'FORM ASCII; FORM:DEXP:SOURCE FDAT; *WAI');
            case 'S12'
                fprintf(obj.tool,'CALC1:PAR:MEAS "TRC1", "Z-S12"; *WAI');
                fprintf(obj.tool,'CALC1:FORM REAL; *WAI');
                fprintf(obj.tool,'FORM ASCII; FORM:DEXP:SOURCE FDAT; *WAI');
                fprintf(obj.tool,'CALC1:PAR:MEAS "TRC2", "Z-S12"; *WAI');
                fprintf(obj.tool,'CALC1:FORM IMAG; *WAI');
                fprintf(obj.tool,'FORM ASCII; FORM:DEXP:SOURCE FDAT; *WAI');
        end
    end
%     function mode = get.Mode(obj)
%         fprintf(obj.tool,['CALC1:MARK1:X?; *WAI']);
%         marker_frequency = str2num(fscanf(obj.tool));
%     end
    function impedance = get.Impedance(obj)
%         if obj.Average >= 1 % average
%           %   Success = fprintf(obj.tool,'*OPC?; *WAI'); pause (1); fscanf(obj.tool) % operation completed ?
%           %   Success = fprintf(obj.tool,'SENS1:SWEEP:TIME?; *WAI'); pause (1); fscanf(obj.tool) % ne marche pas
%           %   fprintf(obj.tool,'*SWEEP:TIME?; *WAI'); pause (1); fscanf(obj.tool) % ne marche pas
%           averageTime=analyzer.average_count/2; % estimation
%           fprintf('Waiting %gs since average count=%i\n',averageTime,analyzer.average_count);
%           pause (averageTime);
        fprintf(obj.tool,'CALC1:MARK:COUPLED ON; *WAI');
        fprintf(obj.tool,'INITIATE:CONTINUOUS ON; *WAI'); pause(0.5); % single sweep
        %% trace 1 acquisition
        pause(1.5);
        fprintf(obj.tool,'CALC1:PARAMETER:SELECT "TRC1"; *WAI');
        fprintf(obj.tool,'CALC1:DATA? FDAT; *WAI');
        IMs=fscanf(obj.tool); impedance(:,1)=sscanf(IMs,'%g,');
        % trace 2 acquisition
        pause(1.5);
        fprintf(obj.tool,'CALC1:PARAMETER:SELECT "TRC2"; *WAI');
        fprintf(obj.tool,'CALC1:DATA? FDAT; *WAI');
        IMs=fscanf(obj.tool); impedance(:,2)=sscanf(IMs,'%g,');        
    end
    function obj = set.Average(obj,average)
        fprintf(obj.tool,['AVERAGE:COUNT ' num2str(average) '; *WAI']);
    end
    function delete(obj)
        obj.close_communication;
    end
  end
end

