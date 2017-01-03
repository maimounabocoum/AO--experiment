% GeneratorTriggeredBurst.m - for LibTiePie 0.4.4+
%
% This example generates a 100 kHz square waveform, 25% duty cycle, 0..5 V, 20 periods, this waveform is triggered by the external trigger (EXT 1).
% Connect EXT 1 to GND to trigger the burst.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Update device list:
LibTiePie.List.Update;

% Try to open a generator with triggered burst support:
clear Gen;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.GENERATOR )
    Gen = LibTiePie.List.OpenGenerator( IDKIND.INDEX , k );

    % Check for triggered burst support:
    if ismember( BM.COUNT , Gen.BurstModes ) && Gen.TriggerInputCount > 0
      break;
    else
      clear Gen;
    end
  end
end

if exist( 'Gen' , 'var' )
  % Set signal type:
  Gen.SignalType = ST.SQUARE;

  % Set frequency:
  Gen.Frequency = 100e3; % 100 kHz

  % Set symmetry (duty cycle):
  Gen.Symmetry = 0.25; % 25 %

  % Set amplitude:
  Gen.Amplitude = 5; % 5 V

  % Set offset:
  Gen.Offset = 0; % 0 V

  % Set burst mode:
  Gen.BurstMode = BM.COUNT;

  % Set burst count:
  Gen.BurstCount = 20; % 20 periods

  % Locate trigger input:
  TriggerInput = Gen.GetTriggerInputById( TIID.EXT1 ); % EXT 1

  if TriggerInput == false
    clear TriggerInput;
    clear Gen;
    error( 'Unknown trigger input!' );
  end

  % Enable trigger input:
  TriggerInput.Enabled = true;

  % Set trigger input kind:
  TriggerInput.Kind = TK.FALLING;

  % Release reference to trigger input:
  clear TriggerInput;

  % Enable output:
  Gen.OutputOn = true;

  % Print generator info:
  Gen

  % Start triggered burst:
  Gen.Start;

  % Wait for keystroke:
  display( 'Press any key to stop signal generation...' );
  waitforbuttonpress;

  % Stop generator:
  Gen.Stop();

  % Disable output:
  Gen.OutputOn = false;

  % Close generator: 
  clear Gen;
else
  error( 'No generator available with triggered burst support!' );
end