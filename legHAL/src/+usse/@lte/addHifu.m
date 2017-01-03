% USSE.LTE.ADDHIFU (PUBLIC)
%   Stop the loaded ultrasound sequence.
%
%   OBJ = OBJ.ADDHIFU() adds an HIFU block to the sequence.
%
%   OBJ = OBJ.ADDHIFU(PARNAME, PARVALUE, ...) adds an HIFU block to the sequence
%   with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - HIFUFREQ (single) sets the emitting frequency.
%       [0.5 4] MHz - default = 1
%     - FIRINGDURATION (single) sets the HIFU duration.
%       [1e3 1e6] us - default = 0
%     - TRANSMITELEMTS (int32) sets the tx channels.
%       [1 system.probe.NbElemts] - default = 1:system.probe.NbElemts
%     - PHASE (single) sets the phase offsets.
%       [0 2*pi] rad - default = 0
%     - MAXDUTY (single) sets the waveform duty cycle.
%       [0 1] - default = 0.9
%     - RXFREQ (single) sets the sampling frequency.
%       [1 60] MHz - default = 45
%     - ACQDURATION (single) sets the sampling duration.
%       0 = no acquisition, [1e-6 0.1] s - default = 0
%     - RCVELEMTS (int32) sets the receiving elements.
%       0 = no acquisition, [1 system.probe.NbElemts] - default = 1
%     - TRIGGERMODE (int32) sets the trigger mode.
%       0 = none, 1 = trigger in, 2 = trigger out, 3 = trigger in & out -
%       default = 0
%     - CONTROLPTS (single) sets the TGC control points.
%       [0 960] - default = 950
%     - REPEAT (int32) sets the number of LTEIMAGING repetition.
%       [1 Inf] - default = 1
%     - FASTTGC (int32) enables the fast TGC.
%       0 = classical TGC, 1 = fast TGC - default = 0
%
%   Note - This function is defined as a method of the remoteclass USSE.LTE. It
%   cannot be used without all methods of the remoteclass USSE.LTE and all
%   methods of its superclass USSE.USSE developed by SuperSonic Imagine and
%   without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/08/12

function obj = addHifu(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls on the method

% Check function syntax
if ( nargout ~= 1 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' addHifu function needs 1 output ' ...
        'argument corresponding to the ' upper(class(obj)) ' object.'];
    error(ErrMsg);
    
elseif ( rem(nargin, 2) == 0 )
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' addHifu function needs an even ' ...
        'number of input arguments.'];
    error(ErrMsg);
    
elseif ( nargin > 1 )
    
    % Check if there are no duplicated labels
    Labels = {varargin{1:2:end}};
    
    for k = 1 : length(Labels)
        Idx = find(strcmpi(Labels{k}, Labels));
        
        if ( length(Idx) ~= 1 )
            
            % Build the prompt of the help dialog box
            ErrMsg = ['The ' upper(class(obj)) ' addHifu function only ' ...
                'accepts one definition per parameter. Parameter ' ...
                upper(Labels{k}) ' is defined several times.'];
            error(ErrMsg);
            
        end
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve arguments and control them

% Set default values to the parameters
HifuFreq   = 1;                            % emitting frequency 1 MHz
FiringDur  = 1e5;                          % hifu duration 0.1 s
TxElemts   = 1 : system.hardware.NbTxChan; % all tx channels are used
Phase      = 0;                            % all phase offsets set to 0
DutyCycle  = 0.9;                          % maximum duty cycle of 0.9
RxFreq     = 45;                           % sampling frequency of 45 MHz
RxDur      = 0;                            % sampling duration 0 us (no sampling)
RxElemts   = 1;                            % receiving elements
TrigMode   = 0;                            % no triggers
ControlPts = 950 * ones(1,6);              % TGC control points
Repeat     = 1;                            % repeat factor of the HIFU events
FastTGC    = 0;                            % fast TGC parameter

% Control the input arguments
for k = 1 : 2 : length(varargin)
    
    % HIFU emission frequency
    if ( strcmpi(varargin{k}, 'HifuFreq') )
        
        % Estimate potential frequencies
        HifuFreq  = varargin{k+1};
        HifuFreqs = [180 / (ceil(180 / HifuFreq) + 1); ...
            180 / ceil(180 / HifuFreq); 180 / floor(180 / HifuFreq); ...
            180 / (floor(180 / HifuFreq) - 1)];
        
        % HifuFreq should be modified
        if ( isempty(find(HifuFreqs == varargin{k+1}, 1)) )
            
            % Create Prompt and ListString
            Prompt      = [num2str(varargin{k+1}) '-MHz HIFUFREQ not ' ...
                'supported. Select value:'];
            ListString  = strtrim(cellstr(num2str(HifuFreqs)));
            [~, Idx]    = min(abs(HifuFreqs - varargin{k+1}));
            
            % Build the dialog box
            [Selection Value] = listdlg( ...
                'ListString', ListString, ...
                'SelectionMode', 'single', ...
                'ListSize', [250 80], ...
                'InitialValue', Idx, ...
                'Name', 'Change HIFUFREQ', ...
                'PromptString', Prompt);
            
            % Change the value of HIFUFREQ parameter
            if Value
                HifuFreq = str2double(ListString{Selection});
            else
                HifuFreq = str2double(ListString{Idx});
            end
            
        end
        
