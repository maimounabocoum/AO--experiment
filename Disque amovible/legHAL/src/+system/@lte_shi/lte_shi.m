% REMOTE.TPC (COMMON.REMOTEOBJ)
%   Create a REMOTE.TPC instance.
%
%   OBJ = REMOTE.TPC() creates a generic REMOTE.TPC instance.
%
%   OBJ = REMOTE.TPC(NAME, DESC, DEBUG) creates a REMOTE.TPC instance with its
%   name and description values set to NAME and DESC (character values) and
%   using the DEBUG value (1 is enabling the debug mode).
%
%   OBJ = REMOTE.TPC(NAME, DESC, PARNAME, PARVALUE, ..., DEBUG) creates a
%   REMOTE.TPC instance with parameters PARSNAME set to PARSVALUE.
%
%   Dedicated parameters:
%     - IMGVOLTAGE (single) sets maximum imaging voltage.
%       [10 80] V - default = 10
%     - PUSHVOLTAGE (single) sets maximum push voltage.
%       [10 80] V - default = 10
%     - IMGCURRENT sets maximum imaging current.
%       [0 2] A - default = 0.1
%     - PUSHCURRENT sets maximum push current.
%       [0 20] A - default = 0.1
%
%   Inherited variables:
%     - NAME contains the name of the object.
%     - TYPE contains the type of the object.
%     - DESC contains a description of the object.
%     - DEBUG enables the debugging mode.
%
%   Dedicated functions:
%     - INITIALIZE builds the remoteclass REMOTE.TPC.
%     - BUILDREMOTE builds the associated remote structure.
%
%   Inherited functions:
%     - ISPARAM checks if a parameter (or several parameters) already belongs to
%       the remoteclass REMOTE.TPC.
%     - ADDPARAM adds a parameter/object (explicit definition and cell array
%       definition) to the remoteclass REMOTE.TPC.
%     - GETPARAM retrieves the value/object of a REMOTE.TPC parameter.
%     - SETPARAM sets the value of a REMOTE.TPC parameter.
%     - ISEMPTY checks if all REMOTE.TPC parameters are correctly defined.
%
%   Note - This class is defined as a member of the legHAL interface. It cannot
%   be used without all methods of the remoteclass REMOTE.TPC and its superclass
%   COMMON.REMOTEOBJ developed by SuperSonic Imagine and without a system with a
%   REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/07/28

classdef lte_shi < common.object
   
% ============================================================================ %
% ============================================================================ %

properties ( SetAccess = 'private', GetAccess = 'public' )
    srv % remote

    delayI2C       = 0.0003;        % delay between i2C commands
    delay_rel_on   = 0.005;         % delay to toggle a relay
    delay_cmd_rel  = 0.010;         % delay between 2 relay commands
    delay_mux_sels = 0.0003;        % delay for mux selection
    delay_rail_sel = 1;             % delay for rails selection to have no alram at 36 volt in image mode see HW-256 form more details  1s to fix the issue on linux

    rel_im         = hex2dec('0F'); % ?
    rel_th         = 0;             % ?
    rails_im       = hex2dec('0F'); % all rails on ASTEC side
    rails_th       = 0;             % all rails on MAGNA side

    V_HV_conv      = 3276/38;
    I_HV_conv      = 3276/50;
    V5_conv        = 3276/5;
    minusV5_conv   = 1500/-5;
    V12_conv       = 3276/12;
    V5_5_conv      = 3288/5.5;
    user_conv      = 3276/2;
end

properties ( SetAccess = 'protected', GetAccess = 'public' )
    
    NbRemotePars = 6; % parameters
    
end

% ============================================================================ %
% ============================================================================ %

% Private methods
methods ( Access = 'private' )
    
    ret = i2c( obj, varargin )
    i2c_enable( obj )
    init_digital_output( obj )
    init_digital_input( obj )
    init_dac( obj )
    set_rel( obj, rails_sides, hydro )
    set_rails( obj, rails_sides )    
end

% Protected methods (accessible for subclasses)
methods ( Access = 'protected' )
    
    varargout = initalize(obj, varargin)
    
end

% ============================================================================ %

% Public methods
methods ( Access = 'public' )
    init(obj); % remove ?
    set_imaging_hv( obj, hv ) % make public ?
    init_mode( obj, mode, varargin )
    
    report_and_clear_alarms( obj, varargin )
    set_probe_interlock_mask( obj, mask )
    set_probe_temperature_alarm_threshold( obj, temperature )
    set_ld_alarm_threshold( obj, ld, nb_tx, freq_mhz )

    acq = get_analog_acq( obj )
    analog_acq_display( obj )

end

% ============================================================================ %

% Class contructor
methods ( Access = 'public' )
    function obj = lte_shi( srv, varargin )
        
        % Label of the object
        if ( length(varargin) > 1 )
            if ( ~ischar(varargin{1}) || ~ischar(varargin{2}))
%                 varargin = { ...
%                     'TPC', ...
%                     'default power control', ...
%                     varargin{1:end}};
            else
                varargin{1} = upper(varargin{1});
            end
        else
            varargin = { ...
                'LTE SHI', ...
                'LTE SHI control', ...
                varargin{1:end}};
        end
        
        % Initialize object
        obj = obj@common.object(varargin{1:end});
        
        obj.srv = srv;
        
    end
end

% ============================================================================ %
% ============================================================================ %

end