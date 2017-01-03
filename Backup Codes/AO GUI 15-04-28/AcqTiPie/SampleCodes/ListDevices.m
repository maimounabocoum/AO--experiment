% ListDevices.m - for LibTiePie 0.4.4+
%
% This example prints all the available devices to the screen. 
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Update device list:
LibTiePie.List.Update;

% Get the number of connected devices:
dwConnectedDevices = LibTiePie.List.Count;

if dwConnectedDevices > 0
  fprintf( 'Available devices:\n' );

  for k = 0 : dwConnectedDevices - 1
    fprintf( '  Name: %s\n' , LibTiePie.List.DeviceName( IDKIND.INDEX , k ) );
    fprintf( '    Serial Number  : %u\n' , LibTiePie.List.SerialNumber( IDKIND.INDEX , k ) );
    types = LibTiePie.List.DeviceTypes( IDKIND.INDEX , k );
    if ~LibTiePie.bEnumsSupported
      types = cellfun( @DEVICETYPE.toString , num2cell( types ) , 'UniformOutput' , false );
    end
    fprintf( '    Available types: %s\n' , ArrayToString( types ) );
  end
else
  fprintf( 'No devices found!\n' )
end