% ACMO.ULTRACOLOR (ACMO.ACMO)
%   Create an ACMO.ULTRACOLOR instance.
%
%   OBJ = ACMO.ULTRACOLOR() creates a generic ACMO.ULTRACOLOR instance.
%
%   OBJ = ACMO.ULTRACOLOR(NAME, DESC, DEBUG) creates an ACMO.ULTRACOLOR instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ACMO.ULTRACOLOR(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ACMO.ULTRACOLOR instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TWFREQ (single) sets the flat emission frequency.
%       [1 20] MHz
%     - NBHCYCLE (int32) sets the number of half cycle.
%       [1 200]
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch
%     - DUTYCYCLE (single) sets the maximum duty cycle.
%       [0 1]
%     - TXCENTER (single) sets the transmit center position.
%       [0 100] mm
%     - TXWIDTH (single) sets the transmit width.
%       [0 100] mm
%     - FLATANGLES (single) sets the flat angles.
%       [-40 40] deg
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
%     - RXCENTER (single) sets the receive center position.
%       [0 100] mm
%     - RXWIDTH (single) sets the receive width.
%       [0 100] mm
%     - NUMSAMPLES (int32) sets the number of acquired samples.
%       [0 4096]
%     - SKIPSAMPLES (int32) sets the number of skipped samples.
%       [0 4096]
%     - RXBANDWIDTH (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50% - default = 1
%     - FIRBANDWIDTH (int32) sets the digital filter coefficients.
%       -1 = none, [0 100] = pre-calculated - default = 100
%     - ENSLENGTH (int32) sets the ensemble length.
%       [1 1000]
%     - ANGLEREPFREQ (single) sets the flat angle frequency.
%       0 = greatest possible, [1 30000] Hz
%     - PRF (single) sets the pulse repetition frequency.
%       [1 10000] Hz
%     - FRAMERATE (single) sets the frame rate of the images.
%       0 = PRF / ENSLENGTH, [1 30000] Hz
%     - TRIGIN (int32) enables the trigger in.
%       0 = no trigger in, 1 = trigger in - default = 0
%     - TRIGOUT (single) enables the trigger out.
%       0 = no trigger out, [1e-3 720.8] us = trigger out duration - default = 0
%     - TRIGOUTDELAY (single) sets the trigger out delay.
%       [0 1000] us - default = 0
%     - TRIGALL (int32) enables triggers on all events.
%       0 = triggers on 1st event, 1 = triggers on all events - default = 0
%
%   Inherited parameters:
%     - REPEAT (int32) sets the number of ACMO repetition.
%       [1 Inf] - default = 1
%     - DURATION (single) sets the TGC duration.
%       [0 Inf] us - default = 0
%     - CONTROLPTS (single) sets the value of TGC control points.
%       [0 960] - default = 900
%     - FASTTGC (int32) enables the fast TGC mode.
%       0 = classical TGC, 1 = fast TGC - default = 0
%     - NBLOCALBUFFER (int32) sets the number of local buffer.
%       0 = automatic, [1 20] - default = 0
%     - NBHOSTBUFFER (int32) sets the number of host buffer.
%       [1 10] - default = 1
%     - ORDERING (int32) sets the ELUSEV execution order during the ACMO.
%       0 = chronological, [1 Inf] = customed order - default = 0
%     - REPEATELUSEV (int32) sets the number of times all ELUSEV are repeated
%       before data transfer.
%       [1 Inf] = number of repetitions - default = 1
%
%   Inherited objects:
%     - MODE contains REMOTE.MODE instances.
%     - TGC contains REMOTE.TGC instances.
%     - DMACONTROL contains REMOTE.DMACONTROL instances.
%     - ELUSEV contains ELUSEV.ELUSEV instances.
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass ACMO.ULTRACOLOR.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ACMO.ULTRACOLOR.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ACMO.ULTRACOLOR.
%     - GETPARAM retrieves the value/object of a ACMO.ULTRACOLOR parameter.
%     - SETPARAM sets the value of a ACMO.ULTRACOLOR parameter.
%     - ISEMPTY checks if all ACMO.ULTRACOLOR parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ACMO.ULTRACOLOR and its
%   superclass ACMO.ACMO developed by SuperSonic Imagine and without a system
%   with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/01

classdef ultracolor < acmo.acmo
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
  
    varargout = initalize(obj, varargin) % build the remoteclass ACMO.ULTRACOLOR
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = ultracolor(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'ULTRACOLOR', ...
                            'default ultrafast color acquisition mode', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'ULTRACOLOR', ...
                        'default ultrafast color acquisition mode', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@acmo.acmo(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end