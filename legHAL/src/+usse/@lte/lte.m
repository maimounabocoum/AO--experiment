% USSE.LTE (USSE.USSE)
%   Create an USSE.LTE instance.
%
%   OBJ = USSE.LTE() creates a generic USSE.LTE instance.
%
%   OBJ = USSE.LTE(DEBUG) creates a generic USSE.LTE instance using the DEBUG
%   value (1 is enabling the debug mode).
%
%   OBJ = USSE.LTE(NAME, DESC, DEBUG) creates an USSE.LTE instance with its
%   name and description values set to NAME and DESC (character values).
%
%   OBJ = USSE.LTE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   USSE.LTE instance with parameters PARSNAME set to PARSVALUE.
%
%   Inherited parameters:
%     - REPEAT (int32) sets the number of USSE repetition.
%       [1 Inf]
%     - LOOP (int32) enables the loop mode.
%       0 = single execution sequence, 1 = loop the sequence
%     - DATAFORMAT (char) sets the format of output data.
%       RF = RF data, BF = beamformed data, FF = final frame data - default = RF
%     - ORDERING (int32)sets the ACMO execution order during the USSE.
%       0 = chronological, [1 Inf] = customed order - default = 0
%
%   Inherited objects:
%     - TPC contains a single REMOTE.TPC instance.
%     - ACMO contains ACMO.ACMO instances.
%
%   Inherited variables:
%     - SERVER contains the remote server parameters - default = 192.168.1.15.
%     - INFOSTRUCT contains general information on the ultrasound sequence.
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass USSE.USSE.
%     - BUILDREMOTE builds the associated remote structure.
%     - ADDHIFU adds an HIFU block to the sequence.
%     - ADDIMAGING adds an LTEIMAGING block to the sequence.
%     - SETVOLTAGE sets the Magna Power voltage.
%     - SETCURRENT sets the Magna Power current.
%     - SETCURRENTLIMITATION set the current limitation of the magna power
%     - SETVOLAGELIMITATION set the voltage limitation of the magna power
%     - GETMEASCURRENTTPC get the current measuredby the Magna power
%     - getAlarmTpcAndClear et the Magna Power questionnable Conditional
%     register and clear alarm if varargin = True
%     - GETDATA waits for data and retrieves them.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass USSE.USSE.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass USSE.USSE.
%     - GETPARAM retrieves the value/object of a USSE.USSE parameter.
%     - SETPARAM sets the value of a USSE.USSE parameter.
%     - ISEMPTY checks if all USSE.USSE parameters are correctly defined.
%     - CALLBACKS manages GUIs callbacks.
%     - SELECTHARDWARE selects the system hardware.
%     - SELECTPROBE selects the probe.
%     - INITIALIZEREMOTE initializes the remote server.
%     - QUITREMOTE switches the system to user level.
%     - STOPSSYSTEM stops the remote host.
%     - LOADSEQUENCE loads the ultrasound sequence.
%     - STARTSEQUENCE starts the loaded ultrasound sequence.
%     - STOPSEQUENCE stops the loaded ultrasound sequence.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass USSE.LTE and its superclass
%   USSE.USSE developed by SuperSonic Imagine and without a system with a REMOTE
%   server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/09/07

classdef lte < usse.usse
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin) % build remoteclass USSE.LTE
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    % legHAL dedicated methods
    varargout = buildRemote(obj, varargin) % build the remote structure
    varargout = addHifu(obj, varargin)     % add an HIFU block to the sequence
    varargout = addImaging(obj, varargin)  % adds an LTEIMAGING block to the sequence
    
    % Host system management
    varargout = setVoltage(obj, varargin)           % set the Magna Power voltage
    varargout = setCurrent(obj, varargin)           % set the Magna Power current    
    varargout = setCurrentLimitation(obj, varargin) % set the Magna Power current limitation 
    varargout = getMeasCurrentTpc(obj)              % get the Magna Power current measured
    varargout = getAlarmTpcAndClear(obj, varargin)  % get the Magna Power questionnable Conditional register and clear alarm if varargin = True    
    varargout = setVoltageLimitation (obj, varargin)  % set the Magna Power voltage limitation 
    % Sequence management
    varargout = getData(obj, varargin) % wait for data and retrieve them
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = lte(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'LTE', ...
                            'default liver therapy ultrasound sequence', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'LTE', ...
                        'default liver therapy ultrasound sequence', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@usse.usse(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end