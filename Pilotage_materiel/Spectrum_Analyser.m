classdef Spectrum_Analyser < Measurement_tool 
    %SPECTRUM_ANALYSER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        DeviceType;
        CenterFrequency;
        Span;
        Level;
%         FrameRate;
%         DbHeight;
        sweepLen;
        startFreq;
        binSize;
%         frameWidth;
%         frameHeight;
        RBW;
        Max;
        Min;
        Frequency;
        First_Frequency;
        Last_Frequency;
    end

    properties (Access = private)
        device_msg;
    end
    
    methods
        function obj=Spectrum_Analyser(info1,info2,info3,info4)
            obj = obj@Measurement_tool(info1,info2,info3,info4);
            init=str2func(['init_',obj.name,'_',obj.brand,'_',obj.ref]);
            obj = init(obj);
        end
        function obj = init_Spectrum_Analyser_SIGNALHOUND_USB_SA44B(obj)
            if ~libisloaded('sa_api')
                [notfound, warnings] = loadlibrary('sa_api', 'SignalHound_Driver\sa_api.h');
            else
                unloadlibrary('sa_api');
                [notfound, warnings] = loadlibrary('sa_api', 'SignalHound_Driver\sa_api.h');
            end
            
            %% Open Device 
            device = -1;
            pdevice = libpointer('int32Ptr',device);
            obj.device_msg = calllib('sa_api','saOpenDevice',pdevice);
            obj.tool = get(pdevice,'Value');
            clear pdevice
            if ~strcmpi(obj.device_msg,'saNoError')
                warndlg('This is not connected','!! Warning !!');
            end
            
            %%Check device Type
            deviceType = -1;
            pdeviceType = libpointer('int32Ptr',deviceType);
            obj.device_msg = calllib('sa_api','saGetDeviceType',obj.tool,pdeviceType);
            obj.DeviceType = get(pdeviceType,'Value');
            switch obj.DeviceType
                case 0
                   obj.DeviceType = 'None';
                case 1
                    obj.DeviceType = 'SA44';
                case 2
                    obj.DeviceType = 'SA44B';
                case 3
                    obj.DeviceType = 'SA124A';
                case 4
                    obj.DeviceType = 'SA124B';
                otherwise
                    obj.DeviceType = 'None';
            end
            
            %%Init Value
            obj.CenterFrequency = 123.3e6; 
            obj.Span = 100.0e3;
            obj.Level = -100;
            obj.RBW = 100;
%             obj.FrameRate = 30;
%             obj.DbHeight = 30;
            
        end
        function curve = measure(obj)         
            % Récupération data
            obj.sweepLen=0;
            psweepLen = libpointer('int32Ptr',obj.sweepLen);
            obj.startFreq = 0.0;
            pstartFreq = libpointer('doublePtr',obj.startFreq);
            obj.binSize = 0.0;
            pbinSize = libpointer('doublePtr',obj.binSize);
            calllib('sa_api','saQuerySweepInfo',obj.tool, psweepLen, pstartFreq, pbinSize);
            obj.sweepLen=get(psweepLen,'Value');
            obj.startFreq=get(pstartFreq,'Value');
            obj.binSize=get(pbinSize,'Value');
            %%
            % Allocate memory for the sweep and frame
            obj.Max = zeros(get(psweepLen,'Value'),1,'single');
            pMax = libpointer('singlePtr',obj.Max);
            obj.Min = zeros(get(psweepLen,'Value'),1,'single');
            pMin = libpointer('singlePtr',obj.Min);
            startIndex = -1;
            pstartIndex = libpointer('int32Ptr',startIndex);
            stopIndex = -1;
            pstopIndex = libpointer('int32Ptr',stopIndex);
            
            %%
%             while(get(pstopIndex,'Value') < obj.sweepLen)
%                 calllib('sa_api','saGetPartialSweep_32f',obj.tool, pMin, pMax,pstartIndex,pstopIndex);
%                 disp('Measuring...');
%             end

            calllib('sa_api','saGetSweep_32f',obj.tool, pMin, pMax);
            obj.Max = get(pMax,'Value');
            obj.Min = get(pMin,'Value');
            curve = obj.Max;
            
            obj.First_Frequency = single(obj.startFreq);
            obj.Last_Frequency = single(obj.startFreq + obj.sweepLen * obj.binSize);
            obj.Frequency = single(obj.startFreq + (obj.binSize/2) + [0:obj.sweepLen-1] * obj.binSize);
            
            clear psweepLen pstartFreq pbinSize pMax pMin pstartIndex pstopIndex          
            
        end
        function startAcq(obj)
            calllib('sa_api','saConfigCenterSpan',obj.tool, obj.CenterFrequency, obj.Span);
            calllib('sa_api','saConfigAcquisition',obj.tool, 1, 0);
            calllib('sa_api','saConfigLevel',obj.tool, obj.Level);
            calllib('sa_api','saConfigSweepCoupling',obj.tool, obj.RBW, obj.RBW, true);
            %calllib('sa_api','saConfigRealTime',obj.tool, obj.DbHeight, obj.FrameRate);
            pause(0.1);
            % Initialisation mesure
            calllib('sa_api','saInitiate',obj.tool, 0, 0);  %0 SA_SWEEPING %1 SA_REAL_TIME
        end
        function stopAcq(obj)
            %% Stop measurement
            calllib('sa_api','saAbort',obj.tool);
        end
        function delete(obj)
            %% Close Device
            calllib('sa_api','saCloseDevice',obj.tool);
        end
    end
end