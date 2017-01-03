% ACMO.BFOC.INITIALIZE (PROTECTED)
%   Build the remoteclass ACMO.BFOC.
%
%   OBJ = OBJ.INITIALIZE() returns a generic ACMO.COLOR instance.
%
%   OBJ = OBJ.INITIALIZE(DEBUG) returns a generic ACMO.COLOR instance using
%   the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, DEBUG) returns an ACMO.COLOR instance
%   with its name and description values set to NAME and DESC (character
%   values).
%
%   OBJ = OBJ.INITIALIZE(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) returns an
%   ACMO.COLOR instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - TWFREQ (single) sets the flat emission frequency.
%       [1 20] MHz
%     - NBHCYCLE (int32) sets the number of half cycle.
%       [1 200]
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
%       [0 100] mms
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
%     - FOCUS  (single) sets the focal depth [0 100] mm
%     - FDRATIO (single) Fnumber
%     - XOrigin (single) : lateral shift of each acoustic line from the left side of the element (mm)
%     - FirstLinePos (int32) : position of the first transmitted beam on
%     the probe (element idx)
%     - NBFOCLINES (int32) : number of transmit lines
%     - TXLINEPITCH (int32) : line pitch (element)
%     - STEERANGLE (single) sets the steering angle.
%       [-40 40]
%     - ENSEMBLELENGTH (int32) : ensemble length used to characterize
%     repetition
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
%   Note - This function is defined as a method of the remoteclass
%   ACMO.BFOC. It cannot be used without all methods of the remoteclass
%   ACMO.BFOC and all methods of its superclass ACMO.ACMO developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/02/01

function obj = initialize(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

current_class = 'acmo.color';

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

% Initialize ACMO.ACMO superclass
obj = initialize@acmo.acmo(obj, varargin{1:end});

% ============================================================================ %
% ============================================================================ %

%% Add new parameters

% ============================================================================ %

Par = common.parameter( ...
    'SteerAngle', ...
    'single', ...
    'sets the steering angle', ...
    {[-45 45]}, ...
    {'steering angle [deg]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

Par = common.parameter( ...
    'TwFreq', ...
    'single', ...
    'sets the focused emission frequency', ...
    {[1 system.hardware.MaxTxFreq]}, ...
    {'focused emission frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'NbHcycle', ...
    'int32', ...
    'sets the number of half cycle', ...
    {[1 200]}, ...
    {'number of half cycle'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'PRF', ...
    'single', ...
    'sets the pulse repetition frequency', ...
    {0 [1 3e4]}, ...
    {'greatest pulse repetition frequency', ...
    'pulse repetition frequency [Hz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'DutyCycle', ...
    'single', ...
    'sets the maximum duty cycle', ...
    {[0 1]}, ...
    {'maximum duty cycle'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'ApodFct', ...
    'char', ...
    'sets the apodisation function', ...
    {'none' 'bartlett' 'blackman' 'connes' 'cosine' 'gaussian' 'hamming' ...
        'hanning' 'welch'}, ...
    {'no apodisation' 'bartlett function' 'blackman function' ...
        'connes function' 'cosine function' 'gaussian function' ...
        'hamming function' 'hanning function' 'welch function'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'RxFreq', ...
    'single', ...
    'sets the sampling frequency', ...
    {[1 60]}, ...
    {'focused reception frequency [MHz]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'RxDuration', ...
    'single', ...
    'sets the acquisition duration', ...
    {[0 1000]}, ...
    {'acquisition duration [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'RxDelay', ...
    'single', ...
    'sets the acquisition delay', ...
    {[0 1000]}, ...
    {'acquisition delay [us]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'RxBandwidth', ...
    'int32', ...
    'sets the decimation mode', ...
    {1 2 3}, ...
    {'no decimation', '100% mode', '50% mode'}, ...
    obj.Debug, current_class );
Par = Par.setValue(2);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'FIRBandwidth', ...
    'int32', ...
    'sets the digital filter coefficients', ...
    {-1 [0 100]}, ...
    {'FIR BP coeffs for impulse', 'Load pre-calculated FIR BP coeffs [%]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(100);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TrigIn', ...
    'int32', ...
    'enables the trigger in', ...
    {0 1}, ...
    {'no trigger in', 'trigger in activated'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TrigOut', ...
    'single', ...
    'enables the trigger out', ...
    {0 [1e-3 720.8]}, ...
    {'no trigger out', 'trigger duration [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TrigOutDelay', ...
    'single', ...
    'sets the trigger out delay', ...
    {[0 1000]}, ...
    {'trigger delay [us]'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TrigAll', ...
    'int32', ...
    'enables triggers on all events', ...
    {0 1}, ...
    {'triggers on 1st event', 'triggers on all events'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'PulseInv', ...
    'int32', ...
    'enables the pulse inversion mode', ...
    {0 1}, ...
    {'no pulse inversion' 'pulse inversion enabled'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TxPolarity', ...
    'int32', ...
    'Set the elements polarity of successive Tx for each focused line', ...
    {[0 1]}, ...
    {'0: Standard polarity, 1:Inverted polarity'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TxElemsPattern', ...
    'int32', ...
    'Set the elements pattern of successive Tx for each focused line', ...
    {[0 2]}, ...
    {'0: All elements, 1: Odd elements, 2: Even elements'}, ...
    obj.Debug, current_class );
Par = Par.setValue(0);
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'XOrigin', ...
    'single', ...
    'sets the lateral shift on each scanline', ...
    {[0 100]}, ...
    {'lateral shift on each scanline [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'NbFocLines', ...
    'int32', ...
    'sets the number of scanlines', ...
    {[1 512]}, ...
    {'number of scanlines'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'FirstLinePos', ...
    'int32', ...
    'sets the position of the first scanline (element idx)', ...
    {[1 system.probe.NbElemts]}, ...
    {'number of scanlines'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'TxLinePitch', ...
    'int32', ...
    'sets transmit line pitch in elements', ...
    {[1 256]}, ...
    {'transmit line pitch [elements]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'FDRatio', ...
    'single', ...
    'sets the F/D Ratio', ...
    {[1 20]}, ...
    {'F/D Ratio'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'Focus', ...
    'single', ...
    'sets the focal depth [mm]', ...
    {[5 200]}, ...
    {'focal depth [mm]'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %

Par = common.parameter( ...
    'EnsembleLength', ...
    'int32', ...
    'defines repetition for frequency estimation', ...
    {[4 64]}, ...
    {'Ensemble Length'}, ...
    obj.Debug, current_class );
obj = obj.addParam(Par);

% ============================================================================ %
Par = common.parameter( ...
    'NumberLinesPerBox', ...
    'int32', ...
    'number of transmit firings per pulse repetition interval', ...
    {[1 256]}, ...
    {'NumberLinesPerBox'}, ...
    obj.Debug, current_class );
    Par = Par.setValue(1);
    obj = obj.addParam(Par);

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
