classdef Measurement_tool < handle
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        brand;
        ref;
        protocol;
        address;
        tool;
    end
    
    methods
        function obj=Measurement_tool(info1,info2,info3,info4)
            obj.brand = upper(info1);
            obj.ref = upper(info2);
            obj.protocol = upper(info3);
            obj.address = info4;
            switch obj.brand
                case 'NEWPORT'
                    switch obj.ref
                        case 'ESP300'
                            obj.name = 'Axes3D';
                        case 'ESP301'
                            obj.name = 'Axes3D';
                        case 'MM4006'
                            obj.name = 'Axes3D';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'RIGOL'
                    switch obj.ref
                        case 'DG1022'
                            obj.name = 'GBF';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'ROHDE_SCHWARZ'
                    switch obj.ref
                        case 'ZVL'
                            obj.name = 'Analyseur';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'SARTORIUS'
                    switch obj.ref
                        case 'CPA423S'
                            obj.name = 'Scale';
                        case 'QUINTIX3102'
                            obj.name = 'Scale';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'TEKTRONIX'
                    switch obj.ref
                        case 'DPO3034'
                            obj.name = 'Oscillo';
                        case 'DPO2034'
                            obj.name = 'Oscillo';
                        case 'AFG3101C'
                            obj.name = 'GBF';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'AGILENT'
                    switch obj.ref
                        case '33220A'
                            obj.name = 'GBF';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'HOMEMADE'
                    switch obj.ref
                        case 'MUX1'
                            obj.name = 'Multiplexeur';
                        case 'MUX2'
                            obj.name = 'Multiplexeur';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'TIEPIE'
                    switch obj.ref
                        case 'HS5'
                            obj.name = 'TiePie';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'SIGNALHOUND'
                    switch obj.ref
                        case 'USB_SA44B'
                            obj.name = 'Spectrum_Analyser';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                case 'ARDUINO'
                    switch obj.ref
                        case 'UNO'
                            obj.name = 'arduino';
                        otherwise
                            warndlg('This product doesn''t exist','!! Warning !!');
                    end
                otherwise
                    warndlg('This product doesn''t exist','!! Warning !!');
            end
            % Init communication
            if strcmpi(obj.brand,'RIGOL') || strcmpi(obj.brand,'ROHDE_SCHWARZ') || strcmpi(obj.brand,'TEKTRONIX') || strcmpi(obj.brand,'AGILENT')
                obj.tool = visa('ni', [obj.protocol,'0::',obj.address,'::INSTR']);
            end
            if strcmpi(obj.brand,'NEWPORT') || strcmpi(obj.brand,'SARTORIUS') || strcmpi(obj.brand,'HOMEMADE') || strcmpi(obj.brand,'ARDUINO')
                obj.tool = serial([obj.protocol,obj.address]);
            end
            if strcmpi(obj.brand,'TIEPIE') || strcmpi(obj.brand,'SIGNALHOUND')
                
            end
        end
        function open_communication(obj)
            fopen(obj.tool);
        end
        function close_communication(obj)
            fclose(obj.tool);
        end
    end
end

