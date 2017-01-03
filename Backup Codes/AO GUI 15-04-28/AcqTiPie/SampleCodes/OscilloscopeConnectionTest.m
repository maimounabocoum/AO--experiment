% OscilloscopeConnectionTest.m - for LibTiePie 0.4.1+
%
% This example performs a connection test.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Search for devices:
LibTiePie.List.Update;

% Try to open an oscilloscope with connection test support:
clear Scp;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.OSCILLOSCOPE )
    Scp = LibTiePie.List.OpenOscilloscope( IDKIND.INDEX , k );
    if Scp.HasConnectionTest
      break;
    else
      clear Scp;
    end
  end
end

if exist( 'Scp' , 'var' )
  % Enable all channels that support connection testing:
  for k = 1 : Scp.ChannelCount
    Scp.Channels( k ).Enabled = Scp.Channels( k ).HasConnectionTest;
  end

  % Print oscilloscope info:
  Scp

  % Start connection test:
  Scp.StartConnectionTest;

  % Wait for connection test to complete:
  while ~( Scp.IsConnectionTestCompleted || Scp.IsRemoved )
    pause( 10e-3 ); % 10 ms delay, to save CPU time.
  end

  if Scp.IsRemoved
    clear Scp;
    error( 'Device gone!' );
  end

  % Print result:
  display( 'Connection test result:' );
  Scp.ConnectionTestData

  % Close oscilloscope:
  clear Scp;
else
  error( 'No oscilloscope available with connection test support!' );
end