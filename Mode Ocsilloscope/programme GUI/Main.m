function varargout = Main(varargin)
% MAIN M-file for Main.fig

%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 15-Sep-2015 11:24:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

% Choose default command line output for Main
handles.output = hObject;

if exist('GlobalData.mat')
    load('GlobalData.mat')
else
    GlobalData.infos = 'Here will be stored all the images information';
    save('GlobalData','GlobalData');
end

% Update handles structure
guidata(hObject, handles);
%axes(handles.axes1);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'G:\Données Manip\HARMONICS campaign - 2014 - 23fs\*'}, 'pick image');
fich1 = fullfile(pathname,filename);
% 
% TEST CONDITION IMAGE 
if(exist(fich1))
set(handles.text18,'String',fich1);
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.

function a_Callback(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a as text
%        str2double(get(hObject,'String')) returns contents of a as a double


% --- Executes during object creation, after setting all properties.
function a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Lambda_Callback(hObject, eventdata, handles)
% hObject    handle to Lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lambda as text
%        str2double(get(hObject,'String')) returns contents of Lambda as a double


% --- Executes during object creation, after setting all properties.
function Lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function F_Callback(hObject, eventdata, handles)
% hObject    handle to F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of F as text
%        str2double(get(hObject,'String')) returns contents of F as a double

% --- Executes during object creation, after setting all properties.
function F_CreateFcn(hObject, eventdata, handles)
% hObject    handle to F (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in Validate.

function Validate_Callback(hObject, eventdata, handles)
 
% hObject    handle to Validate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get all the parameters GUI : 
a = str2double(get(handles.a,'String'));
lambda = str2double(get(handles.Lambda,'String'));
f = str2double(get(handles.F,'String'));
Dx = 1e-6*str2double(get(handles.calibration,'String'));
% print selected main image
fich1 = get(handles.text18,'String');

%GlobalData.Image = load(fich1);
GlobalData.Image = double(importdata(fich1));

save('GlobalData','GlobalData');
handles.D = GlobalData.Image;

%handles.D = medfilt2(handles.D,[25 25]);

[Ny Nx] = size(handles.D); % number of pixels in x direction
handles.Nx = Nx;
handles.Ny = Ny;
set(handles.text5,'String',num2str(Nx));
set(handles.text6,'String',num2str(Ny));

% windows dimension

handles.Lx = Nx*Dx; % en m
handles.Ly = Ny*Dx; % en m


% save at the end ??
GlobalData.x = 1e6*linspace(-handles.Lx/2,handles.Lx/2,Nx);
GlobalData.y = 1e6*linspace(-handles.Ly/2,handles.Ly/2,Ny);
save('GlobalData','GlobalData');

    handles.x = 1e6*linspace(-handles.Lx/2,handles.Lx/2,Nx); % microns
    handles.y = 1e6*linspace(-handles.Ly/2,handles.Ly/2,Ny); % microns
    handles.fx = (1e-6*handles.x)/(lambda*f);
    handles.fy = (1e-6*handles.y)/(lambda*f);
    handles.lambda = lambda;
    handles.f = f;

     
% definition des coordonnée courantes (change avec un zoom ou un étallonnage)    
    handles.Currx = handles.x;
    handles.Curry = handles.y;
    handles.CurrD = handles.D ;

imagesc(handles.D,'Parent',handles.axes1,'CDataMapping','Scaled')
colorbar('peer',handles.axes1)
%image plot
handles.Currxlim = get(handles.axes1,'XLim');
handles.Currylim = get(handles.axes1,'YLim');

Tau = str2double(get(handles.edit7,'String'));
chirp = str2double(get(handles.chirp,'String'));

[handles.t_gaussian , handles.It_gaussian] = GetGaussianTemporalProfil(Tau,chirp);

A = get(handles.TypeOftemporal,'String');
B = get(handles.TypeOftemporal,'Value');

if strcmp(A{B},'gaussian')
   plot(handles.t_gaussian,handles.It_gaussian,'Parent',handles.axes2) 
   xlabel(handles.axes2,'time (fs)')
   ylabel(handles.axes2,'Normalized I(t)')
end



counts = mean(handles.CurrD(:));
set(handles.edit13,'String',num2str(counts));




guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes on selection change in centering.
function centering_Callback(hObject, eventdata, handles)
% hObject    handle to centering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns centering contents as cell array
%        contents{get(hObject,'Value')} returns selected item from centering


% --- Executes during object creation, after setting all properties.
function centering_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in coordinates.
function coordinates_Callback(hObject, eventdata, handles)
% hObject    handle to coordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns coordinates contents as cell array
%        contents{get(hObject,'Value')} returns selected item from coordinates

handles = updateCurrentAxis(handles);



     guidata(hObject, handles);
     
     

% --- Executes during object creation, after setting all properties.
function coordinates_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in GetCenter.
function GetCenter_Callback(hObject, eventdata, handles)
% hObject    handle to GetCenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% extracting multichoice :
a_index = get(handles.centering,'Value');
a = get(handles.centering,'String');

if strcmp(a(a_index),'use current image')
    
    % find maximum of appearing image
    [M P] = max(handles.CurrD(:)); % P : index of current (zoomed) image max 
    [Px Py] = ind2sub(size(handles.CurrD),P); % index to line / col
    Pts = [Px Py]'; % max coordinates
    
elseif strcmp(a(a_index),'manual selection')
    % opening selector 
    [Px Py] = ginput(1); % returns points in microns 
    Px = max(find(handles.Currx < Px)); % microns to col
    Py = max(find(handles.Curry < Py)); % microns to line
    Pts = [Py Px]';
end

% find maximum of ROI

% plot maximum
%  hmarkerinserter = video.MarkerInserter;
%  hmarkerinserter.Shape = 'Plus';
%  hmarkerinserter.Size = 200;
%  handles.D = step(hmarkerinserter, handles.D, Pts); % adds maker on the image

 % redefining the center of axis : 
 handles.Currx = linspace(-handles.Nx/2-(Pts(2)-handles.Nx/2),handles.Nx/2-(Pts(2)-handles.Nx/2),handles.Nx)*(handles.Currx(2)-handles.Currx(1)) ;
 handles.Curry = linspace(-handles.Ny/2-(Pts(1)-handles.Ny/2),handles.Ny/2-(Pts(1)-handles.Ny/2),handles.Ny)*(handles.Curry(2)-handles.Curry(1)) ;

%medfilt2(handles.D,[25 25])
image(handles.D,'Parent',handles.axes1,'XData',handles.Currx,'YData',handles.Curry,'CDataMapping','Scaled');
colorbar('peer',handles.axes1)
handles.Currxlim = get(handles.axes1,'Xlim');
handles.Currylim = get(handles.axes1,'Ylim');

guidata(hObject, handles);


% --------------------------------------------------------------------
function uitoggletool9_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% recording of last zoom axis set up :
handles.Currxlim = get(handles.axes1,'XLim');
handles.Currylim = get(handles.axes1,'YLim');

CurrD = handles.D; % intensity conversion from RGB image
CurrD(find(handles.Curry < handles.Currylim(1) | handles.Curry > handles.Currylim(2)),:) = 0;
CurrD(:,find(handles.Currx < handles.Currxlim(1) | handles.Currx > handles.Currxlim(2))) = 0;

handles.CurrD = CurrD; % handles des valeurs utilisées pour la recherche de max


 guidata(hObject, handles);


    


% --- Executes on button press in Energy.
function Energy_Callback(hObject, eventdata, handles)
% hObject    handle to Energy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GlobalData.xlim = handles.Currxlim;
GlobalData.ylim = handles.Currylim;
GlobalData.x = handles.Currx;
GlobalData.y = handles.Curry;
GlobalData.Image = handles.CurrD;
save('GlobalData','GlobalData');

IntensityRetrieval;
 guidata(hObject, handles);



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NormEnergy.
function NormEnergy_Callback(hObject, eventdata, handles)
% hObject    handle to NormEnergy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% integrale de l'image courante : 
Energy = 1e-3*str2double(get(handles.edit6,'String'));


Options = get(handles.TypeOftemporal,'String');
Choice = get(handles.TypeOftemporal,'Value');


ImSum = trapz(handles.Currx,trapz(handles.Curry,handles.CurrD));
f_xy = handles.CurrD/ImSum;

switch Options{Choice}
    case 'gaussian'        
Tau = str2double(get(handles.edit7,'String'));
chirp = str2double(get(handles.chirp,'String'));
[handles.t_gaussian , handles.It_gaussian] = GetGaussianTemporalProfil(Tau,chirp);
TempInt = trapz(handles.t_gaussian ,handles.It_gaussian);
t = handles.t_gaussian;
I_t = handles.It_gaussian/TempInt;
% puissance surfacique en J/fs/microns^2
handles.CurrD = Energy*max(I_t)*f_xy ;
% conversion en J/s/cm^2
handles.CurrD = handles.CurrD*(1e15)*(1e4)^2;
    case 'loaded profil'  
t = handles.wizzler_time.data(:,1);
I_t = handles.wizzler_time.data(:,2);
Phi_t = handles.wizzler_time.data(:,3);

% renormalisation du profil temporel : 

TempInt = trapz(t,I_t);
I_t = I_t/TempInt;


% puissance surfacique en J/fs/microns^2
handles.CurrD = Energy*max(I_t)*f_xy ;

% conversion en J/s/cm^2

handles.CurrD = handles.CurrD*(1e15)*(1e4)^2;
     
end

if get(handles.checkbox1,'Value') == 1
image(handles.Currx,handles.Curry,log(abs(handles.CurrD)),'Parent',handles.axes1,'CDataMapping','Scaled')
else
image(handles.Currx,handles.Curry,handles.CurrD,'Parent',handles.axes1,'CDataMapping','Scaled')
end   
Imax = max(handles.CurrD(:))

if get(handles.checkbox1,'Value') == 0
plot(t,I_t*max(handles.CurrD(:))/max(I_t),'Parent',handles.axes2)
else
semilogy(t,I_t*max(handles.CurrD(:))/max(I_t),'Parent',handles.axes2)
end
    
   xlabel(handles.axes2,'time (fs)')
   ylabel(handles.axes2,'I (W/cm^2)')
   title(handles.axes2,['a_0 = ',num2str(0.86*0.8*sqrt(max(handles.CurrD(:)/1e18)))])
   
colorbar('peer',handles.axes1)
set(handles.axes1,'XLim',handles.Currxlim);
set(handles.axes1,'YLim',handles.Currylim);

set(handles.text37,'String',num2str(1e-18*max(handles.CurrD(:))));

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile({'*.*'}, 'pick image');
fich1 = fullfile(pathname,filename);
% 
% TEST CONDITION IMAGE 
if(exist(fich1))
handles.background = double(imread(fich1));
end
guidata(hObject, handles);



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   R = str2double(get(handles.edit9,'String'));
   [X Y] = meshgrid(handles.Currx,handles.Curry);
   Mask = (X.^2 + Y.^2) < R^2;
   Portion = handles.CurrD.*Mask;
imagesc(handles.Currx,handles.Curry,Portion,'Parent',handles.axes1,'CDataMapping','Scaled')
colorbar('peer',handles.axes1)
set(handles.axes1,'XLim',handles.Currxlim);
set(handles.axes1,'YLim',handles.Currylim);

percent = 100*trapz(handles.Curry,trapz(handles.Currx,Portion'))...
/trapz(handles.Curry,trapz(handles.Currx,handles.CurrD')); 

set(handles.edit8,'String',num2str(percent));
   
   guidata(hObject,handles);
   
   
   

   
   
   
   
   
   
   
   
   
   
   
   



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

  handles.CurrD(handles.CurrD < max(handles.CurrD(:))/200) = 0 ;
if get(handles.checkbox1,'Value') == 1
image(handles.Currx,handles.Curry,log(abs(handles.CurrD)),'Parent',handles.axes1,'CDataMapping','Scaled') 
else
    image(handles.Currx,handles.Curry,handles.CurrD,'Parent',handles.axes1,'CDataMapping','Scaled')
end 
colorbar('peer',handles.axes1)
set(handles.axes1,'XLim',handles.Currxlim);
set(handles.axes1,'YLim',handles.Currylim);



guidata(hObject,handles);



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ftmp = figure; 
atmp = axes;
if get(handles.checkbox1,'Value') == 1
image(handles.Currx,handles.Curry,log(abs(handles.CurrD)),'CDataMapping','Scaled')
else
    image(handles.Currx,handles.Curry,handles.CurrD,'CDataMapping','Scaled')
    
end
%colorbar
[Imax P] = max(handles.CurrD(:)); % P : index of current (zoomed) image max 
[Px Py] = ind2sub(size(handles.CurrD),P)

% set(atmp,'XLim',[-20 20]);
% set(atmp,'YLim',[-25 15]);

% set(atmp,'XLim',handles.Currxlim);
% set(atmp,'YLim',handles.Currylim);


%file_name = get(handles.edit11,'String');
%saveas(ftmp,['E:\Manip 20fs - janvier 2014\Maï Results\13-02-2014\matlab analysis\',file_name]);

%delete(ftmp);


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.folder_name = uigetdir;

guidata(hObject,handles);

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function calibration_Callback(hObject, eventdata, handles)
% hObject    handle to calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of calibration as text
%        str2double(get(hObject,'String')) returns contents of calibration as a double


% --- Executes during object creation, after setting all properties.
function calibration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to calibration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   [X Y] = ginput(2);
   handles.Lpicked = sqrt((Y(2)-Y(1))^2 + (X(2)-X(1))^2);
   guidata(hObject,handles);
   set(handles.distance,'String',num2str(handles.Lpicked))
   
   


% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dir = uigetdir('C:\Users\bocoum\Documents\thèse\matlab');
x = handles.Currx;
y = handles.Curry;
I = handles.CurrD;

filename = get(handles.edit11,'String');

save([dir,'\',filename],'x','y','I');



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[FileNameTime FolderName] = uigetfile('F:\Données Manip\HARMONICS campaign - 2014 - 23fs\mesures wizzler\TARGET','-all');
%[FileNameTime FolderName] = uigetfile('F:\Données Manip\HARMONICS campaign - 2014 - 23fs\20140821 - after compression chamber');

handles.wizzler_time = importdata([FolderName FileNameTime]);



I = findstr('time',FileNameTime) - 1;
FileNameSpectra = [FileNameTime(1:I),'spectral.txt'];

if exist([FolderName FileNameSpectra])
handles.wizzler_spectra = importdata([FolderName FileNameSpectra]);
end

t = handles.wizzler_time.data(:,1);
I_t = handles.wizzler_time.data(:,2);
 Phi_t = handles.wizzler_time.data(:,1);

lambda_nm = linspace(320,1000,length(handles.wizzler_spectra.data(:,1)));
I_w = handles.wizzler_spectra.data(:,2);
Phi_w = handles.wizzler_spectra.data(:,3);

hold(handles.axes2,'off')



A = get(handles.TypeOftemporal,'String');
B = get(handles.TypeOftemporal,'Value');

if strcmp(A{B},'loaded profil')
   plotyy(t,I_t,t,Phi_t,'Parent',handles.axes2)
   xlabel(handles.axes2,'time (fs)')
   ylabel(handles.axes2,'Normalized I(t)')
end


%plotyy(lambda_nm,I_w,lambda_nm,Phi_w,'Parent',handles.axes2)




guidata(hObject,handles);


% --- Executes on selection change in TypeOftemporal.
function TypeOftemporal_Callback(hObject, eventdata, handles)
% hObject    handle to TypeOftemporal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns TypeOftemporal contents as cell array
%        contents{get(hObject,'Value')} returns selected item from TypeOftemporal


A = get(handles.TypeOftemporal,'String');
B = get(handles.TypeOftemporal,'Value');



if strcmp(A{B},'loaded profil')
    

    
t = handles.wizzler_time.data(:,1);
I_t = handles.wizzler_time.data(:,2);
Phi_t = handles.wizzler_time.data(:,3);

tau = FWHM(I_t,t);
set(handles.edit7,'String',num2str(tau));


   plotyy(t,I_t,t,Phi_t,'Parent',handles.axes2)
   xlabel(handles.axes2,'time (fs)')
   ylabel(handles.axes2,'Normalized I(t)')
end


if strcmp(A{B},'gaussian')
Tau = str2double(get(handles.edit7,'String'));
chirp = str2double(get(handles.chirp,'String'));

[handles.t_gaussian , handles.It_gaussian] = GetGaussianTemporalProfil(Tau,chirp);


   plot(handles.t_gaussian,handles.It_gaussian,'Parent',handles.axes2) 
   xlabel(handles.axes2,'time (fs)')
   ylabel(handles.axes2,'Normalized I(t)')
end





% --- Executes during object creation, after setting all properties.
function TypeOftemporal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TypeOftemporal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chirp_Callback(hObject, eventdata, handles)
% hObject    handle to chirp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chirp as text
%        str2double(get(hObject,'String')) returns contents of chirp as a double


% --- Executes during object creation, after setting all properties.
function chirp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chirp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double

lambda0 = str2double(get(handles.Lambda,'String'));
a = str2double(get(handles.a,'String'));
focal = str2double(get(handles.F,'String'));

DX = (lambda0*focal/a)*1e6;



set(handles.edit15,'String',num2str(DX))

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
