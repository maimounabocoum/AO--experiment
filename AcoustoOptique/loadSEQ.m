function loadSEQ(hf)


        % common values definition, A0.val : index 1 for value to
        % initialize
        AO.Volt(AO.val)         = str2double(get(VoltEdit,'string'))      ;
        AO.FreqSonde(AO.val)    = str2double(get(FreqEdit,'string'))      ;
        AO.NbHemicycle(AO.val)  = str2double(get(HemicycleEdit,'string')) ;      
        AO.NTrig(AO.val)        = str2double(get(NtrigEdit,'string'))     ;
        AO.Prof(AO.val)         = str2double(get(USDepthEdit,'string'))   ;

         switch get(ScanEdit,'value');
             case 1 % focused wave
                 
                 AO.X0(AO.val)          = str2double(get(X0Edit,'string'));
                 AO.Foc                 = str2double(get(FocEdit,'string'));
                 AO.ScanLength(AO.val)  = str2double(get(WidthXEdit,'string'));
                 
                [AO.SEQ,AO.Param] = AOSeqInit_FOC(AO);
                 
             case 2 % plane waves
%                 AO.AlphaM(AO.val)   = str2double(get(AlphaEdit,'string'));
%                 AO.dA(AO.val)       = str2double(get(dAEdit,'string'));
%                 AO.ScanLength(AO.val)  = str2double(get(WidthXEdit,'string'));
%                 
%                 [AO.SEQ,AO.Param] = AOSeqInit_OP( AO );
%                 
             case 3 % structured plane waves
%                 AO.AlphaM(AO.val)   = str2double(get(AlphaEdit,'string'));
%                 AO.dA(AO.val)       = str2double(get(dAEdit,'string'));
%                 AO.Np               = get(NphaseEdit,'value');
%                 AO.Nphase           = NN(AO.Np);
%                 AO.freqx            = str2double(get(freqxEdit,'string'));
%                 
%                 [AO.SEQ,AO.Param] = AOSeqInit_STRUCT( AO );
%                 [AO.SEQ,AO.Param] = AOSeqInit_STRUCT2( AO );
         end
        
        set(AO.LOADED,'visible','on')
        set(AO.start,'enable','on','string','Start Sequence')
        set(AO.SREdit,'enable','on')
        set(AO.RangeEdit,'enable','on')
        guidata(hf,AO)
                if FilterIndex
                    load([dir filename],'CP');
                    set(PathEdit,'string',filename)
                    
                    AO.Volt(AO.val)         = CP.ImgVoltage;
                    AO.FreqSonde(AO.val)    = CP.TwFreq;
                    AO.NbHemicycle(AO.val)  = CP.NbHcycle;
                    
                    AO.Foc                  = CP.PosZ;
                    AO.X0(AO.val)           = CP.PosX;
                    AO.ScanLength(AO.val)   = CP.ScanLength;
                    
                    AO.Prof(AO.val)  = CP.Prof;
                    AO.NTrig(AO.val) = CP.Repeat;
                end
                
            case 2
                [filename,dir,FilterIndex] = uigetfile('D:\Codes Matlab\AcoustoOptique\SEQdir\SEQ_OP*.mat','Select a sequence');
                
                if FilterIndex
                    load([dir filename],'UF');
                    set(PathEdit,'string',filename)
                    
                    AO.Volt(AO.val)         = UF.ImgVoltage;
                    AO.FreqSonde(AO.val)    = UF.TwFreq;
                    AO.NbHemicycle(AO.val)  = UF.NbHcycle;
                    
                    AO.AlphaM(AO.val)   = UF.AlphaM;
                    AO.dA(AO.val)       = UF.dA;
                    
                    AO.Prof(AO.val)  = UF.Prof;
                    AO.NTrig(AO.val) = UF.Repeat;
                end
                
            case 3
                [filename,dir,FilterIndex] = uigetfile('D:\Codes Matlab\AcoustoOptique\SEQdir\SEQ_STR*.mat','Select a sequence');
                
                if FilterIndex
                    load([dir filename],'US');
                    set(PathEdit,'string',filename)
                    
                    AO.Volt(AO.val)         = US.ImgVoltage;
                    AO.FreqSonde(AO.val)    = US.TwFreq;
                    AO.NbHemicycle(AO.val)  = US.NbHcycle;
                    
                    AO.AlphaM(AO.val)   = US.AlphaM;
                    AO.dA(AO.val)       = US.dA;
                    
                    AO.Nphase           = US.Nphase;
                    AO.Np               = find(NN == AO.Nphase);
                    
                    AO.Prof(AO.val)  = US.Prof;
                    AO.NTrig(AO.val) = US.Repeat;
                end
                
        end
        
        set(VoltEdit,'string',AO.Volt(AO.val))
        set(FreqEdit,'string',AO.FreqSonde(AO.val))
        set(HemicycleEdit,'string',AO.NbHemicycle(AO.val))
        
        set(FocEdit,'string',AO.Foc)
        set(AlphaEdit,'string',AO.AlphaM(AO.val))
        set(X0Edit,'string',AO.X0(AO.val))
        set(dAEdit,'string',AO.dA(AO.val))
        set(WidthXEdit,'string',AO.ScanLength(AO.val))
        set(freqxEdit,'string',AO.freqx)
        set(NphaseEdit,'value',AO.Np)
        
        set(USDepthEdit,'string',AO.Prof(AO.val))
        set(NtrigEdit,'string',AO.NTrig(AO.val))
        
    end


