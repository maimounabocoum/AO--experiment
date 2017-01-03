function loadSEQ(hf)
% This function is a GUI part of Acousto-Optic GUI for loading US sequence

AO=guidata(hf);

%% Definition of window
USParamList = {'val','Volt','FreqSonde','NbHemicycle','NTrig','Prof',...
    'X0','Foc','ScanLength',...
    'AlphaM','dA'};
UnSetFields = USParamList(~isfield(AO,USParamList));

if ~isempty( UnSetFields )
    for ii = 1: length( UnSetFields )
        if strcmpi(UnSetFields{ii},'val')
            AO.( UnSetFields{ii} ) = 1;
        elseif any(strcmpi(UnSetFields{ii}, ...
                {'Volt','FreqSonde','NbHemicycle','NTrig','Prof'}))
            AO.( UnSetFields{ii} ) = [0 0];
        else
            AO.( UnSetFields{ii} ) = 0;
        end
    end
end

if ~AO.hlOpen % Initialize buttons only if the window has been closed
    %load sequence button
    LSEQ = uicontrol('Style', 'pushbutton',...
        'string', 'Load',...
        'Fontsize',14,...
        'units','normalized',...
        'Position',[0.4 0.03 0.25 0.05],...
        'callback',{@Load},...
        'tag','loadButton',...
        'parent',AO.hl);
    
    % close button
    CSEQ = uicontrol('Style', 'pushbutton',...
        'string', 'Close',...
        'Fontsize',14,...
        'units','normalized',...
        'Position',[0.7 0.03 0.25 0.05],...
        'callback',{@Close},...
        'tag','CloseButton',...
        'parent',AO.hl);
    
    %Select scan type
    ScanText = uicontrol('Style','text',...
        'String','Choose US sequence type',...
        'visible', 'on',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','left',...
        'Fontsize',12,...
        'units','normalized',...
        'tag','ScanText',...
        'Position',[0.05,0.9,0.9,0.05],...
        'parent',AO.hl);
    
    ScanEdit = uicontrol('Style','popupmenu',...
        'string',{'Focused US','Plane Waves'},...
        'value',AO.val,...
        'Fontsize',12,...
        'visible', 'on',...
        'units','normalized',...
        'Position',[0.05,0.87,0.5,0.05],...
        'callback',{@ScanSelect},...
        'tag','Scan',...
        'parent',AO.hl);
    
    %load already done sequence
    PathText = uicontrol('Style','text',...
        'String','Load a previous sequence or enter parameters',...
        'visible', 'on',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','left',...
        'Fontsize',12,...
        'units','normalized',...
        'tag','PathText',...
        'Position',[0.05,0.78,0.9,0.04],...
        'parent',AO.hl);
    
    PathEdit = uicontrol('Style','edit',...
        'string','',...
        'Fontsize',12,...
        'visible', 'on',...
        'enable','off',...
        'units','normalized',...
        'Position',[0.05,0.75,0.75,0.04],...
        'tag','Path',...
        'parent',AO.hl);
    
    browseButton = uicontrol('Style', 'pushbutton',...
        'string', 'Browse',...
        'Fontsize',12,...
        'BackgroundColor',AO.parentcolor,...
        'visible', 'on',...
        'units','normalized',...
        'Position',[0.80,0.75,0.15,0.04],...
        'callback',{@browse},...
        'tag','browseButton',...
        'parent',AO.hl);
    
    % param buttons
    
    VoltText = uicontrol('Style','text',...
        'String','US tension (V)',...
        'horizontalalignment','center',...
        'BackgroundColor',AO.parentcolor,...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.05 0.64 0.5 0.04],...
        'parent',AO.hl);
    
    VoltEdit = uicontrol('Style','edit',...
        'string',AO.Volt(AO.val),...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.65 0.3 0.04],...
        'callback', {@checkValue},...
        'tag','Volt',...
        'parent',AO.hl);
    
    FreqText = uicontrol('Style','text',...
        'String','Probe frequency (MHz)',...
        'horizontalalignment','center',...
        'BackgroundColor',AO.parentcolor,...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.05 0.57 0.5 0.04],...
        'parent',AO.hl);
    
    FreqEdit = uicontrol('Style','edit',...
        'string',AO.FreqSonde(AO.val),...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.58 0.3 0.04],...
        'tag','FreqSonde',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    HemicycleText = uicontrol('Style','text',...
        'String','Number of hemicycles',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.05 0.5 0.5 0.04],...
        'parent',AO.hl);
    
    HemicycleEdit = uicontrol('Style','edit',...
        'string',AO.NbHemicycle(AO.val),...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.51 0.3 0.04],...
        'tag','NbHemicycle',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    FocText = uicontrol('Style','text',...
        'String','US Focus depth (mm)',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.05 0.43 0.5 0.04],...
        'parent',AO.hl);
    
    FocEdit = uicontrol('Style','edit',...
        'string',AO.Foc,...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.44 0.3 0.04],...
        'tag','Foc',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    AlphaText = uicontrol('Style','text',...
        'String','Alpha max (�)',...
        'visible','off',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.05 0.43 0.5 0.04],...
        'parent',AO.hl);
    
    AlphaEdit = uicontrol('Style','edit',...
        'string',AO.AlphaM,...
        'visible','off',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.44 0.3 0.04],...
        'tag','AlphaMax',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    X0Text = uicontrol('Style','text',...
        'String','X0 (mm)',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'tag','X0Text',...
        'Position',[0.05 0.36 0.5 0.04],...
        'parent',AO.hl);
    
    X0Edit = uicontrol('Style','edit',...
        'string',AO.X0,...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.37 0.3 0.04],...
        'tag','X0',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    dAText = uicontrol('Style','text',...
        'String','Pas (�)',...
        'visible','off',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'tag','dAText',...
        'Position',[0.05 0.36 0.5 0.04],...
        'parent',AO.hl);
    
    dAEdit = uicontrol('Style','edit',...
        'string',AO.dA,...
        'visible','off',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.37 0.3 0.04],...
        'tag','dA',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    WidthXText = uicontrol('Style','text',...
        'String','Width along X (mm)',...
        'Visible','on',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'tag','WidthXText',...
        'Position',[0.05 0.29 0.5 0.04],...
        'parent',AO.hl);
    
    WidthXEdit = uicontrol('Style','edit',...
        'string', AO.ScanLength,...
        'Visible','on',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.30 0.3 0.04],...
        'tag','ScanLength',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    
    USDepthText = uicontrol('Style','text',...
        'String','Depth in US direction (mm)',...
        'Visible','on',...
        'BackgroundColor',AO.parentcolor,...
        'horizontalalignment','center',...
        'Fontsize',12,...
        'units','normalized',...
        'tag','USDepthText',...
        'Position',[0.05 0.22 0.5 0.04],...
        'parent',AO.hl);
    
    USDepthEdit = uicontrol('Style','edit',...
        'string',AO.Prof(AO.val),...
        'Visible','on',...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.23 0.3 0.04],...
        'tag','Prof',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    NtrigText = uicontrol('Style','text',...
        'String','Number of averaging',...
        'horizontalalignment','center',...
        'BackgroundColor',AO.parentcolor,...
        'Fontsize',12,...
        'units','normalized',...
        'tag','NtrigText',...
        'Position',[0.05 0.15 0.5 0.04],...
        'parent',AO.hl);
    
    NtrigEdit = uicontrol('Style','edit',...
        'string',AO.NTrig(AO.val),...
        'Fontsize',12,...
        'units','normalized',...
        'Position',[0.55 0.16 0.3 0.04],...
        'tag','Ntrig',...
        'callback', {@checkValue},...
        'parent',AO.hl);
    
    AO.hlOpen = 1; % marker for telling the window is open.
    
    guidata(hf,AO)
    ScanSelect(ScanEdit);
