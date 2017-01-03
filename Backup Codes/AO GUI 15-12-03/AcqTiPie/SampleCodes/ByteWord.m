function [ Result ] = ByteWord( by , w )
% ByteWord creates an 'array' of the byte, followed by the word in Big-endian.
  Result = uint32( bitor( uint32( bitor( by , bitand( uint16( w ) , hex2dec( 'FF00' ) ) ) ) , bitshift( uint32( bitand( uint16( w ) , hex2dec( 'FF' ) ) ) , 16 ) ) );
end