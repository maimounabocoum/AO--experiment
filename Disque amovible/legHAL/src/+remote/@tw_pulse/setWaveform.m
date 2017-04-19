% REMOTE.TW_PULSE.SETWAVEFORM (PROTECTED)
%   Build the REMOTE.TW_PULSE waveform.
%
%   WF = OBJ.SETWAVEFORM() returns the waveform WF of the REMOTE.TW_PULSE
%   instance.
%
%   Note - This function is defined as a method of the remoteclass
%   REMOTE.TW_PULSE. It cannot be used without all methods of the remoteclass
%   REMOTE.TW_PULSE and all methods of its superclass REMOTE.TW developed by
%   SuperSonic Imagine and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/02

function varargout = setWaveform(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check syntax
if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' setWaveform function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Build the waveform

% Retrieve parameters
TxElemts = obj.getParam('TxElemts');
TwFreq   = obj.getParam('TwFreq');
NbHcycle = double(obj.getParam('NbHcycle'));
SampFreq = 90 + 90 * double(obj.getParam('txClock180MHz'));
Polarity = double(obj.getParam('Polarity'));

% ============================================================================ %

if NbHcycle > floor( double( system.hardware.MaxSamples ) / ( 0.5 * system.hardware.ClockFreq/2 /TwFreq ) )
    error( [ 'NbHcycle is ' num2str(NbHcycle) ' but should be <= ' num2str( floor( double( system.hardware.MaxSamples ) / ( 0.5 * system.hardware.ClockFreq/2 /TwFreq ) ) ) ] )
end

% Build the temporal waveform
Nsamples     = floor(0.5 * SampFreq / TwFreq);
Waveform_Cos = cos(ceil((1 : Nsamples * NbHcycle) / Nsamples) * pi);

% Build the initial full waveform
varargout{1} = zeros(system.hardware.NbTxChan, length(Waveform_Cos));

if max( TxElemts ) > system.hardware.NbTxChan
    error( [ 'Emmission on element ' num2str(max( TxElemts )) ' but system.hardware.NbTxChan is ' num2str( system.hardware.NbTxChan ) ] )
end

if length( Polarity ) == 1
    Waveform = Polarity * Waveform_Cos;
    varargout{1}(TxElemts, :) = - repmat(Waveform, [length(TxElemts), 1]);

elseif length( Polarity ) == length( TxElemts )
    if size(Polarity,1) == 1
        Polarity = Polarity';
    end

    Waveform = repmat(Waveform_Cos, [length(TxElemts), 1]);
    varargout{1}(TxElemts, :) = - repmat( Polarity, 1, length(Waveform_Cos) ) .* Waveform;

else
    % Build the prompt of the help dialog box
    ErrMsg = ['The length of the Polarity parameter for the class ' upper(class(obj)) ' setWaveform function ' ...
        'must be 1 or equal to the number of transmitting elements.' ];
    error(ErrMsg);

end


% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'setWaveform');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end