end

    function Load(source,eventdata)
        AO.Volt(AO.val)         = str2double(get(VoltEdit,'string'));
        AO.FreqSonde(AO.val)    = str2double(get(FreqEdit,'string'));
        AO.NbHemicycle(AO.val)  = str2double(get(HemicycleEdit,'string'));
        
        AO.NTrig(AO.val)        = str2double(get(NtrigEdit,'string'));
        AO.Prof(AO.val)         = str2double(get(USDepthEdit,'string'));
        
        switch get(ScanEdit,'value');
            case 1
                AO.X0          = str2double(get(X0Edit,'string'));
                AO.Foc         = str2double(get(FocEdit,'string'));
                AO.ScanLength  = str2double(get(WidthXEdit,'string'));
                
                AO.SEQ = AOSeqInit_FOC( AO );
                
            case 2
                AO.AlphaM   = str2double(get(AlphaEdit,'string'));
                AO.dA       = str2double(get(dAEdit,'string'));
                
                AO.SEQ = AOSeqInit_OP( AO );
                
        end
        
        set(AO.LOADED,'visible','on')
        set(AO.start,'enable','on','string','Start Sequence')
        set(AO.SREdit,'enable','on')
        set(AO.RangeEdit,'enable','on')
        guidata(hf,AO)
        
    end

    function ScanSelect(source,eventdata)
        
        AO.val=get(source,'value');
        switch AO.val
            case 1
                set(AlphaText,'visible','off')
                set(AlphaEdit,'visible','off')
                set(dAText,'visible','off')
                set(dAEdit,'visible','off')
                
                set(FocText,'visible','on')
                set(FocEdit,'visible','on')
                set(X0Text,'visible','on')
                set(X0Edit,'visible','on')
                set(WidthXText,'visible','on')
                set(WidthXEdit,'visible','on')
                
            case 2
                set(AlphaText,'visible','on')
                set(AlphaEdit,'visible','on')
                set(dAText,'visible','on')
                set(dAEdit,'visible','on')
                
                set(FocText,'visible','off')
                set(FocEdit,'visible','off')
                set(X0Text,'visible','off')
                set(X0Edit,'visible','off')
                set(WidthXText,'visible','off')
                set(WidthXEdit,'visible','off')
                
        end
        
        set(FreqEdit,'string',AO.FreqSonde(AO.val))
        set(VoltEdit,'string',AO.Volt(AO.val))
        set(HemicycleEdit,'string',AO.NbHemicycle(AO.val))
        set(USDepthEdit,'string',AO.Prof(AO.val))
        set(NtrigEdit,'string',AO.NTrig(AO.val))
        
    end

    function Close(source,eventdata)
        close(AO.hl)
    end

    function browse(source,eventdata)
        switch AO.val
            case 1
                [filename,dir,FilterIndex] = uigetfile('D:\AcoustoOptique\SEQdir\SEQ_Foc*.mat','Select a sequence');
                
                if FilterIndex
                    load([dir filename],'CP');
                    set(PathEdit,'string',filename)
                    
                    AO.Volt(AO.val)         = CP.ImgVoltage;
                    AO.FreqSonde(AO.val)    = CP.TwFreq;
                    AO.NbHemicycle(AO.val)  = CP.NbHcycle;
                    
                    AO.Foc          = CP.PosZ;
                    AO.X0           = CP.PosX;
                    AO.ScanLength   = CP.ScanLength;
                    
                    AO.Prof(AO.val)  = CP.Prof;
                    AO.NTrig(AO.val) = CP.Repeat;
                end
                
            case 2
                [filename,dir,FilterIndex] = uigetfile('D:\AcoustoOptique\SEQdir\SEQ_OP*.mat','Select a sequence');
                
                if FilterIndex
                    load([dir filename],'UF');
                    set(PathEdit,'string',filename)
                    
                    AO.Volt(AO.val)         = UF.ImgVoltage;
                    AO.FreqSonde(AO.val)    = UF.TwFreq;
                    AO.NbHemicycle(AO.val)  = UF.NbHcycle;
                    
                    AO.AlphaM   = UF.AlphaM;
                    AO.dA       = UF.dA;
                    
                    AO.Prof(AO.val)  = UF.Prof;
                    AO.NTrig(AO.val) = UF.Repeat;
                end
                
        end
        
        set(VoltEdit,'string',AO.Volt(AO.val))
        set(FreqEdit,'string',AO.FreqSonde(AO.val))
        set(HemicycleEdit,'string',AO.NbHemicycle(AO.val))
        
        set(FocEdit,'string',AO.Foc)
        set(AlphaEdit,'string',AO.AlphaM)
        set(X0Edit,'string',AO.X0)
        set(dAEdit,'string',AO.dA)
        set(WidthXEdit,'string',AO.ScanLength)
        
        set(USDepthEdit,'string',AO.Prof(AO.val))
        set(NtrigEdit,'string',AO.NTrig(AO.val))

    end

    function checkValue(source,eventdata)
        
        if isnan(str2double(get(source,'string')))
            display('ERROR : Must enter a numeric value')
            set(source,'string','0')
            return
        end
        
        if str2double(get(source,'string'))<0
            if strcmp(get(source,'tag'),'AlphaMax') || strcmp(get(source,'tag'),'dA')
                display('Warning : angles values are set as positive numbers')
                set(source,'string',num2str(abs(str2double(get(source,'string')))))
            else
                
                display('ERROR : Must enter a positive value')
                set(source,'string','0')
                return
            end
        end
        
        if strcmp(get(source,'tag'),'Volt') || strcmp(get(source,'tag'),'Freq')
            if str2double(get(FreqEdit,'string'))==15 && str2double(get(VoltEdit,'string'))>25
                display('ERROR : Max voltage 25V')
                switch get(source,'tag')
                    case 'Volt'
                        set(source,'string','25')
                    case 'Freq'
                        set(source,'string','0')
                end
            end
        end
        
        if strcmp(get(source,'tag'),'Hemicycle') && str2double(get(source,'string'))>20
            display('ERROR : US impulse is too long')
            set(source,'string','20')
        end
        
        if strcmp(get(source,'tag'),'X0') || strcmp(get(source,'tag'),'WidthX')
            tmp=get(source,'string');
            switch get(source,'tag')
                case 'X0'
                    if str2double(tmp)>system.probe.NbElemts*system.probe.Pitch
                        display('ERROR : Scan starting position can''t exceed probe length')
                        set(source,'string',num2str(system.probe.NbElemts*system.probe.Pitch))
                    elseif str2double(tmp)+str2double(get(WidthXEdit,'string'))>system.probe.NbElemts*system.probe.Pitch
                        display('ERROR : Scan exceeds probe length')
                        set(WidthXEdit,'string',num2str(system.probe.NbElemts*system.probe.Pitch-str2double(tmp)))
                    end
                case 'WidthX'
                    if str2double(tmp)+str2double(get(X0Edit,'string'))>system.probe.NbElemts*system.probe.Pitch
                        display('ERROR : Scan exceeds probe length')
                        set(WidthXEdit,'string',num2str(system.probe.NbElemts*system.probe.Pitch-str2double(get(X0Edit,'string'))))
                    end
            end
        end
        
        if strcmp(get(source,'tag'),'AlphaMax')
            if str2double(get(source,'string'))>40 && strcmpi(system.probe.Type,'linear')
                display('Max scanning range for linear array is 40�')
                set(source,'string','40')
            end
        end
        
        if strcmp(get(source,'tag'),'dA')
            if str2double(get(source,'string'))>str2double(get(AlphaEdit,'string'))
                display('Scanning steps can''t exceed scanning range')
                set(source,'string',get(AlphaEdit,'string'))
            end
        end
        
    end

end