% OscilloscopeCombineHS4.m - for LibTiePie 0.4.4+
%
% This example demonstrates how to create and open a combined instrument of all found Handyscope HS4 / Handyscope HS4 DIFF's.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Update device list:
LibTiePie.List.Update;

% Try to open all HS4(D) oscilloscopes:
arAllowedProductIDs = [ PID.HS4, PID.HS4D ];
import LibTiePie.Oscilloscope;
arScps = Oscilloscope.empty;

for k = 0 : LibTiePie.List.Count - 1
  if ismember( LibTiePie.List.DeviceProductId( IDKIND.INDEX , k ) , arAllowedProductIDs ) && LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.OSCILLOSCOPE )
    arScps( end + 1 ) = LibTiePie.List.OpenOscilloscope( IDKIND.INDEX , k );
    fprintf( 'Found: %s, s/n: %u\n' , arScps( end ).Name , arScps( end ).SerialNumber );
  end
end

if ( length( arScps ) > 1 )
  % Create and open combined instrument:
  Scp = LibTiePie.List.CreateAndOpenCombinedDevice( arScps );

  % Remove HS4(D) objects, not required anymore:
  clear arScps;

  % Print combined oscilloscope info:
  Scp

  % Get serial number, required for removing:
  dwSerialNumber = Scp.SerialNumber;

  % Close combined oscilloscope:
  clear Scp;

  % Remove combined oscilloscope from the device list:
  LibTiePie.List.RemoveDevice( dwSerialNumber );
else
  clear arScps;
  error( 'Not enough HS4(D)''s found, at least two required!' );
end