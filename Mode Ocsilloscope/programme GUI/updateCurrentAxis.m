function handles = updateCurrentAxis(handles)

a_index = get(handles.coordinates,'Value');
a = get(handles.coordinates,'String');

if strcmp(a(a_index),'microns')
    
    handles.Currx = 1e6*linspace(-handles.Lx/2,handles.Lx/2,handles.Nx);
    handles.Curry = 1e6*linspace(-handles.Ly/2,handles.Ly/2,handles.Ny);
    
elseif strcmp(a(a_index),'m^{-1}')
    
    handles.Currx = (1e-6*handles.x)/(handles.lambda*handles.f);
    handles.Curry = (1e-6*handles.y)/(handles.lambda*handles.f);

    
elseif strcmp(a(a_index),'muRad')
    %*0.1635
    handles.Currx = 1e6*linspace(-handles.Lx/2,handles.Lx/2,handles.Nx)/handles.f;
    handles.Curry = 1e6*linspace(-handles.Ly/2,handles.Ly/2,handles.Ny)/handles.f;
    
   
elseif strcmp(a(a_index),'pixels')
    
   handles.Currx = 1:str2double(get(handles.text5,'String'));
   handles.Curry = 1:str2double(get(handles.text6,'String'));
    
end


    image(handles.Currx,handles.Curry,handles.D,'Parent',handles.axes1,'CDataMapping','Scaled');
    colorbar('peer',handles.axes1)
    handles.Currxlim = get(handles.axes1,'XLim');
    handles.Currylim = get(handles.axes1,'YLim');












end