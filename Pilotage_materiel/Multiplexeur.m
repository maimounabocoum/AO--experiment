classdef Multiplexeur < Measurement_tool
  %MULTIPLEXEUR Summary of this class goes here
  %   Detailed explanation goes here
  
  properties(Constant)
    delay_command = 0.1;
  end
  
  properties
    Channel;
  end
  
  methods
    function obj=Multiplexeur(info1,info2,info3,info4)
      obj@Measurement_tool(info1,info2,info3,info4);
      init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
      obj = init(obj);
    end
    function obj = init_Multiplexeur_HOMEMADE_MUX1(obj)
      set(obj.tool, 'Baudrate', 4800) ;        % Set the baud rate at the specific value, 19200
      set(obj.tool, 'Parity', 'none') ;        % Set parity as none
      set(obj.tool, 'Databits', 8) ;           % set the number of data bits
      set(obj.tool, 'StopBits', 1) ;           % set number of stop bits as 1
      set(obj.tool, 'Terminator', 'LF') ;      % set the terminator value to newline
      set(obj.tool, 'OutputBufferSize', 512) ; % Buffer for write operation, default it is 512
      set(obj.tool, 'InputBufferSize', 22) ;   % Input buffer 22
      set(obj.tool, 'FlowControl', 'none');    % No flow control
      open_communication(obj);
    end
    function obj = init_Multiplexeur_HOMEMADE_MUX2(obj)
      set(obj.tool, 'Baudrate', 4800) ;        % Set the baud rate at the specific value, 19200
      set(obj.tool, 'Parity', 'none') ;        % Set parity as none
      set(obj.tool, 'Databits', 8) ;           % set the number of data bits
      set(obj.tool, 'StopBits', 1) ;           % set number of stop bits as 1
      set(obj.tool, 'Terminator', 'LF') ;      % set the terminator value to newline
      set(obj.tool, 'OutputBufferSize', 512) ; % Buffer for write operation, default it is 512
      set(obj.tool, 'InputBufferSize', 22) ;   % Input buffer 22
      set(obj.tool, 'FlowControl', 'none');    % No flow control
      open_communication(obj);
    end
    function obj = set.Channel(obj,channel)
      if channel>=1 && channel<=128
        fwrite(obj.tool, channel);
        pause(obj.delay_command);
        obj.Channel = channel;
      else
          warning(['Number not possible']);
      end
    end
    function channel = get.Channel(obj)
      channel = obj.Channel;
    end
    function delete(obj)
        obj.tool.close_communication;
    end
  end
end

