classdef oscilloTrace < handle & TF_t
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %% oscilloscope properties
        z
        Npoints
        Nlines
        Lines
        SampleRate
        
        %% GUI handle 
        IsRunning
        Hgui
        param
    end
    
    methods
        function obj = oscilloTrace(Npoints,Nlines,SampleRate,c)
                % Transfer data to Matlab
                obj@TF_t(Nlines*Npoints,SampleRate);
                %dt             = 1/(SampleRate) ;
                obj.Npoints    = Npoints ;
                obj.Nlines     = Nlines ;
                obj.SampleRate = SampleRate;    
                % by default, indexation in Gage starts at 0
                obj.Lines      = zeros(Npoints,Nlines);
               % data  = zeros(Npoints,1);
                %obj.t          = (0:(Nlines*Npoints-1))*dt;
                obj.z          = c*(obj.t);
                
            %% initialize GUI
            obj.IsRunning = 1 ;
            obj.Hgui = guihandles(oscillo_gui);
%% define callback functions inside the current class :
set(obj.Hgui.stop,    'callback', @(src, event) stop_Callback(obj, src, event));
set(obj.Hgui.update,  'callback', @(src, event) update_Callback(obj, src, event));
set(obj.Hgui.save,    'callback', @(src, event) save_Callback(obj, src, event));
set(obj.Hgui.loading, 'callback', @(src, event) loading_Callback(obj, src, event));

% sets the figure close function. This lets the class know that
% the figure wants to close and thus the class should cleanup in memory as
% well :
%set(obj.Hgui.figure1,'closerequestfcn', @(src,event) Close_fcn(obj, src, event));
    
        end
        
        function obj = Addline(obj,Nmin,Nmax,datatmp,lineNumber)

            obj.Lines((1+Nmin):Nmax,lineNumber) = datatmp(:)' ;
            
        end
        
        function S = saveobj(obj,savingfolder)
            S.t           = obj.t   ;
            S.z           = obj.z ;
            S.Nlines      = obj.Nlines ;
            S.Lines       = obj.Lines  ;
            S.SampleRate  = obj.SampleRate ;
            S.param       = str2double( get(obj.Hgui.param,'string') );
            
            save(savingfolder,'S');
        end
        
        function obj = loadobj(S)
            
           if isstruc(S)
               
                newObj = ClassConstructor; 
                newObj.t = S.t;
                newObj.z = S.z;
                newObj.Nlines = S.Nlines;
                newObj.Lines = S.Lines;
                newObj.SampleRate = S.SampleRate;
                obj = newObj;
               
           else
              error('you need to enter a Structure with rigth members') 
           end
        end
        
        function [] = SNR(obj)
            
            figure
            plot(obj.Lines,'--')
            hold on
            plot(sum(obj.Lines,2),'red')
            
            
        end
        
        function [] = ScreenAquisition(obj)
            % does the figue handle exist :
            %   set figure properties :
            
            %% number of average to screen out :
            Nav = str2double( get(obj.Hgui.Nav,'string') );           
                    if isnan(Nav)
                    set(obj.Hgui.Nav,'string','1')
                    Nav = 1;
                    end
                    Nav = min(Nav,obj.Nlines);
                    set(obj.Hgui.Nav,'string',num2str(Nav));
            
            if get(obj.Hgui.unwrap,'value')
            LineAverage = obj.Lines(:) ;
            else
            LineAverage = sum(obj.Lines(:,1:Nav),2)/Nav;
            end
            
            xdft           = obj.fourier(obj.Lines(:));
            psdx = abs(xdft).^2 ;
            
            %% filtering in the fourier domaine
            filters = [-0.6 -0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5 0.6]*1e6 ;
            with = 0.2e5;
            xdft_filtered = 0*xdft;
            for filtNum = 1:length(filters)
            xdft_filtered(abs( obj.f - filters(filtNum)) < with) =...
            xdft(abs( obj.f - filters(filtNum)) < with);          
            end
            psdx_filtered = abs(xdft_filtered).^2;
            
            Lines_filtered = obj.ifourier(xdft_filtered);
            Lines_filtered = reshape(Lines_filtered,obj.Npoints,obj.Nlines);
            
            if get(obj.Hgui.unwrap,'value')
            LineAverage_filtered = Lines_filtered(:) ;
            else
            LineAverage_filtered = sum(Lines_filtered(:,1:Nav),2)/Nav;
            size(LineAverage_filtered)
            end
            %% filter signal :
            %LineAverage_filtered = ifft([xdft , xdft(end:-1:2)]) ;
            %LineAverage_filtered = spectralFiltering(freq,xdft);        
    
                
                % (-N/2:N/2-1)*Fs/N; % freq(N/2+1)
