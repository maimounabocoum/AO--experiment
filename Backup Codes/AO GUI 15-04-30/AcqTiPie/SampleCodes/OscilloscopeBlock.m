% OscilloscopeBlock.m - for LibTiePie 0.4.3+
%
% This example performs a block mode measurment and plots the data.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Search for devices:
LibTiePie.List.Update;

% Try to open an oscilloscope with block measurement support:
clear Scp;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.OSCILLOSCOPE )
    Scp = LibTiePie.List.OpenOscilloscope( IDKIND.INDEX , k );
    if ismember( MM.BLOCK , Scp.MeasureModes )
      break;
    else
      clear Scp;
    end
  end
end

if exist( 'Scp' , 'var' )
  % Set measure mode:
  Scp.MeasureMode = MM.BLOCK;

  % Set sample frequency:
  Scp.SampleFrequency = 1e6; % 1 MHz

  % Set record length:
  Scp.RecordLength = 10000; % 10 kS

  % Set pre sample ratio:
  Scp.PreSampleRatio = 0; % 0 %

  % For all channels:
  for k = 1 : Scp.ChannelCount
    Ch = Scp.Channels( k ); 

    % Enable channel to measure it:
    Ch.Enabled = true;

    % Set range:
    Ch.Range = 8; % 8 V

    % Set coupling:
    Ch.Coupling = CK.DCV; % DC Volt

    % Release reference:
    clear Ch; 
  end

  % Set trigger timeout:
  Scp.TriggerTimeOut = 100e-3; % 100 ms 

  % Disable all channel trigger sources:
  for k = 1 : Scp.ChannelCount
    Scp.Channels( k ).TriggerEnabled = false;
  end

  % Setup channel trigger:
  Ch = Scp.Channels( 1 ); % Ch 1

  % Enable trigger source:
  Ch.TriggerEnabled = true;

  % Kind:
  Ch.TriggerKind = TK.RISING; % Rising edge

  % Level:
  Ch.TriggerLevel = 0.5; % 50 %

  % Hysteresis:
  Ch.TriggerHysteresis = 0.05; % 5 %

  % Release reference:
  clear Ch;

  % Print oscilloscope info:
  Scp

  % Start measurement:
  Scp.Start;

  % Wait for measurement to complete:
  while ~( Scp.IsDataReady || Scp.IsRemoved )
    pause( 10e-3 ) % 10 ms delay, to save CPU time.
  end

  if Scp.IsRemoved
    clear Scp;
    error( 'Device gone!' )
  end

  % Get data:
  arData = Scp.GetData;

  % Get all channel data value ranges (which are compensated for probe gain/offset):
  clear darRangeMin;
  clear darRangeMax;
  for i = 1 : Scp.ChannelCount
    [ darRangeMin( i ) , darRangeMax( i ) ] = Scp.Channels( i ).DataValueRange;
  end

  % Plot results:
  figure( 500 );
  plot( ( 1:Scp.RecordLength ) / Scp.SampleFrequency , arData );
  axis( [ 0 ( Scp.RecordLength / Scp.SampleFrequency ) min( darRangeMin ) max( darRangeMax ) ] );
  xlabel( 'Time [s]' );
  ylabel( 'Amplitude [V]' );

  % Close oscilloscope:
  clear Scp;
else
  error( 'No oscilloscope available with block measurement support!' );
end