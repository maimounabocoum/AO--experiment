% GeneratorGatedBurst.m - for LibTiePie 0.4.4+
%
% This example generates a 10 kHz square waveform, 5 Vpp when the external trigger input is active.
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
    if ismember( BM.GATED_PERIODS , Gen.BurstModes ) && Gen.TriggerInputCount > 0
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
  Gen.Frequency = 10e3; % 10 kHz

  % Set amplitude:
  Gen.Amplitude = 5; % 5 V

  % Set offset:
  Gen.Offset = 0; % 0 V

  % Set burst mode:
  Gen.BurstMode = BM.GATED_PERIODS;

  % Locate trigger input:
  TriggerInput = Gen.GetTriggerInputById( TIID.EXT1 ); % EXT 1

  if TriggerInput == false
    clear TriggerInput;
    clear Gen;
    error( 'Unknown trigger input!' );
  end

  % Enable trigger input:
  TriggerInput.Enabled = true;

  % Release reference to trigger input:
  clear TriggerInput;

  % Enable output:
  Gen.OutputOn = true;

  % Print generator info:
  Gen

  % Start signal burst:
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
  error( 'No generator available with gated burst support!' );
end