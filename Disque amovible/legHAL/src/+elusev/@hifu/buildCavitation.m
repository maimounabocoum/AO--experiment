% ELUSEV.HIFU.BUILDCAVITATION (PROTECTED)
%   Build the associated remote structure.
%
%   RXTXTW = OBJ.BUILDCAVITATION() returns the array RXTXTW containing the
%   definition of the passive reception events.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.HIFU.
%   It cannot be used without all methods of the remoteclass ELUSEV.HIFU and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/11

function varargout = buildCavitation(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls

% Control the output argument
if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The buildCavitation needs one output argument:\n' ...
        ' - a matrix containing the description of the cavitation events.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Retrieve cavitation parameters
TwFreq     = obj.getParam('TwFreq') * 1e6;
Phase      = obj.getParam('Phase');
RxFreq     = obj.getParam('RxFreq');
RxDuration = obj.getParam('RxDuration') / 1e6;

% ============================================================================ %

% Control RXFREQ
AuthFreq          = system.hardware.ClockFreq ...
    ./ (system.hardware.ADRate * system.hardware.ADFilter);
DiffFreq          = min(AuthFreq(AuthFreq >= (1 - 1e-3) * RxFreq) - RxFreq);
[ADRate ADFilter] = find((AuthFreq - RxFreq) == DiffFreq);
[ADFilter I]      = max(ADFilter);
ADRate            = system.hardware.ADRate(ADRate(I));
RxFreq            = system.hardware.ClockFreq ./ (ADRate * ADFilter) * 1e6;

% ============================================================================ %
% ============================================================================ %

%% Build the RxTxTw

% Initialize variables
MaxSamples  = system.hardware.MaxSamples;
TwPeriod    = 1 / (obj.getParam('TwFreq') * 1e6);
NSampPeriod = system.hardware.ClockFreq * 1e6 / TwFreq;
Delays      = Phase / (2*pi * TwFreq);

% Possible (Tx,Tw)
PossRepeat   = [(1:1024) ((1:1024) .* 256)];
NbPossCycles = PossRepeat' * (1 : floor(MaxSamples / NSampPeriod));
PossDuration = NbPossCycles .* TwPeriod + max(Delays) / 1e6;

% ============================================================================ %

% Build the 1us blocks
if ( RxDuration * RxFreq > 4096.001 )
    
    % Build the acceptable 1us Blocks
    PossDuration = PossDuration .* (PossDuration <= 4096 / RxFreq);
    Block1us = ceil(PossDuration / 1e-6) * 1e-6 - PossDuration;
    Mask     = (Block1us <= (5e-4 .* PossDuration));
    Mask     = Mask & (PossDuration <= RxFreq) & (PossDuration <= 2e-3);
    Block1us = PossDuration .* Mask;

    % Control with the number of samples
    NSamples = (Block1us * RxFreq);
    Level    = min(10, round(1e-6 * RxFreq));
    Mask     = (rem(floor(NSamples), 128) < Level);
    Block1us = Block1us .* Mask;
    
    % Control the number of repetition
    Mask = RxDuration ./ Block1us .* (Block1us ~= 0);

    % Determine the best combination
    [repeat NbPeriod] = find(Mask == min(Mask(:)), 1, 'first');
    NbRepeat          = ceil(Mask(repeat, NbPeriod));
    
    % Build the TxTwRx
    DurationEvent = PossDuration(repeat, NbPeriod);
    DurationEvent = ...
        (DurationEvent >= 5e-3) .* ceil(DurationEvent / 5e-3) * 5e-3 ...
        + (DurationEvent <= 2e-3) .* ceil(DurationEvent / 1e-6) * 1e-6;
    repeat256     = ( rem(PossRepeat(repeat), 256) == 0 );
    repeat001     = PossRepeat(repeat) / (1 + 255 * repeat256);
    RxTxTw        = [DurationEvent, NbPeriod, (repeat001 - 1),  repeat256];
    RxTxTw        = repmat(RxTxTw, [NbRepeat 1]);
    
% ============================================================================ %

else
    
    % Build the 5 ms blocks
    Mask     = (PossDuration >= 5e-3) & (PossDuration >= RxDuration) ...
        & (PossDuration <= 10);
    Block5ms = PossDuration .* Mask;

    % Build the 1 us blocks
    Mask     = (PossDuration >= RxDuration) & (PossDuration <= 2e-3);
    Block1us = PossDuration .* Mask;

    % Determine the shortest transmit event
    Block = Block5ms + Block1us;

    % Determine the best combination
    [repeat NbPeriod] = find(Block == min(Block(Block ~= 0)), 1, 'first');

% ============================================================================ %

    % Build the TxTwRx
    DurationEvent = PossDuration(repeat, NbPeriod) + TwPeriod;
    DurationEvent = (DurationEvent >= 5e-3) .* ceil(DurationEvent / 5e-3) ...
        * 5e-3 + (DurationEvent <= 2e-3) .* ceil(DurationEvent / 1e-6) * 1e-6;
    repeat256     = ( rem(PossRepeat(repeat), 256) == 0 );
    repeat001     = PossRepeat(repeat) / (1 + 255 * repeat256);
    RxTxTw        = [DurationEvent, NbPeriod, (repeat001 - 1),  repeat256];

end

% ============================================================================ %
% ============================================================================ %

% Output values
varargout{1} = RxTxTw;

% ============================================================================ %
% ============================================================================ %

% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'buildCavitation');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end