% ============================================================================ %

    % HIFU emission duration (s -> us)
    elseif ( strcmpi(varargin{k}, 'FiringDuration') )
        
        if ( varargin{k+1} < 1e-3 )
            % Build the prompt of the help dialog box
            ErrMsg = ['The ' upper(class(obj)) ' addHifu function does ' ...
                'not accept a firing duration smaller than 1 ms.'];
            error(ErrMsg);
        elseif ( varargin{k+1} > 1 )
            % Build the prompt of the help dialog box
            ErrMsg = ['The ' upper(class(obj)) ' addHifu function does ' ...
                'not accept a firing duration greater than 1 s.'];
            error(ErrMsg);
        else
            FiringDur = varargin{k+1} * 1e6;
        end
        
% ============================================================================ %

    % TxElemts definition
    elseif ( strcmpi(varargin{k}, 'TransmitElemts') )
        
        if ( ~isempty(varargin{k+1}) )
            varargin{k+1} = unique(sort(varargin{k+1}));
            
            if ( varargin{k+1}(1) < 1 )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept an index of a transmit element ' ...
                    'smaller than 1.'];
                error(ErrMsg);
            elseif ( varargin{k+1}(end) > system.hardware.NbTxChan )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept an index of a transmit element ' ...
                    'greater than ' num2str(system.hardware.NbTxChan) '.'];
                error(ErrMsg);
            else
                TxElemts = varargin{k+1};
            end
        end
        
% ============================================================================ %

    % Phase definition
    elseif ( strcmpi(varargin{k}, 'Phase') )
        
        if ( ~isempty(varargin{k+1}) )
            
            if ( min(varargin{k+1}) < 0 )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept a phase offset smaller than 0.'];
                error(ErrMsg);
            elseif ( max(varargin{k+1}) > 2*pi )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept a phase offset greater than 2*pi.'];
                error(ErrMsg);
            else
                Phase = varargin{k+1};
            end
        end
        
% ============================================================================ %

    % DutyCycle definition
    elseif ( strcmpi(varargin{k}, 'MaxDuty') )
        
        if ( ~isempty(varargin{k+1}) )
            
            if ( min(varargin{k+1}) < 0 )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept a maximum duty cycle smaller than 0.'];
                error(ErrMsg);
            elseif ( max(varargin{k+1}) > 0.9 )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept a maximum duty cycle greater than ' ...
                    '0.9.'];
                error(ErrMsg);
            else
                DutyCycle = varargin{k+1};
            end
        end
        
% ============================================================================ %

    % Sampling frequency definition
    elseif ( strcmpi(varargin{k}, 'RxFreq') )
        
        % Control RXFREQ
        AuthFreq = system.hardware.ClockFreq ...
            ./ (system.hardware.ADRate * system.hardware.ADFilter);
        AuthFreq = sort(AuthFreq(AuthFreq >= (1 - 1e-3) * varargin{k+1}));
        
        if ( isempty(AuthFreq) )
            % Build the prompt of the help dialog box
            ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                'does not accept a sampling frequency of ' ...
                num2str(varargin{k+1}) ' MHz.'];
            error(ErrMsg);
        elseif ( isempty(find(varargin{k+1} == AuthFreq, 1)) )
            
            % Create Prompt and ListString
            Prompt      = [num2str(varargin{k+1}) '-MHz RXFREQ not ' ...
                'supported. Select value:'];
            ListString  = strtrim(cellstr(num2str(AuthFreq)));
            [~, Idx]    = min(abs(HifuFreq - varargin{k+1}));
            
            % Build the dialog box
            [Selection Value] = listdlg( ...
                'ListString', ListString, ...
                'SelectionMode', 'single', ...
                'ListSize', [250 80], ...
                'InitialValue', Idx, ...
                'Name', 'Change RXFREQ', ...
                'PromptString', Prompt);
            
            % Change the value of RXFREQ parameter
            if Value
                RxFreq = str2double(ListString{Selection});
            else
                RxFreq = str2double(ListString{Idx});
            end
            
        else
            RxFreq = varargin{k+1};
        end
        
% ============================================================================ %

    % Sampling duration (s -> us)
    elseif ( strcmpi(varargin{k}, 'AcqDuration') )
        
        if ( varargin{k+1} < 0 )
            % Build the prompt of the help dialog box
            ErrMsg = ['The ' upper(class(obj)) ' addHifu function does ' ...
                'not accept an acquisition duration smaller than 0 ms.'];
            error(ErrMsg);
        elseif ( varargin{k+1} > 0.1 )
            % Build the prompt of the help dialog box
            ErrMsg = ['The ' upper(class(obj)) ' addHifu function does ' ...
                'not accept a acquisition duration greater than 100 ms.'];
            error(ErrMsg);
        else
            RxDur = varargin{k+1} * 1e6;
        end
        
