classdef Scale < Measurement_tool
  %SCALE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(Constant)
    delay_command_tare = 0.5; % Increase this value in constructor if the commands are not taken into account
    delay_command_measure = 0.4;
  end
  
  properties
    Mass;
  end
  
  methods
    function obj=Scale(info1,info2,info3,info4)
      obj@Measurement_tool(info1,info2,info3,info4);
      init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
      obj = init(obj);
    end
    function obj = init_Scale_SARTORIUS_CPA423S(obj)
      set(obj.tool, 'Baudrate', 19200) ;       % Set the baud rate at the specific value, 19200
      set(obj.tool, 'Parity', 'Odd') ;         % Set parity as none
      set(obj.tool, 'Databits', 7) ;           % set the number of data bits
      set(obj.tool, 'StopBits', 1) ;           % set number of stop bits as 1
      set(obj.tool, 'Terminator', 'LF') ;      % set the terminator value to newline
      set(obj.tool, 'OutputBufferSize', 512) ; % Buffer for write operation, default it is 512
      set(obj.tool, 'InputBufferSize', 22) ;   % Input buffer 22
      set(obj.tool, 'FlowControl', 'none');    % No flow control
      obj.open_communication;
      obj.Tare();
      % fprintf(rfb, '%cK\r\n',27); % WEIGHT VERY STABLE
      % fprintf(rfb, '%cL\r\n',27); % WEIGHT STABLE
      % fprintf(rfb, '%cM\r\n',27); % WEIGHT INSTABLE
      % fprintf(rfb, '%cN\r\n',27); % WEIGHT VERY INSTABLE
      obj.Mass = 0;
    end
    function obj = init_Scale_SARTORIUS_QUINTIX3102(obj)
      set(obj.tool, 'InputBufferSize', 44) ;   % Input buffer 22
      obj.open_communication;
      obj.Tare();
      % fprintf(rfb, '%cK\r\n',27); % WEIGHT VERY STABLE
      % fprintf(rfb, '%cL\r\n',27); % WEIGHT STABLE
      % fprintf(rfb, '%cM\r\n',27); % WEIGHT INSTABLE
      % fprintf(rfb, '%cN\r\n',27); % WEIGHT VERY INSTABLE
      obj.Mass = 0;
    end
    function mass = get.Mass(obj)
      if strcmpi(obj.ref ,'CPA423S')
        fprintf(obj.tool, '%cP\r\n',27); % READ
        pause(obj.delay_command_measure);
        tmp = strtrim(fscanf(obj.tool));
        if strcmpi(tmp(1),'N')
          mass = str2double(tmp(11:16));
        else
          mass = 0;
        end
      else %if strcmpi(obj.ref ,'QUINTIX3102')
        tmp = [''];
        while(length(tmp)<15)
          flushinput(obj.tool);
          fprintf(obj.tool, '%cP\r\n',27);
          while(obj.tool.BytesAvailable<22)
          end
          fprintf(obj.tool, '%cP\r\n',27);
          tmp = strtrim(fscanf(obj.tool));
        end
        pos_delimiter = strfind(tmp,'.');
        mass = str2double(tmp(pos_delimiter-4:pos_delimiter+2));
        if strcmpi(tmp(7),'-')
          mass = -mass;
        end
      end
      obj.Mass = mass;
    end
    function Tare(obj)
      fprintf(obj.tool, '%cT\r\n',27);
      pause(obj.delay_command_tare);
    end
    function delete(obj)
        obj.close_communication;
    end
  end
end

