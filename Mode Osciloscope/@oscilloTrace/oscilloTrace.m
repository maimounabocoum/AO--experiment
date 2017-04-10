classdef oscilloTrace
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        t
        z
        Nlines
        Lines
        SampleRate
    end
    
    methods
        function obj = oscilloTrace(Npoints,Nlines,SampleRate,c)
                % Transfer data to Matlab
                dt             = 1/(SampleRate) ;
                obj.Nlines     = Nlines ;
                obj.SampleRate = SampleRate;    
                % by default, indexation in Gage starts at 0
                obj.Lines      = zeros(Npoints,Nlines);
               % data  = zeros(Npoints,1);
                obj.t          = (0:Npoints-1)*dt;
                obj.z          = c*(obj.t);
    
        end
        
        function obj = Addline(obj,Nmin,Nmax,datatmp,lineNumber)

            obj.Lines((1+Nmin):Nmax,lineNumber) = datatmp(:)' ;
            
        end
        
        function [] = ScreenAquisition(obj,FigHandle)
            % does the figue handle exist :

            %   set figure properties :
            set(FigHandle,'name','1D data analysis');
            set(FigHandle,'NextPlot', 'replace'); 
            
            LineAverage = sum(obj.Lines,2)/(obj.Nlines) ;
            
                Fs = obj.SampleRate;
                N = length(LineAverage);
                xdft = fft(LineAverage);
                xdft = xdft(1:N/2+1);
                xdft_filtered = xdft;
                psdx = (1/(Fs*N)) * abs(xdft).^2;
                psdx(2:end-1) = 2*psdx(2:end-1);
                freq = 0:Fs/N:Fs/2;
                
                b = [1/6 1/6 1/6 1/6 1/6 1/6];
                a = 1;
                LineAverage_filtered = filter(b,a,LineAverage);

            
              subplot(311)
              
              lambda = 1540./freq(10:end);
               plot(obj.z*1e3,LineAverage)
               hold on 
              plot(obj.z*1e3,LineAverage_filtered,'color','red')
              hold off
%               hl1=line(obj.z*1e3,LineAverage,LineAverage,'Color','blue');
%               hl2=line(obj.z*1e3,smooth(LineAverage,10),'Color','r');
%             %  plotxx(obj.z*1e3,LineAverage,obj.t*1e6,smooth(LineAverage,10),{'mm','\mu s'},{'Volt'});
%               ax(1)=gca; % axis containg datas
% %             set(ax(1),'XColor','blue','YColor','blue');
%                 ax(2)= axes('Position',get(ax(1),'Position'),...
%                            'XAxisLocation','top',...
%                            'YAxisLocation','right',...
%                            'Color','none',...
%                            'XColor','red',...
%                            'YColor','red',...
%                            'XLim',get(ax(1),'XLim'),...
%                            'ytick',[]);
%                        get(ax(2))
%              set(ax,'box','off')
%              set(get(ax(1),'xlabel'),'string','z(mm)')
%              set(get(ax(2),'xlabel'),'string','t(\mu s)')
%              set(get(ax(1),'ylabel'),'string','Volt')
%  
             
              
              
              subplot(312)
              


                plot(lambda*1e3,psdx(10:end))
                grid on
                title('Periodogram Using FFT')
                xlabel('\lambda (mm)')
                ylabel('Power/Frequency (dB/Hz)')
                
                subplot(313)
                
                plot(freq*1e-6,10*log10(psdx))
                grid on
                title('Periodogram Using FFT')
                xlabel('Frequency (MHz)')
                ylabel('Power/Frequency (dB/Hz)')

            
        end


    
    end

end

   
            
        function [ax,hl1,hl2] = plotxx(x1,y1,x2,y2,xlabels,ylabels)
%PLOTXX - Create graphs with x axes on both top and bottom 
%Author: Denis Gilbert, Ph.D., physical oceanography
%Maurice Lamontagne Institute, Dept. of Fisheries and Oceans Canada
%email: gilbertd@dfo-mpo.gc.ca  Web: http://www.qc.dfo-mpo.gc.ca/iml/
%November 1997; Last revision: 01-Nov-2001
  

            if nargin < 4
               error('Not enough input arguments')
            elseif nargin==4
               %Use empty strings for the xlabels
               xlabels{1}=' '; xlabels{2}=' '; ylabels{1}=' '; ylabels{2}=' ';
            elseif nargin==5
               %Use empty strings for the ylabel
               ylabels{1}=' '; ylabels{2}=' ';
            elseif nargin > 6
               error('Too many input arguments')
            end

            if length(ylabels) == 1
               ylabels{2} = ' ';
            end

            if ~iscellstr(xlabels) 
               error('Input xlabels must be a cell array')
            elseif ~iscellstr(ylabels) 
               error('Input ylabels must be a cell array')
            end

            hl1=line(x1,y1,'Color','blue');
            hl2=line(x2,y2,'Color','r');
            %hl2=line(x2,y2,'Color','r','Parent',ax(2));
            
            ax(1)=gca;
            ax(2) = axes;
           % copyobj(ax(1),ax(2));

%             set(ax(1),'XColor','blue','YColor','blue');
% % 
%             ax(2)= axes('Position',get(ax(1),'Position'),...
%                        'XAxisLocation','top',...
%                        'YAxisLocation','right',...
%                        'Color','none',...
%                        'XColor','red',...
%                        'YColor','red',...
%                        'XLim',get(ax(1),'XLim'));
                   

            %set(ax,'box','on')

           
            %label the two x-axes
            %set(ax(2),'XLim',get(ax(1),'XLim'));
%             set(get(ax(1),'xlabel'),'string',xlabels{1})
%             set(get(ax(2),'xlabel'),'string',xlabels{2})
%             set(get(ax(1),'ylabel'),'string',ylabels{1})
            %set(get(ax(2),'ylabel'),'string',ylabels{2})
             get(ax(1))
             
     end

