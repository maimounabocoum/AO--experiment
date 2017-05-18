function varargout = OscilloscopeProgram(varargin)
% OSCILLOSCOPEPROGRAM MATLAB code for OscilloscopeProgram.fig
%      OSCILLOSCOPEPROGRAM, by itself, creates a new OSCILLOSCOPEPROGRAM or raises the existing
%      singleton*.
%
%      H = OSCILLOSCOPEPROGRAM returns the handle to a new OSCILLOSCOPEPROGRAM or the handle to
%      the existing singleton*.
%
%      OSCILLOSCOPEPROGRAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OSCILLOSCOPEPROGRAM.M with the given input arguments.
%
%      OSCILLOSCOPEPROGRAM('Property','Value',...) creates a new OSCILLOSCOPEPROGRAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OscilloscopeProgram_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OscilloscopeProgram_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OscilloscopeProgram

% Last Modified by GUIDE v2.5 18-May-2017 11:07:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OscilloscopeProgram_OpeningFcn, ...
                   'gui_OutputFcn',  @OscilloscopeProgram_OutputFcn, ...
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


% --- Executes just before OscilloscopeProgram is made visible.
function OscilloscopeProgram_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OscilloscopeProgram (see VARARGIN)


% Choose default command line output for OscilloscopeProgram
handles.output = hObject;

% default folder for Legal :
addpath('C:\Users\bocoum\Documents\MATLAB\legHAL\');
addPathLegHAL();
common.constants.SoundSpeed



% initialize buttons
set(handles.start,'visible','off');
set(handles.abort,'visible','off');

global NTrig Prof SampleRate
NTrig = 0 ;
Prof  = 0 ;
SampleRate = 10 ;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OscilloscopeProgram wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = OscilloscopeProgram_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output



function Volt_Callback(hObject, eventdata, handles)
% hObject    handle to Volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Volt as text
%        str2double(get(hObject,'String')) returns contents of Volt as a double


% --- Executes during object creation, after setting all properties.
function Volt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Volt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Freq_Callback(hObject, eventdata, handles)
% hObject    handle to Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Freq as text
%        str2double(get(hObject,'String')) returns contents of Freq as a double


% --- Executes during object creation, after setting all properties.
function Freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Nhc_Callback(hObject, eventdata, handles)
% hObject    handle to Nhc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Nhc as text
%        str2double(get(hObject,'String')) returns contents of Nhc as a double


% --- Executes during object creation, after setting all properties.
function Nhc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Nhc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Xcenter_Callback(hObject, eventdata, handles)
% hObject    handle to Xcenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Xcenter as text
%        str2double(get(hObject,'String')) returns contents of Xcenter as a double


% --- Executes during object creation, after setting all properties.
function Xcenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Xcenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Foc_Callback(hObject, eventdata, handles)
% hObject    handle to Foc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Foc as text
%        str2double(get(hObject,'String')) returns contents of Foc as a double


% --- Executes during object creation, after setting all properties.
function Foc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Foc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zmin_Callback(hObject, eventdata, handles)
% hObject    handle to Zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmin as text
%        str2double(get(hObject,'String')) returns contents of Zmin as a double


% --- Executes during object creation, after setting all properties.
function Zmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Zmax_Callback(hObject, eventdata, handles)
% hObject    handle to Zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Zmax as text
%        str2double(get(hObject,'String')) returns contents of Zmax as a double


% --- Executes during object creation, after setting all properties.
function Zmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Zmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Naverage_Callback(hObject, eventdata, handles)
% hObject    handle to Naverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Naverage as text
%        str2double(get(hObject,'String')) returns contents of Naverage as a double


% --- Executes during object creation, after setting all properties.
function Naverage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Naverage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GageVoltage.
function GageVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to GageVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GageVoltage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GageVoltage


% --- Executes during object creation, after setting all properties.
function GageVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GageVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GageSamplFreq_Callback(hObject, eventdata, handles)
% hObject    handle to GageSamplFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of GageSamplFreq as text
%        str2double(get(hObject,'String')) returns contents of GageSamplFreq as a double


% --- Executes during object creation, after setting all properties.
function GageSamplFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GageSamplFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in datalist.
function datalist_Callback(hObject, eventdata, handles)
% hObject    handle to datalist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns datalist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from datalist


% --- Executes during object creation, after setting all properties.
function datalist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datalist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectpath.
function selectpath_Callback(hObject, eventdata, handles)
% hObject    handle to selectpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

foldername = uigetdir('');

if foldername~=0
   set(handles.savepath,'string',foldername);   
   MyFiles = dir(foldername);
   {MyFiles.name}
   set(handles.datalist,'String',{MyFiles.name});

else
   set(handles.savepath,'string','no folder selected');   
end

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in abort.
function abort_Callback(hObject, eventdata, handles)
% hObject    handle to abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

NTrig =         str2double( get(handles.Naverage,'string') );
Prof =          str2double( get(handles.Zmax,'string') );
SampleRate =    str2double( get(handles.GageSamplFreq,'string') );
RangeList =     get(handles.GageVoltage,'String');
RangeValue     =     RangeList{get(handles.GageVoltage,'Value')};
switch RangeValue
    case '+/-1V'
        Range = 1 ;
    case '+/-5V'
        Range = 5 ;
end
isTrigged = get(handles.IsTrigged,'value');
%[ret,Hgage] = InitOscilloGage(NTrig,Prof,SampleRate,Range);

% Update handles structure
%handles.Hgage = Hgage ;

guidata(hObject, handles);

% --- Executes on button press in IsTrigged.
function IsTrigged_Callback(hObject, eventdata, handles)
% hObject    handle to IsTrigged (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of IsTrigged


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NTrig =         str2double( get(handles.Naverage,'string') );
Prof =          str2double( get(handles.Zmax,'string') );
SampleRate =    str2double( get(handles.GageSamplFreq,'string') );
RangeList =     get(handles.GageVoltage,'String');
Range     =     RangeList{get(handles.GageVoltage,'Value')};

[ SEQ ] = InitOscilloSequence(AixplorerIP, Volt , FreqSonde , NbHemicycle , Foc , X0, NTrig);



% --- Executes on button press in legalselection.
function legalselection_Callback(hObject, eventdata, handles)
% hObject    handle to legalselection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
