% ACMO.INTERLEAVED (ACMO.ACMO)
%   Create an ACMO.INTERLEAVED instance.
%
%   OBJ = ACMO.INTERLEAVED() creates a generic ACMO.INTERLEAVED instance.
%
%   OBJ = ACMO.INTERLEAVED(NAME, DESC, DEBUG) creates an ACMO.INTERLEAVED
%   instance with its name and description values set to NAME and DESC
%   (character values) and using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = ACMO.INTERLEAVED(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates an
%   ACMO.INTERLEAVED instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - NBEVENTS (int32) contains a vector (length equal to the number of
%       interleaved acmos) to define the events size for each acmo.
%       [1 Inf] = number of events
%     - TIMEINTEGRATION (int32) enables preserving the timing between events.
%       0 = do not preserve timing, 1 = preserve timing - default = 0
%
%   Dedicated objects:
%     - ACMO contains the ACMOs to be interleaved.
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
%     - INITIALIZE builds the remoteclass ACMO.INTERLEAVED.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass ACMO.INTERLEAVED.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass ACMO.INTERLEAVED.
%     - GETPARAM retrieves the value/object of a ACMO.INTERLEAVED parameter.
%     - SETPARAM sets the value of a ACMO.INTERLEAVED parameter.
%     - ISEMPTY checks if all ACMO.INTERLEAVED parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass ACMO.INTERLEAVED and its
%   superclass ACMO.ACMO developed by SuperSonic Imagine and without a system
%   with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/03

classdef interleaved < acmo.acmo
   
% ============================================================================ %
% ============================================================================ %

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
  
    varargout = initalize(obj, varargin) % build the remoteclass ACMO.INTERLEAVED
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    
    varargout = buildRemote(obj, varargin) % build associated remote structure
    
end

% ============================================================================ %

%% Class contructor
methods ( Access = 'public' )
    function obj = interleaved(varargin)
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
                varargin = {'INTERLEAVED', ...
                            'default interleaved acquisition modes', ...
                            varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'INTERLEAVED', ...
                        'default interleaved acquisition modes', ...
                        varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@acmo.acmo(varargin{1:end});
        
    end
end

% ============================================================================ %
% ============================================================================ %

end