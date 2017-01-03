% GeneratorBurst.m - for LibTiePie 0.4.1+
%
% This example generates a 50 Hz sine waveform, 4 Vpp, 100 periods.
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
    if ismember( BM.COUNT , Gen.BurstModes )
      break;
    else
      clear Gen;
    end
  end
end

if exist( 'Gen' , 'var' )
  % Set signal type:
  Gen.SignalType = ST.SINE;

  % Set frequency:
  Gen.Frequency = 50; % 50 Hz

  % Set amplitude:
  Gen.Amplitude = 2; % 2 V

  % Set offset:
  Gen.Offset = 0; % 0 V

  % Set burst mode:
  Gen.BurstMode = BM.COUNT;

  % Set burst count:
  Gen.BurstCount = 100; % 100 periods

  % Enable output:
  Gen.OutputOn = true;

  % Print generator info:
  Gen

  % Start signal burst:
  Gen.Start;

  % Wait for burst to complete:
  while Gen.IsBurstActive
    pause( 10e-3 ); % 10 ms delay, to save CPU time.
  end

  % Disable output:
  Gen.OutputOn = false;

  % Close generator:
  clear Gen;
else
  error( 'No generator available with burst support!' );
end