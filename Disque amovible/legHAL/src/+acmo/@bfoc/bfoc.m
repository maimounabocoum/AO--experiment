% ACMO.BFOC (ACMO.ACMO)
%   Create an ACMO.BFOC instance.
%
%   OBJ = ACMO.BFOC() creates a generic ACMO.BFOC instance.
%
%   OBJ = ACMO.BFOC(NAME, DESC, DEBUG) creates an ACMO.BFOC instance
%   with its name and description values set to NAME and DESC (character
%   values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ACMO.BFOC(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ACMO.ULTRAFAST instance with parameters PARSNAME set to PARSVALUE.
%
%     - TWFREQ (single) sets the flat emission frequency.
%       [1 20] MHz
%     - NBHCYCLE (int32) sets the number of half cycle.
%       [1 200]
%     - STEERANGLE (single) sets the steering angle.
%       [-40 40] °
%     - PRF (single) sets the pulse repetition frequency.
%       0 = greatest possible, [1 30000] Hz
%     - DUTYCYLE (single) sets the maximum duty cycle.
%       [0 1]
%     - APODFCT (char) sets the apodisation function.
%       none, bartlett, blackman, connes, cosine, gaussian, hamming, hanning,
%       welch
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
%     - RXCENTER (single) sets the receive center position.
%       [0 100] mm
%     - RXDURATION (single) sets the acquisition duration.
%       [0 1000] us
%     - RXDELAY (single) sets the acquisition delay.
%       [0 1000] us
%     - RXBANDWIDTH (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50% - default = 2
%     - FIRBANDWIDTH (int32) sets the digital filter coefficients.
%       -1 = none, [0 100] = pre-calculated - default = 100
%     - TRIGIN (int32) enables the trigger in.
%       0 = no trigger in, 1 = trigger in - default = 0
%     - TRIGOUT (single) enables the trigger out.
%       0 = no trigger out, [1e-3 720.8] us = trigger out duration - default = 0
%     - TRIGOUTDELAY (single) sets the trigger out delay.
%       [0 1000] us - default = 0
%     - TRIGALL (int32) enables triggers on all events.
%       0 = triggers on 1st event, 1 = triggers on all events - default = 0
%     - REPEATFLAT (int32) sets the number of events repetition.
%       [1 1000] - default = 1
%     - PULSEINV (int32) enables the pulse inversion mode.
%       0 = no pulse inversion, 1 = pulse inversion - default = 0
%     - FOCUS  (single) sets the focal depth [0 100] mm
%     - FDRATIO (single) Fnumber
%     - XOrigin (single) : lateral shift of each acoustic line from the left side of the element (mm)
%     - NBFOCLINES (int32) : number of transmit lines
%     - TXLINEPITCH (int32) : line pitch (element)
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
%     - NBHOSTBUFFER (int32) sets the number of host buffer.
%       [1 10] - default = 2
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
%     - INITIALIZE builds the remoteclass ACMO.BFOC.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ACMO.BFOC.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ACMO.BFOC.
%     - GETPARAM retrieves the value/object of a ACMO.BFOC parameter.
%     - SETPARAM sets the value of a ACMO.BFOC parameter.
%     - ISEMPTY checks if all ACMO.BFOC parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ACMO.BFOC and its
%   superclass ACMO.ACMO developed by SuperSonic Imagine and without a system
%   with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/01

classdef bfoc < acmo.acmo
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
  
    varargout = initalize(obj, varargin) % build the remoteclass ACMO.BFOC
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = bfoc(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'BFOC', ...
                            'default focused acquisition mode', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'BFOC', ...
                        'default focused acquisition mode', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@acmo.acmo(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end