%                 n_smooth = 7;
%                 b = (1/n_smooth)*ones(1,n_smooth);
%                 a = 1;
%                 LineAverage_filtered = filter(b,a,LineAverage);
%                 xdft_filtered  = fft(LineAverage_filtered);
%                 xdft_filtered = xdft_filtered(1:N/2+1);
%                 psdx_filtered = (1/(Fs*N)) * abs(xdft_filtered).^2;
%                 psdx_filtered(2:end-1) = 2*psdx_filtered(2:end-1);

              % edit axes 1 :
              axesHandlesToChildObjects = findobj(obj.Hgui.axes1, 'Type', 'line');
                if ~isempty(axesHandlesToChildObjects)
                    delete(axesHandlesToChildObjects);
                end	
              
              % retreive x axis user selection for AO signal :  
              xchoiceList = get(obj.Hgui.X_AO,'string')  ;
              xchoice     = get(obj.Hgui.X_AO,'value')  ;
                switch xchoiceList{xchoice}
                    case 'z ( mm )'
              line(obj.z(1:length(LineAverage))*1e3,LineAverage,'parent',obj.Hgui.axes1)
              line(obj.z(1:length(LineAverage))*1e3,LineAverage_filtered,'parent',obj.Hgui.axes1,'color','red')
              xlabel('parent',obj.Hgui.axes1,'z(mm)')
              ylabel('parent',obj.Hgui.axes1,'Volt')
                    case 't ( us )'
              line(obj.t(1:length(LineAverage))*1e6,LineAverage,'parent',obj.Hgui.axes1)
              xlabel('parent',obj.Hgui.axes1,'t(\mu s)')
              ylabel('parent',obj.Hgui.axes1,'Volt')  
                end
              % edit axes 2 :
              axesHandlesToChildObjects = findobj(obj.Hgui.axes2, 'Type', 'line');
                if ~isempty(axesHandlesToChildObjects)
                    delete(axesHandlesToChildObjects);
                end	
                
                
              % retreive x axis user selection for spectrum :  
              xchoiceList = get(obj.Hgui.Xspectrum,'string')  ;
              xchoice     = get(obj.Hgui.Xspectrum,'value')  ;
              switch xchoiceList{xchoice}
              
                  case 'wavelength'
                      
              line(obj.l*1e3,psdx./(obj.l'.^2)*1540,'parent',obj.Hgui.axes2)
              xlabel('parent',obj.Hgui.axes2,'\lambda (mm)')
              set(obj.Hgui.axes2, 'XScale','log') ;

                  case 'frequency'
                      
              %trapz(freq*1e-6,psdx*1e6)
              line(obj.f*1e-6,psdx*1e6,'parent',obj.Hgui.axes2)
              line(obj.f*1e-6,psdx_filtered*1e6,'parent',obj.Hgui.axes2,'color','red')
              xlabel('parent',obj.Hgui.axes2,'f (MHz)')
              ylabel('parent',obj.Hgui.axes2,'PSD(energy/MHz)')
              set(obj.Hgui.axes2, 'XScale','linear')
              end   
              
              % set scale for y axis :
              if get(obj.Hgui.logy,'value') == 1
              set(obj.Hgui.axes2, 'YScale','log') ;
              else
              set(obj.Hgui.axes2, 'YScale','linear')   ;
              end
            
              drawnow
        end
        


    
    end
    
        %Private Class Methods - these functions can only be access by the
    %class itself.
    methods (Access = private)
        
        function obj = stop_Callback(obj, ~, ~)
            obj.IsRunning = 0;
        end
        
        function obj = loading_Callback(obj, ~, ~)
            test = 1
        end
        
        function obj = save_Callback(obj, ~, ~)
            
            foldername = get(obj.Hgui.foldername,'string');
            filename = get(obj.Hgui.filename,'string');
            if ~isdir(foldername)
               foldername =  uigetdir();
               if foldername~=0
               set(obj.Hgui.foldername,'string',foldername);
               end
            end
            
            % get all files with that name :
            MyFileInfo = dir([foldername,'\',filename,'*.mat']);
            if isempty(MyFileInfo)
                FileIndex = 0 ;
            else
                
            SortedNames = sort({MyFileInfo.name});
            % get index of last data saved :
            %regexprep(x, '"', '')
            FileIndex = regexprep(SortedNames{end},[filename,'_'], '');
            FileIndex = str2double( regexprep(FileIndex,'.mat', '') ) + 1 ;
            
            
            %exist([foldername,'\',filename,'.mat']) 

            end
             sprintf('saving : %s_%d','filename',FileIndex)
             obj.saveobj([foldername,'\',filename,'_',num2str(FileIndex),'.mat']);
                
             
            
        end
        
        function obj = update_Callback(obj, src, event)
            ymin = str2double( get(obj.Hgui.min,'string') );
            ymax = str2double( get(obj.Hgui.max,'string') );
            set(obj.Hgui.axes1,'ylim',[ymin ymax])
 
            ymin = str2double( get(obj.Hgui.min_fft,'string') );
            ymax = str2double( get(obj.Hgui.max_fft,'string') );
            set(obj.Hgui.axes2,'ylim',[ymin ymax])
            
            % set cursors
            
        end
        
        function obj = Close_fcn(obj, src, event)
            
            delete(obj);
            
            close(gcf)
            
        end
    end

end

 
