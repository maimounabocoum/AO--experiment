classdef oscilloGUI < handle 
    %   UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %% GUI status
        IsRunning
        
        %% GUI handle
        gui_h
    end
    
    methods
        
        function this = oscilloGUI()
            %% init oscilloscope status 
            this.IsRunning = 1;
            
            %% initialize GUI
            this.gui_h = guihandles(oscillo_gui);
%% define callback functions inside the current class :
set(this.gui_h.stop, 'callback', @(src, event) stop_Callback(this, src, event));
set(this.gui_h.update, 'callback', @(src, event) update_Callback(this, src, event));

        end
        
        
    end
    
    %Private Class Methods - these functions can only be access by the
    %class itself.
    methods (Access = private)
        
        function this = stop_Callback(this, ~, ~)
            this.IsRunning = 0;
        end
        
        function this = update_Callback(this, src, event)
            ymin = str2double( get(this.gui_h.min,'string') );
            ymax = str2double( get(this.gui_h.max,'string') );
            set(this.gui_h.axes1,'ylim',[ymin ymax])
        end
    end
end


