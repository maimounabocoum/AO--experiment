% TODO: 
% * remote_magna
% * alarms managment

classdef lte_magna < common.object

% ============================================================================ %
% ============================================================================ %

properties ( SetAccess = 'private', GetAccess = 'public' )
    % USSE
    srv

    % RS232 connection
    rs232
end

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
%    varargout = initalize(obj, varargin) % build class LTE_MAGNA
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )

    ret = connect( obj )
%     varargout = setVoltage(obj, varargin)           % set the Magna Power voltage
%     varargout = setCurrent(obj, varargin)           % set the Magna Power current    
%     varargout = setVoltageLimitation (obj, varargin)  % set the Magna Power voltage limitation 
%     varargout = setCurrentLimitation(obj, varargin) % set the Magna Power current limitation 
%     varargout = getMeasCurrentTpc(obj)              % get the Magna Power current measured
%     varargout = getAlarmTpcAndClear(obj, varargin)  % get the Magna Power questionnable Conditional register and clear alarm if varargin = True    

    ret = clearAlarms( obj )
    ret = getIdn( obj )
    ret = getStatus( obj )
    ret = setLocal( obj )
    ret = setRemote( obj )

    ret = start( obj )
    ret = stop( obj )

    ret = getCurrentMin( obj )
    ret = getCurrentMax( obj )
    ret = getCurrent( obj )
    ret = getCurrentLimitationMin( obj )
    ret = getCurrentLimitationMax( obj )
    ret = getCurrentLimitation( obj )
    
    ret = getVoltageMin( obj )
    ret = getVoltageMax( obj )
    ret = getVoltage( obj )
    ret = getVoltageLimitationMin( obj )
    ret = getVoltageLimitationMax( obj )
    ret = getVoltageLimitation( obj )

    ret = getMeasureVoltage( obj )
    ret = getMeasureCurrent( obj )
    
    ret = setVoltage( obj, value )
    ret = setVoltageLimitation( obj, value )
    ret = setCurrent( obj, value )
    ret = setCurrentLimitation( obj, value )
    
end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = lte_magna( srv, varargin )
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
%                 varargin = {'LTE_MAGNA', ...
%                             'default liver therapy Magna power supply', ...
%                             varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = {'LTE_MAGNA', ...
                        'default liver therapy Magna power supply', ...
                        varargin{1:end}};
        end

        % Initialize object
        obj = obj@common.object(varargin{1:end});

        obj.srv = srv;

        % init rs232
        obj.rs232 = system.rs232( obj.srv, ...
            'LTE Magna', 'Serial connection to the LTE Magna power supply', ...
            'Port', 'ttyUSB0', ...
            'BaudRate', 19200, ...
            'DataBits', 8, ...
            'StopBits', 1, ...
            'Parity', 0, ...
            'EndLine', 1, ...
            'Timeout', 400 ...
            );
        obj.rs232.connect();
    end
end

% ============================================================================ %
% ============================================================================ %

end