% Generator.m - for LibTiePie 0.4.1+
%
% This example generates a 100 kHz triangle waveform, 4 Vpp.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Search for devices:
LibTiePie.List.Update;

% Try to open a generator:
clear Gen;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.GENERATOR )
    Gen = LibTiePie.List.OpenGenerator( IDKIND.INDEX , k )
    break;
  end
end

if exist( 'Gen' , 'var' )
  % Set signal type:
  Gen.SignalType = ST.TRIANGLE;

  % Set frequency:
  Gen.Frequency = 100e3; % 100 kHz

  % Set amplitude:
  Gen.Amplitude = 2; % 2 V

  % Set offset:
  Gen.Offset = 0; % 0 V

  % Enable output:
  Gen.OutputOn = true;

  % Print generator info:
  Gen

  % Start signal generation:
  Gen.Start;

  % Wait for keystroke:
  display( 'Press any key to stop signal generation...' );
  waitforbuttonpress;

  % Stop generator:
  Gen.Stop;

  % Disable output:
  Gen.OutputOn = false;

  % Close generator:
  clear Gen;
else
  error( 'No generator available!' );
end