% ACMO.PHOTOACOUSTIC.INITIALIZE (PROTECTED)
%   Build the remoteclass ACMO.PHOTOACOUSTIC.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ACMO.PHOTOACOUSTIC instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ACMO.PHOTOACOUSTIC instance
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ACMO.PHOTOACOUSTIC
%   instance with its name and description values set to NAME and DESC
%   (character values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   ACMO.PHOTOACOUSTIC instance with parameters PARSNAME set to PARSVALUE.
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
%   Note - This function is defined as a method of the remoteclass
%   ACMO.PHOTOACOUSTIC. It cannot be used without all methods of the remoteclass
%   ACMO.PHOTOACOUSTIC and all methods of its superclass ACMO.ACMO developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/10/28

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'acmo.photoacoustic';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize ACMO.ACMO superclass
obj = initialize@acmo.acmo(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% Number of frames (default = 10)
Par = common.parameter( ...
    'NbFrames', ...
    'int32', ...
    'sets the number of acquired frames', ...
    {[1 1000]}, ...
    {'number of acquired frames'}, ...
    obj.Debug, current_class );
Par = Par.setValue(10);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Pulse repetition frequency
Par = common.parameter( ...
    'PRF', ...
    'single', ...
    'sets the pulse repetition frequency', ...
    {[1 1e4]}, ...
    {'pulse repetition frequency [Hz]'}, ...
    obj.Debug, current_class );

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Sampling frequency
Par = common.parameter( ...
    'RxFreq', ...
    'single', ...
    'sets the sampling frequency', ...
    {[1 60]}, ...
    {'sampling frequency [MHz]'}, ...
    obj.Debug, current_class );

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Receive center position
Par = common.parameter( ...
    'RxCenter', ...
    'single', ...
    'sets the receive center position', ...
    {[0 100]}, ...
    {'receive center position [mm]'}, ...
    obj.Debug, current_class );

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Synthetic acquisition (default = 0)
Par = common.parameter( ...
    'SyntAcq', ...
    'int32', ...
    'enables synthetic acquisition', ...
    {0 1}, ...
    {'no synthetic acquisition' 'synthetic acquisition'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Acquisition duration
Par = common.parameter( ...
    'RxDuration', ...
    'single', ...
    'sets the acquisition duration', ...
    {[0 1000]}, ...
    {'acquisition duration [us]'}, ...
    obj.Debug, current_class );

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Acquisition delay (default = 0)
Par = common.parameter( ...
    'RxDelay', ...
    'single', ...
    'sets the acquisition delay', ...
    {[0 1000]}, ...
    {'acquisition delay [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Decimation mode (default = 1)
Par = common.parameter( ...
    'RxBandwidth', ...
    'int32', ...
    'sets the decimation mode', ...
    {1 2 3}, ...
    {'no decimation', '100% mode', '50% mode'}, ...
    obj.Debug, current_class );
Par = Par.setValue(1);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Definition of the digital filter coefficients (default = 100)
Par = common.parameter( ...
    'FIRBandwidth', ...
    'int32', ...
    'sets the digital filter coefficients', ...
    {-1 [0 100]}, ...
    {'FIR BP coeffs for impulse', 'Load pre-calculated FIR BP coeffs'}, ...
    obj.Debug, current_class );
Par = Par.setValue(100);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Trigger in (default = 0)
Par = common.parameter( ...
    'TrigIn', ...
    'int32', ...
    'enables the trigger in', ...
    {0 1}, ...
    {'no trigger in', 'trigger in activated'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Trigger out (default = 0)
Par = common.parameter( ...
    'TrigOut', ...
    'single', ...
    'enables the trigger out', ...
    {0 [1e-3 720.8]}, ...
    {'no trigger out', 'trigger duration [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %

% Trigger out delay (default = 0)
Par = common.parameter( ...
    'TrigOutDelay', ...
    'single', ...
    'sets the trigger out delay', ...
    {[0 1000]}, ...
    {'trigger delay [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);

% Add parameter to the object parameters
obj = obj.addParam( Par );

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'initialize');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end