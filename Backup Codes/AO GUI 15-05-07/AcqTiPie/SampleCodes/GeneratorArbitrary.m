% GeneratorArbitrary.m - for LibTiePie 0.4.1+
%
% This example generates an arbitrary waveform.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Search for devices:
LibTiePie.List.Update;

% Try to open a generator with arbitrary support:
clear Gen;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.GENERATOR )
    Gen = LibTiePie.List.OpenGenerator( IDKIND.INDEX , k );
    if ismember( ST.ARBITRARY , Gen.SignalTypes )
      break;
    else
      clear Gen;
    end
  end
end

if exist( 'Gen' , 'var' )
  % Set signal type:
  Gen.SignalType = ST.ARBITRARY;

  % Set frequency mode:
  Gen.FrequencyMode = FM.SAMPLEFREQUENCY;

  % Set frequency:
  Gen.Frequency = 100e3; % 100 kHz

  % Set amplitude:
  Gen.Amplitude = 2; % 2 V

  % Set offset:
  Gen.Offset = 0; % 0 V

  % Enable output:
  Gen.OutputOn = true;

  % Create arbitrary signal:
  x = 1:10000;
  arData = sin( x / 100 ) .* ( 1 - ( x / 10000 ) );
  clear x;

  % Load the signal into the generator:
  Gen.Data = arData;

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
  error( 'No generator available with arbitrary support!' );
end