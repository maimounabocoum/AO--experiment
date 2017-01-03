% ELUSEV.HIFU.BUILDEMISSION (PROTECTED)
%   Build the associated remote structure.
%
%   TXTW = OBJ.BUILDEMISSION(TWDURATION) returns the array TXTW containing the
%   definition of the emission events regarding the firing duration TWDURATION.
%
%   Note - This function is defined as a method of the remoteclass ELUSEV.HIFU.
%   It cannot be used without all methods of the remoteclass ELUSEV.HIFU and all
%   methods of its superclass ELUSEV.ELUSEV developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/11

function varargout = buildEmission(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls

% Control the input argument
if ( nargin ~= 2 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The buildEmission needs one input argument:\n' ...
        ' - an integer corresponding to the emission duration.'];
    error(ErrMsg);
    
elseif ( ~isnumeric(varargin{1}) )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The buildEmission needs one input argument:\n' ...
        ' - an integer corresponding to the emission duration.'];
    error(ErrMsg);
    
else

    TwDur = round(varargin{1}) / 1e6;
    
end

% ============================================================================ %

% Control the output argument
if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The buildEmission needs one output argument:\n' ...
        ' - a matrix containing the description of the emission events.'];
    error(ErrMsg);
    
end

% ============================================================================ %

% Retrieve emission parameters
TwFreq    = obj.getParam('TwFreq') * 1e6;
Phase     = obj.getParam('Phase');

% ============================================================================ %
% ============================================================================ %

%% Build the TxTw

% Initialize variables
MaxSamples  = system.hardware.MaxSamples;
TwPeriod    = 1 / (obj.getParam('TwFreq') * 1e6);
NSampPeriod = system.hardware.ClockFreq * 1e6 / TwFreq;
Delays      = Phase / (2*pi * TwFreq);

% Possible (Tx,Tw)
PossRepeat   = [(1:1024) ((1:1024) .* 256)];
NbPossCycles = PossRepeat' * ( 1 : floor( single(MaxSamples) / single(NSampPeriod) ) );
PossDuration = NbPossCycles .* TwPeriod + max(Delays) / 1e6;

% ============================================================================ %

% Build TxTwDef
TxTw = [];

% Loop on firing duration
while ( TwDur > 1e-6 )

    % Build 5 ms blocks
    Block1us = false;
    if ( TwDur >= 5e-3 )
        
        % Build the acceptable 5ms Blocks
        Block5ms = ceil(PossDuration / 5e-3) * 5e-3 - PossDuration;
        Mask     = (Block5ms <= (5e-4 .* PossDuration));
        Mask     = Mask & (PossDuration > 5e-3) & (PossDuration <= TwDur) ...
            & (PossDuration <= 10);
        Block5ms = PossDuration .* Mask;
        
        % Optimal 5 ms block
        [repeat NbPeriod] = find((Block5ms == max(Block5ms(:))) ...
                                    & (Block5ms ~= 0), 1, 'first');
            
        % Build the TxTwDef
        if ~isempty(repeat) % acceptable 5 ms block
            
            % Update TxTwDef
            DurationEvent  = PossDuration(repeat, NbPeriod) + TwPeriod;
            DurationEvent  = ceil(DurationEvent / 5e-3) * 5e-3;
            repeat256      = ( rem(PossRepeat(repeat), 256) == 0 );
            repeat001      = PossRepeat(repeat) / (1 + 255 * repeat256);
            TxTw(end+1, :) = [DurationEvent, NbPeriod, (repeat001 - 1), ...
                repeat256];
            
            % Update remaining duration
            TwDur = TwDur - DurationEvent;
            
        else % no acceptable 5 ms block
            
            Block1us = true;
            
        end
        
    end
    
% ============================================================================ %

    % Build 1 us blocks
    if  (  TwDur > 1e-6  &&  TwDur < 5e-3  )  ||  Block1us
        
        % Build the acceptable 5ms Blocks
        Block1us = ceil(PossDuration / 1e-6) * 1e-6 - PossDuration;
        Mask     = (  Block1us <= (5e-4 .* PossDuration)  );
        Mask     = Mask & (PossDuration <= TwDur) & (PossDuration <= 2e-3);
        Block1us = PossDuration .* Mask;
        
        % Optimal 1 us blocks
        [repeat NbPeriod] = find((Block1us == max(Block1us(:))) ...
                                    & (Block1us ~= 0), 1, 'first');
        
        % Build the TxTwDef
        if ~isempty(repeat) % acceptable 1 us block
            
            % Update TxTwDef
            DurationEvent  = PossDuration(repeat, NbPeriod) + TwPeriod;
            DurationEvent  = ceil(DurationEvent / 1e-6) * 1e-6;
            repeat256      = ( rem(PossRepeat(repeat), 256) == 0 );
            repeat001      = PossRepeat(repeat) / (1 + 255 * repeat256);
            TxTw(end+1, :) = [DurationEvent, NbPeriod, (repeat001 - 1), ...
                repeat256];
            
            % Update remaining duration
            TwDur = TwDur - DurationEvent;
            
        else % no acceptable 1 us block
            
            % Build the prompt of the help dialog box
            if ( TwDur > 2e-6 )
                disp(['The remaining HIFU firing duration (' ...
                    num2str(TwDur * 1e3) ' us) cannot be achieved...']);
            end
            
            % Shorten event...
            TwDur = 0;
                
        end
            
    end
        
end

% ============================================================================ %
% ============================================================================ %

% Output values
varargout{1} = TxTw;

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'buildEmission');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end
