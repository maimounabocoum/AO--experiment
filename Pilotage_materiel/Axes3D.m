classdef Axes3D < Measurement_tool
    %3Axes Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        Id_axes = [1 2 3];     % X = 1, Y = 2, Z = 3
        MotV = [25 25 25];      % vitesses moteurs [mm/s]
        MotAcc = [100 100 100];  % accelerations moteurs [mm/s^2]
        MotDecc = [100 100 100]; % decelerations moteurs [mm/s^2]
    end
    
    properties
        X_position;
        Y_position;
        Z_position;
    end
    
    methods
        function obj=Axes3D(info1,info2,info3,info4)
            obj@Measurement_tool(info1,info2,info3,info4);
            init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
            init(obj);
        end
        function init_Axes3D_NEWPORT_ESP300(obj)
            obj.open_communication;
            pause(0.1);
            % Moteurs ON
            fprintf(obj.tool,['MO']);
            %% Controle des vitesses moteur
            for ii = 1:length(obj.Id_axes)
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'VA',num2str(obj.MotV(ii))]);
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'AC',num2str(obj.MotAcc(ii))]);
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'AG',num2str(obj.MotDecc(ii))]);
            end
        end
        function init_Axes3D_NEWPORT_ESP301(obj)
            obj.Id_axes = [1 2 3];
            obj.MotV = [25 25 10];      % vitesses moteurs [mm/s]
            obj.MotAcc = [100 100 20];  % accelerations moteurs [mm/s^2]
            obj.MotDecc = [100 100 20]; % decelerations moteurs [mm/s^2]
            set(obj.tool, 'Baudrate', 921600) ;       % Set the baud rate at the specific value, 19200
            %       set(obj.tool, 'Parity', 'None') ;         % Set parity as none
            %       set(obj.tool, 'Databits', 8) ;           % set the number of data bits
            %       set(obj.tool, 'StopBits', 1) ;           % set number of stop bits as 1
            set(obj.tool, 'Terminator', 'CR') ;      % set the terminator value to newline
            %       set(obj.tool, 'OutputBufferSize', 512) ; % Buffer for write operation, default it is 512
            %       set(obj.tool, 'InputBufferSize', 22) ;   % Input buffer 22
            %       set(obj.tool, 'FlowControl', 'none');    % No flow control
            open_communication(obj);
            pause(0.1);
            % Moteurs ON
            for ii = 1:length(obj.Id_axes)
                fprintf(obj.tool,[num2str(ii),'MO']);
            end
            %% Controle des vitesses moteur
            for ii = 1:length(obj.Id_axes)
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'VA',num2str(obj.MotV(ii))]);
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'AC',num2str(obj.MotAcc(ii))]);
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'AG',num2str(obj.MotDecc(ii))]);
            end
        end
        function init_Axes3D_NEWPORT_MM4006(obj)
            set(obj.tool, 'Baudrate', 19200) ;       % Set the baud rate at the specific value, 19200
            set(obj.tool, 'Parity', 'None') ;         % Set parity as none
            set(obj.tool, 'Databits', 8) ;           % set the number of data bits
            set(obj.tool, 'StopBits', 1) ;           % set number of stop bits as 1
            set(obj.tool, 'Terminator', 'CR') ;      % set the terminator value to newline
            %       set(obj.tool, 'OutputBufferSize', 512) ; % Buffer for write operation, default it is 512
            %       set(obj.tool, 'InputBufferSize', 22) ;   % Input buffer 22
            %       set(obj.tool, 'FlowControl', 'none');    % No flow control
            open_communication(obj);
            pause(0.1);
            % Moteurs ON
            fprintf(obj.tool,['MO']);
            %% Controle des vitesses moteur
            for ii = 1:length(obj.Id_axes)
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'VA',num2str(obj.MotV(ii))]);
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'AC',num2str(obj.MotAcc(ii))]);
                fprintf(obj.tool,[num2str(obj.Id_axes(ii)),'AG',num2str(obj.MotDecc(ii))]);
            end
        end
        function setHome(obj)
            dlgTitle    = 'Set Home';
            dlgQuestion = 'Are you sure to define Home at this position?';
            choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
            if choice=='Yes'
                fprintf(obj.tool,['DH']);
            end
        end
        function gotoHome(obj)
            dlgTitle    = 'Go to Home';
            dlgQuestion = 'Are you sure to go to X=0,Y=0 and Z=0?';
            choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'No');
            if choice=='Yes'
                fprintf(obj.tool,[num2str(obj.Id_axes(1)),'PA',num2str(0)]);
                fprintf(obj.tool,[num2str(obj.Id_axes(2)),'PA',num2str(0)]);
                fprintf(obj.tool,[num2str(obj.Id_axes(3)),'PA',num2str(0)]);
            end
        end
        function startMotor(obj)
            fprintf(obj.tool,['MO']);
        end
        function stopMotor(obj)
            fprintf(obj.tool,['MF']);
        end
        function obj = set.X_position(obj,x_position)
            obj.X_position = x_position;
            fprintf(obj.tool,['MO']);
            fprintf(obj.tool,[num2str(obj.Id_axes(1)),'PA',num2str(x_position)]);
        end
        function obj = set.Y_position(obj,y_position)
            obj.Y_position = y_position;
            fprintf(obj.tool,['MO']);
            fprintf(obj.tool,[num2str(obj.Id_axes(2)),'PA',num2str(y_position)]);
        end
        function obj = set.Z_position(obj,z_position)
            obj.Z_position = z_position;
            fprintf(obj.tool,['MO']);
            fprintf(obj.tool,[num2str(obj.Id_axes(3)),'PA',num2str(z_position)]);
        end
        function x_position = get.X_position(obj)      
            fprintf(obj.tool,['1TP?']);
            if strcmpi(obj.ref,'MM4006')
                tmp = fscanf(obj.tool);
                x_position = str2double(tmp(4:end));     
            else
                x_position = str2double(fscanf(obj.tool));
            end
        end
        function y_position = get.Y_position(obj)
            fprintf(obj.tool,['2TP?']);
            if strcmpi(obj.ref,'MM4006')
                tmp = fscanf(obj.tool);
                y_position = str2double(tmp(4:end));     
            else
                y_position = str2double(fscanf(obj.tool));
            end
        end
        function z_position = get.Z_position(obj)
            fprintf(obj.tool,['3TP?']);
            if strcmpi(obj.ref,'MM4006')
                tmp = fscanf(obj.tool);
                z_position = str2double(tmp(4:end));     
            else
                z_position = str2double(fscanf(obj.tool));
            end
        end
        function delete(obj)
            obj.close_communication;
        end
    end
end

