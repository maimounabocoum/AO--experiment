% OscilloscopeStream.m - for LibTiePie 0.4.3+
%
% This example performs a stream mode measurment and writes the data to OscilloscopeStream.csv.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Search for devices:
LibTiePie.List.Update;

% Try to open an oscilloscope with stream measurement support:
clear Scp;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.OSCILLOSCOPE )
    Scp = LibTiePie.List.OpenOscilloscope( IDKIND.INDEX , k );
    if ismember( MM.STREAM , Scp.MeasureModes )
      break;
    else
      clear Scp;
    end
  end
end

if exist( 'Scp' , 'var' )
  % Set measure mode:
  Scp.MeasureMode = MM.STREAM;

  % Set sample frequency:
  Scp.SampleFrequency = 1e3; % 1 kHz

  % Set record length:
  Scp.RecordLength = 1000; % 1 kS

  % For all channels:
  for k = 1 : Scp.ChannelCount
    Ch = Scp.Channels( k ); 
      
    % Enable channel to measure it:
    Ch.Enabled = true;

    % Set range:
    Ch.Range = 8; % 8 V

    % Set coupling:
    Ch.Coupling = CK.DCV; % DC Volt

    clear Ch;
  end

  % Print oscilloscope info:
  Scp

  % Prepeare CSV writing:
  sCSV = 'OscilloscopeStream.csv';
  if exist( sCSV , 'file' )
    delete( sCSV )
  end
  arData = [];

  % Start measurement:
  Scp.Start;

  % Measure 10 blocks:
  for k = 1 : 10
    % Display a message, to inform the user that we still do something:
    fprintf( 'Data block %u\n' , k );

    % Wait for measurement to complete:
    while ~( Scp.IsDataReady || Scp.IsDataOverflow || Scp.IsRemoved )
      pause( 10e-3 ) % 10 ms delay, to save CPU time.
    end

    if Scp.IsRemoved
      clear Scp;
      error( 'Device gone!' )
    elseif Scp.IsDataOverflow
      error( 'Data overflow!' )
    end

    % Get data:
    arNewData = Scp.GetData;

    % Apped new data to plot:
    arData = [ arData ; arNewData ];
    figure( 123 );
    plot( arData );
    
    % Append new data to CSV file:
    dlmwrite( sCSV , arNewData , '-append' );
  end
  
  fprintf( 'Data written to: %s\n' , sCSV );

  % Stop stream:
  Scp.Stop;
  
  % Close oscilloscope:
  clear Scp;
else
  error( 'No oscilloscope available with stream measurement support!' );
end