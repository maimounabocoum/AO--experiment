% USSE.USSE (COMMON.REMOTEOBJ)
%   Create an USSE.USSE instance.
%
%   OBJ = USSE.USSE() creates a generic USSE.USSE instance.
%
%   OBJ = USSE.USSE(DEBUG) creates a generic USSE.USSE instance using the DEBUG
%   value (1 is enabling the debug mode).
%
%   OBJ = USSE.USSE(NAME, DESC, DEBUG) creates an USSE.USSE instance with its
%   name and description values set to NAME and DESC (character values).
%
%   OBJ = USSE.USSE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   USSE.USSE instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - REPEAT (int32) sets the number of USSE repetition.
%       [1 Inf]
%     - LOOP (int32) enables the loop mode.
%       0 = single execution sequence, 1 = loop the sequence
%     - DATAFORMAT (char) sets the format of output data.
%       RF = RF data, BF = beamformed data, FF = final frame data - default = RF
%     - ORDERING (int32) sets the ACMO execution order during the USSE.
%       0 = chronological, [1 Inf] = customed order - default = 0
%     - DROPFRAMES (int32) enables error message if acquisition were dropped.
%       0 = no error message, 1 = error message - default = 0
%
%   Dedicated objects:
%     - TPC contains a single REMOTE.TPC instance.
%     - ACMO contains ACMO.ACMO instances.
%
%   Dedicated variables:
%     - SERVER contains the remote server parameters.
%     - INFOSTRUCT contains general information on the ultrasound sequence.
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass USSE.USSE.
%     - BUILDREMOTE builds the associated remote structure.
%     - CALLBACKS manages GUIs callbacks.
%     - SELECTHARDWARE selects the system hardware.
%     - SELECTPROBE selects the probe.
%     - INITIALIZEREMOTE initializes the remote server.
%     - QUITREMOTE switches the system to user level.
%     - STOPSSYSTEM stops the remote host.
%     - LOADSEQUENCE loads the ultrasound sequence.
%     - STARTSEQUENCE starts the loaded ultrasound sequence.
%     - STOPSEQUENCE stops the loaded ultrasound sequence.
%     - GETDATA waits for data and retrieve them.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass USSE.USSE.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass USSE.USSE.
%     - GETPARAM retrieves the value/object of a USSE.USSE parameter.
%     - SETPARAM sets the value of a USSE.USSE parameter.
%     - ISEMPTY checks if all USSE.USSE parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass USSE.USSE and its superclass
%   COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/09

classdef usse < common.remoteobj

% ============================================================================ %
% ============================================================================ %

% USSE.USSE dedicated variables (protected value)
properties ( SetAccess = 'protected', GetAccess = 'protected' )

    RemoteStruct = {}; % remote structure of the sequence
    StopDlg      = []; % stop sequence dialog window

end

% ============================================================================ %

% USSE.USSE private variables (protected value)
properties ( SetAccess = 'protected', GetAccess = 'public' )

    Server     % structure corresponding to the remotely controled sytem
    InfoStruct % structure corresponding to the info structure

    ServerInfos
end

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )

    % Class definition
    varargout = initalize(obj, varargin) % build remoteclass USSE.USSE
    
    % Ultrasound sequence management
    varargout = callbacks(obj, src, event) % manages GUIs callbacks

end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )

    % legHAL dedicated methods
    varargout = buildRemote(obj, varargin)    % build the associated remote structure
    obj = buildLutParams( obj, BFstruct )
    varargout = selectHardware(obj, varargin) % select the hardware
    varargout = selectProbe(obj, varargin)    % select the probe
    
    % Host system management
    varargout = initializeRemote(obj, varargin) % initialize the remote server
    varargout = quitRemote(obj, varargin)       % switch the system to user level
    varargout = stopSystem(obj, varargin)       % stop the remote host
    
    % Sequence management
    varargout = loadSequence(obj, varargin)  % load the ultrasound sequence
    varargout = startSequence(obj, varargin) % start the loaded ultrasound sequence
    varargout = stopSequence(obj, varargin)  % stop the loaded ultrasound sequence
    varargout = getData(obj, varargin)       % wait for data and retrieve them
    buf = realignData(obj, buf) % realign RF data

end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = usse(varargin)

        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'USSE', ...
                            'default ultrasound sequence', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'USSE', ...
                        'default ultrasound sequence', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.remoteobj(varargin{1:end});

    end

end

% ============================================================================ %
% ============================================================================ %

end
