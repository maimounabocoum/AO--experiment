
function varargout = buildRemote(obj, varargin)
   
% ============================================================================ %
% ============================================================================ %

% Start error handling
try

% ============================================================================ %
% ============================================================================ %

%% General controls

% Check syntax
if (nargout ~= 1) && (nargout ~= 2)
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function needs 1 ' ...
        'output argument.'];
    error(ErrMsg);
    
end

% ============================================================================ %
% ============================================================================ %

%% Retrieve parameters and control their value

% Retrieve parameters
SoftIrq = obj.getParam( 'SoftIrq' );
Pause = obj.getParam( 'Pause' );
Pause_us = Pause*1e6;

% Control the Pause (steps of 200 ns)
Pause_Err_us = mod( Pause_us, 0.2 );
if Pause_Err_us > 0 && Pause_Err_us < 0.1
    Pause_us = Pause_us - Pause_Err_us;
    Pause = Pause_us*1e-6;
elseif Pause_Err_us >= 0.1 && Pause_Err_us < 0.2
    Pause_us = Pause_us - Pause_Err_us + 0.2;
    Pause = Pause_us*1e-6;
end

if Pause ~= obj.getParam('Pause')
    WarnMsg = [ 'Pause was changed from ' ...
        num2str( obj.getParam('Pause')) ...
        ' s to ' num2str(Pause) ' s.' ];
    obj.WarningMessage( WarnMsg )
    
    obj = obj.setParam('Pause', Pause);
end


%% must have TW and TW for validity
TX  = remote.tx_arbitrary('txClock180MHz', 0, 'twId', 1, ...
    'Delays', 0, 0);
obj = obj.setParam('tx', TX);

TW  = remote.tw_pulse('repeat', 0, 'repeat256', 0, 'ApodFct', 'none', ...
'TxElemts', 1, 'DutyCycle', 0, 'TwFreq', system.hardware.MaxTxFreq, 'NbHcycle', 0, ...
'Polarity', 1, 'txClock180MHz', 0, 0);
obj = obj.setParam('tw', TW);

%% Build the events

Event_List = {};

if Pause_us > system.hardware.MaxNoop
    Nb_Events         = floor( Pause_us / system.hardware.MaxNoop );
    Pause_Last_Event  = rem( Pause_us, system.hardware.MaxNoop );

    Event_noop = zeros( [ 1 Nb_Events ] ) + system.hardware.MaxNoop ;
    if Pause_Last_Event >= system.hardware.MinNoop
    else
        Event_noop(end) = Event_noop(end) - system.hardware.MinNoop;
        Pause_Last_Event = Pause_Last_Event + system.hardware.MinNoop;
    end
    Event_noop = [ Event_noop Pause_Last_Event ];

    for n = 1:Nb_Events+1
        Event = remote.event( 'noop',Event_noop(n), 'duration',0, obj.Debug );
        Event_List{n} = Event;
    end

else
    Event = remote.event( 'noop',Pause_us, 'duration',0, obj.Debug);
    Event_List{1} = Event;

end

% Update EVENT parameter
obj = obj.setParam( 'event', Event_List );

% ============================================================================ %
% ============================================================================ %

%% Export the associated remote structure

% Build structure out of existing remotepar
[obj Struct] = buildRemote@elusev.elusev( obj, varargin{1:end} );

if SoftIrq
    for n = 1:length(Struct.event)
        Struct.event(n).softIrq = int32(8192);
    end
end

% ============================================================================ %

% Control the output arguments
if isempty(fieldnames(Struct))
    
    % Build the prompt of the help dialog box
    ErrMsg = ['The ' upper(class(obj)) ' buildRemote function could not ' ...
        'build a REMOTE structure.'];
    error(ErrMsg);
    
else
    
    % One output argument
    varargout{1} = Struct;
    
    % Two output arguments
    if nargout == 2
        varargout{2} = varargout{1};
        varargout{1} = obj;
    end
end

% ============================================================================ %
% ============================================================================ %

%% End error handling
catch Exception
    
    % Exception in this method
    if isempty(Exception.identifier)
        
        % Emit the new exception
        NewException = ...
            common.legHAL.GetException(Exception, class(obj), 'buildRemote');
        throw(NewException);

    % Re-emit previous exception
    else
        
        rethrow(Exception);
        
    end
    
end

% ============================================================================ %
% ============================================================================ %

end