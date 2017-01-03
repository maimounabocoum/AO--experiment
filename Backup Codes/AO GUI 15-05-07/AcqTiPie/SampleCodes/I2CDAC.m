% I2CDAC.m - for LibTiePie 0.4.1+
%
% This example demonstrates how to use an I2C host supported by LibTiePie.
% It shows how to control an Analog Devices AD5667 dual 16-bit DAC.
%
% Find more information on http://www.tiepie.com/LibTiePie .

% Open LibTiePie and display library info if not yet opened:
LibTiePieNeeded

% Search for devices:
LibTiePie.List.Update;

% Try to open an I2C host:
clear I2C;
for k = 0 : LibTiePie.List.Count - 1
  if LibTiePie.List.DeviceCanOpen( IDKIND.INDEX , k , DEVICETYPE.I2CHOST )
    I2C = LibTiePie.List.OpenI2CHost( IDKIND.INDEX , k );
    break;
  end
end

if exist( 'I2C' , 'var' )
  % Print I2C host info:
  I2C
    
  % Turn on internal reference:
  if I2C.Write( 15 , ByteWord( 56 , 1 ) , 3 , 1 )
    % Set DAC to mid level:
    if ~I2C.Write( 15 , ByteWord( 24 , 32768 ) , 3 , 1 );
      clear I2C;
      error( 'I2C write was unsuccessful.' );
    end
  else
    clear I2C;
    error( 'I2C write was unsuccessful.' );
  end

  % Close I2C host:
  clear I2C;
else
  error( 'No I2C host available!' );
end