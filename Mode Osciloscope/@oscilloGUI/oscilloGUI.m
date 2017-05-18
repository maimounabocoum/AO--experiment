classdef oscilloGUI
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Hfig
        axe
        hhh
        hhhh
        action
    end
    
    methods
        function obj = oscilloGUI()
            % Position : [left(from container left) bottom (from container bottom) width heigth]
          obj.Hfig   = figure('Position',[30 60 1400 700]);
          % Create axes
          obj.axe(1) =   axes('Parent',obj.Hfig,...
                'Position',[0.0923650691835426 0.296282143982457 0.419761904761905 0.509856789781679]);

            % Create axes
          obj.axe(2) =  axes('Parent',obj.Hfig,...
                'Position',[0.548235743303093 0.304359688408951 0.419761904761904 0.505010263125784]);

          controlContainerTOP  = uipanel('Parent', obj.Hfig, 'Units', 'normalized', 'Position', [0.15 1-1./8-0.05 0.7 1./8]) ;
          controlContainerLEFT = uipanel('Parent', obj.Hfig, 'Units', 'normalized', 'Position', [0.01 0.2 0.05 0.7]) ;
          
          obj.hhh    = uicontrol('Parent',controlContainerLEFT,'Style', 'slider','Min',0.01,'Max',100,'Value',100,...
                                 'SliderStep',[0.0001 0.0002],'Units', 'normalized',...
                                 'Position', [0 0 0.2 1],'Callback', 'y2limit=get(fenetre2.hhh)');
          obj.hhhh   = uicontrol('Parent',controlContainerLEFT,'Style', 'slider','Min',0.01,'Max',100,'Value',100,...
                                 'SliderStep',[0.01 0.02],'Units', 'normalized',...
                                 'Position', [0.2 0 0.2 1],'Callback', 'x2limit=get(fenetre2.hhhh)');

% uicontrol('Style', 'edit','Fontsize',20,'string','Ncycles', 'Position', [680 655 100 35],'Callback', '');
% s2=uicontrol('Style', 'edit','Fontsize',20,'string','10', 'Position', [680 625 100 30],'Callback', '[gen1,Gen.Frequency,Gen.Amplitude]=generateurfonction(s1,s2,s3);Gen.Data = gen1;');

          obj.action = uicontrol('Parent',controlContainerTOP,'Style', 'popup','Fontsize',20,'String', 'frequency|wavelength',...
                                 'Units', 'normalized','Position', [0.8 0.2 0.2 0.5],'Callback','');   

% uicontrol('Style', 'edit','Fontsize',20,'string','Moyennage', 'Position', [990 655 150 35],'Callback', '');
% s5=uicontrol('Style', 'edit','Fontsize',20,'string','4','Position', [990 625 150 30],'Callback', '');

uicontrol('Parent',controlContainerTOP,'Style', 'pushbutton','Fontsize',20,'String', 'STOP',...
          'Units', 'normalized','Position', [0 0.2 0.2 0.5],'Callback', 'k=0;');

    end
    
    end
end