% ============================================================================ %

    % Receiving elements
    elseif ( strcmpi(varargin{k}, 'RcvElemts') )
        
        if ( ~isempty(varargin{k+1}) )
            varargin{k+1} = unique(sort(varargin{k+1}));
            
            if ( varargin{k+1}(1) < 0 )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept an index of a receiving element ' ...
                    'smaller than 1.'];
                error(ErrMsg);
            elseif ( varargin{k+1}(end) > system.hardware.NbTxChan )
                % Build the prompt of the help dialog box
                ErrMsg = ['The ' upper(class(obj)) ' addHifu function ' ...
                    'does not accept an index of a receiving element ' ...
                    'greater than ' num2str(system.hardware.NbTxChan) '.'];
                error(ErrMsg);
            elseif ( length(varargin{k+1}) ...
                    ~= length(unique(mod(varargin{k+1}, ...
                    system.hardware.NbRxChan))) )
                % Elements
                Rcv1  = varargin{k+1}(varargin{k+1} ...
                    > system.hardware.NbRxChan);
                ElStr = '';
                for m = 1 : length(Rcv1)
                    Idx = find(varargin{k+1}(varargin{k+1} < ...
                        system.hardware.NbRxChan + 1) ...
                        == mod(Rcv1(m), system.hardware.NbRxChan));
                    if ( ~isempty(Idx) )
                        ElStr = [ElStr ', ' num2str(varargin{k+1}(Idx)) ...
                            '/' num2str(Rcv1(m))];
                    end
                end
                % Build the prompt of the help dialog box
                ErrMsg = ['Some receiving elements (' ElStr(3:end) ') ' ...
                    'are using the same MUX position.'];
                error(ErrMsg);
            elseif ( (RxDur ~= 0) && isempty(varargin{k+1} ~= 0) )
                % Build the prompt of the help dialog box
                ErrMsg = ['Receiving elements should be defined for a ' ...
                    'non-zero receiving duration.'];
                error(ErrMsg);
            else
                RxElemts = varargin{k+1};
            end
        end
        
% ============================================================================ %

    % Trigger mode
    elseif ( strcmpi(varargin{k}, 'TriggerMode') )
        
        if ( ~isempty(varargin{k+1}) )
            TrigMode = varargin{k+1};
        end
        
% ============================================================================ %

    % TGC control points
    elseif ( strcmpi(varargin{k}, 'TgcControlPts') )
        
        if ( ~isempty(varargin{k+1}) )
            ControlPts = varargin{k+1};
        end
        
% ============================================================================ %

    % Repeat factor
    elseif ( strcmpi(varargin{k}, 'Repeat') )
        
        if ( ~isempty(varargin{k+1}) )
            Repeat = varargin{k+1};
        end
        
% ============================================================================ %

    % FastTGC parameter
    elseif ( strcmpi(varargin{k}, 'FastTGC') )
        
        if ( ~isempty(varargin{k+1}) && isnumeric(varargin{k+1}) )
            FastTGC = int32(varargin{k+1} == 1);
        end
        
% ============================================================================ %

    else
        % Build the prompt of the help dialog box
        ErrMsg = ['The ' upper(class(obj)) ' addHifu function does not ' ...
            'accept parameter ' upper(varargin{k}) '.'];
        error(ErrMsg);
    end
    
end

% ============================================================================ %
% ============================================================================ %

%% Add the HIFU

% Attribute trigger mode
if ( TrigMode == 1 ) % trigger IN
    TrigIn  = 1;
    TrigOut = 0;
elseif ( TrigMode == 2 ) % trigger OUT
    TrigIn  = 0;
    TrigOut = 1;
elseif ( TrigMode == 3 ) % trigger IN/OUT
    TrigIn  = 1;
    TrigOut = 1;
else % no triggers
    TrigIn  = 0;
    TrigOut = 0;
end

% ============================================================================ %

% Build the HIFU elusev
HIFU = elusev.hifu( ...
    'TwFreq', HifuFreq, ...
    'TwDuration', FiringDur, ...
    'TxElemts', TxElemts, ...
    'Phase', Phase, ...
    'DutyCycle', DutyCycle, ...
    'RxFreq', RxFreq, ...
    'RxDuration', RxDur, ...
    'RxElemts', RxElemts, ...
    'TrigIn', TrigIn, ...
    'TrigOut', TrigOut, ...
    'TrigAll', 0, ...
    obj.Debug);

% Create ACMO object
ACMO = acmo.acmo( ...
    'Duration', RxDur, ...
    'ControlPts', ControlPts, ...
    'fastTGC', FastTGC, ...
    'Repeat', Repeat, ...
    'elusev', HIFU, ...
    obj.Debug);

% Add ACMO to USSE.LTE
obj = obj.setParam('acmo', ACMO);

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if ( isempty(Exception.identifier) )
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'addHifu');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end
