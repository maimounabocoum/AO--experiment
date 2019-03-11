function varargout = ViewSEQ(varargin)
% VIEWSEQ MATLAB code for ViewSEQ.fig
%      VIEWSEQ, by itself, creates a new VIEWSEQ or raises the existing
%      singleton*.
%
%      H = VIEWSEQ returns the handle to a new VIEWSEQ or the handle to
%      the existing singleton*.
%
%      VIEWSEQ('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEWSEQ.M with the given input arguments.
%
%      VIEWSEQ('Property','Value',...) creates a new VIEWSEQ or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ViewSEQ_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ViewSEQ_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ViewSEQ

% Last Modified by GUIDE v2.5 18-Jan-2019 18:23:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ViewSEQ_OpeningFcn, ...
                   'gui_OutputFcn',  @ViewSEQ_OutputFcn, ...
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


% --- Executes just before ViewSEQ is made visible.
function ViewSEQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ViewSEQ (see VARARGIN)

% Choose default command line output for ViewSEQ
handles.output = hObject;

imagesc(handles.axes1,SEQ.InfoStruct.tx(1).waveform );

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ViewSEQ wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ViewSEQ_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
