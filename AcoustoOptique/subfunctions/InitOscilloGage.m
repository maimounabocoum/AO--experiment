function [ret,handle,acqInfo,sysinfo] = InitOscilloGage(NTrig,Prof,SamplingRate,Range,TriggerSatus)
% Set the acquisition, channel and trigger parameters for the system and
% commit the parameters to the driver.
% AO     = structure with the different parameters
% ret    = positive is setup is successful, negative corresponding to the
% error code else.
% handle = handle for the acq. card
%
% To be used with AO_1D_reglages.m
%
% Created by Clement on 10/06/2015
% Last modified : Clement on 10/06/2015



systems = CsMl_Initialize; % Initialize driver
CsMl_ErrorHandler(systems);


[ret, handle] = CsMl_GetSystem; % Get ready to use Gage handle
try
    % If error, try to free cards and try to get handle again
    CsMl_ErrorHandler(ret);
    
catch exception
    warning(exception.message,exception.identifier)
    display('Attempting to free system')
    ret=CsMl_FreeAllSystems; %frees all systems
    
    try
        CsMl_ErrorHandler(ret); % If no error, system freed
        display('System Freed')
        
    catch exception
        %else, clear all and return
        warning(exception.message,exception.identifier)
        clear all
        return
    end
    
    [ret, handle] = CsMl_GetSystem; %try to get handle again
    
    try
        CsMl_ErrorHandler(ret); % If no error, got handle
        
    catch exception
        %else, clear all and return
        errordlg(exception.message,exception.identifier)
        clear all
        return
    end
end

[ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
CsMl_ErrorHandler(ret, 1, handle);

s = sprintf('-----Board name: %s\n', sysinfo.BoardName);
disp(s);

% ======================================================================= %
%% Acquisition parameters
 
%Customed Parameters

acqInfo.SampleRate      = SamplingRate*1e6;%Max = 50 MHz, must be divider of 50;
acqInfo.SegmentCount    = NTrig; % Number of memory segments 

acqInfo.Depth           = ceil(( acqInfo.SampleRate*1e-6*ceil(Prof/(common.constants.SoundSpeed*1e-3)))/32)*32; % Must be a multiple of 32


%====================== The acqInfo fields can include:
%   SampleRate      - the rate at which to digitize the waveform
%   ExtClock        - a flag to set external clocking on (1) or off (0)
%   Mode            - acquisition mode (1 = Single, 2 = Dual, 4 = Quad, 8 = Octal)
%   SegmentCount    - the number of segments to acquire
%   Depth           - post-trigger depth, in samples
%   SegmentSize     - post and pre-trigger depth
%   TriggerTimeout  - how long to wait before forcing a trigger (in
%                     microseconds). A value of -1 means wait indefinitely.
%   TriggerHoldoff  - the amount of ensured pre-trigger data in samples
%   TriggerDelay    - how long to delay the start of the depth counter
%                     after the trigger event has occurred, in samples
%   TimeStampConfig - the values for time stamp configuration

acqInfo.ExtClock        = 0;
acqInfo.Mode            = 1;%CsMl_Translate('Single', 'Mode');% Use only one channel
acqInfo.SegmentSize     = acqInfo.Depth; % Must be a multiple of 32

switch TriggerSatus   
    case 'on'
acqInfo.TriggerTimeout  = 3e12; % in ms
    case 'off'
acqInfo.TriggerTimeout  = 20;  % in ms : set to natural Rep Rate of 2kHz       
end

acqInfo.TriggerHoldoff  = 0; % Number of points during which the card ignores trigs
acqInfo.TriggerDelay    = 0; % Number of points
acqInfo.TimeStampConfig = 1; % Get the time at which each waveform was acquired
% if non-zero, restart the time stamp counter at each acq.

[ret] = CsMl_ConfigureAcquisition(handle, acqInfo); % config acq parameters
CsMl_ErrorHandler(ret, 1, handle);

% initializes all the channels even though
% they might not all be used.
for i = 1:sysinfo.ChannelCount
    chan(i).Channel     = i;
    chan(i).Coupling    = CsMl_Translate('DC', 'Coupling');
    chan(i).DiffInput   = 0;
    chan(i).InputRange  = 2000;%2000; Vpp in mV
    chan(i).Impedance   = 50; % 50 Ohms or 1 MOhms
    chan(i).DcOffset    = 0;
    chan(i).DirectAdc   = 0;
    chan(i).Filter      = 0; 
end   

% Overwrite setting for channel 1
chan(1).Coupling        = CsMl_Translate('DC', 'Coupling');
chan(1).InputRange      = 2*Range*1e3; % Vpp in mV

[ret] = CsMl_ConfigureChannel(handle, chan); % config chan parameters
CsMl_ErrorHandler(ret, 1, handle);

%========================= Sets trigger parameters
% Trigger       - the trigger engine to set. Trigger numbers start at 1
% Slope         - a value indicating the slope that causes a trigger event 
%                 to occur. Use CsMl_Translate to translate a descriptive 
%                 string into its corresponding index value.
% Source        - a value that sets the trigger source (e.g. External (-1), 
%                 Disable (0), 1, 2, 3, etc.). Use CsMl_Translate to translate 
%                 a descriptive string into its corresponding index value.
% ExtCoupling   - a value that sets the coupling for external trigger input 
%                 (DC or AC). Use CsMl_Translate to translate a descriptive 
%                 string into its corresponding index value. Note that
%                 Channel numbers are just numbers (1, 2, 3, etc) not
%                 names.
% ExtRange      - the external trigger input range in full-scale millivolts
%                 (e.g. 10000 = +/- 5 volt range).
% ExtImpedance	- the external trigger impedance in Ohms. Set 1000000 for HiZ

switch TriggerSatus
    
    case 'on'
trig.Trigger            = 1;
trig.Slope              = CsMl_Translate('Positive', 'Slope'); % Aixplorer Trig has a 'Negative' slope
trig.Level              = 20; % in percent of the trig range (-100 to +100)
trig.Source             = CsMl_Translate('External', 'Source');
trig.ExtCoupling        = CsMl_Translate('DC', 'ExtCoupling');
trig.ExtRange           = 10000; % Vpp in mV, 10000=+-5V
    case 'off'
trig.Trigger            = 1;
trig.Slope              = CsMl_Translate('Negative', 'Slope'); % Aixplorer Trig has a neg slope
trig.Level              = 20; % in percent of the trig range (-100 to +100)
trig.Source             = 0;
trig.ExtCoupling        = CsMl_Translate('DC', 'ExtCoupling');
trig.ExtRange           = 10000; % Vpp in mV, 10000=+-5V      

end

[ret] = CsMl_ConfigureTrigger(handle, trig); % config Trig parameters
CsMl_ErrorHandler(ret, 1, handle);

% The varargin parameter is optional. 
% Coerce   = 1, invalid parameters are coerced to valid ones
% Coerce   = 0, an error is returned in the event of invalid parameters.
% OnChange = 1, CsMl_Commit only send values if they have changed
% OnChange = 0, the values are sent regardless of whether they have changed
% default values : Coerce = 0 ,OnChange = 1

flags.Coerce = 1;
flags.OnChange = 1;
ret = CsMl_Commit(handle, flags);
CsMl_ErrorHandler(ret, 1, handle);

[ret, acqInfo] = CsMl_QueryAcquisition(handle);
CsMl_ErrorHandler(ret, 1, handle);

[ret, sysinfo] = CsMl_GetSystemInfo(handle); % Get card infos
CsMl_ErrorHandler(ret, 1, handle);

CsMl_ResetTimeStamp(handle);

ret = 1;
