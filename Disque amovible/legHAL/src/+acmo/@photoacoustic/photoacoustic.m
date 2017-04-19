% ACMO.PHOTOACOUSTIC (ACMO.ACMO)
%   Create an ACMO.PHOTOACOUSTIC instance.
%
%   OBJ = ACMO.PHOTOACOUSTIC() creates a generic ACMO.PHOTOACOUSTIC instance.
%
%   OBJ = ACMO.PHOTOACOUSTIC(DEBUG) creates a generic ACMO.PHOTOACOUSTIC
%   instance using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ACMO.PHOTOACOUSTIC(NAME, DESC, DEBUG) creates an ACMO.PHOTOACOUSTIC
%   instance with its name and description values set to NAME and DESC
%   (character values).
%
%   OBJ = ACMO.PHOTOACOUSTIC(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates
%   an ACMO.PHOTOACOUSTIC instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - NBFRAMES (int32) sets the number of acquired frames.
%       [1 1000] - default = 10
%     - PRF (single) sets the pulse repetition frequency.
%       [1 - 10000] Hz
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz
%     - RXCENTER (single) sets the receive center position.
%       [0 100] mm
%     - SYNTACQ (int32) enables synthetic acquisition.
%       0 = classical, 1 = synthetic - default = 0
%     - RXDURATION (single) sets the acquisition duration.
%       [0 1000] us
%     - RXDELAY (single) sets the acquisition delay.
%       [0 1000] us - default = 1
%     - RXBANDWIDTH (int32) sets the decimation mode.
%       1 = 200%, 2 = 100%, 3 = 50% - default = 1
%     - FIRBANDWIDTH (int32) sets the digital filter coefficients.
%       -1 = none, [0 100] = pre-calculated - default = 100
%     - TRIGIN (int32) enables the trigger in.
%       0 = no trigger in, 1 = trigger in - default = 0
%     - TRIGOUT (single) enables the trigger out.
%       0 = no trigger out, [1e-3 720.8] us = trigger out duration - default = 0
%     - TRIGOUTDELAY (single) sets the trigger out delay.
%       [0 1000] us - default = 0
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
%     - INITIALIZE builds the remoteclass ACMO.PHOTOACOUSTIC.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ACMO.PHOTOACOUSTIC.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ACMO.PHOTOACOUSTIC.
%     - GETPARAM retrieves the value/object of a ACMO.PHOTOACOUSTIC parameter.
%     - SETPARAM sets the value of a ACMO.PHOTOACOUSTIC parameter.
%     - ISEMPTY checks if all ACMO.PHOTOACOUSTIC parameters are correctly
%       defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ACMO.PHOTOACOUSTIC and its
%   superclass ACMO.ACMO developed by SuperSonic Imagine and without a system
%   with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/28

classdef photoacoustic < acmo.acmo

% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
  
    varargout = initalize(obj, varargin) % build the remoteclass ACMO.PHOTOACOUSTIC

end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = photoacoustic(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'PHOTOACOUSTIC', ...
                            'default photoacoustic acquisition mode', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'PHOTOACOUSTIC', ...
                        'default photoacoustic acquisition mode', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@acmo.acmo(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end