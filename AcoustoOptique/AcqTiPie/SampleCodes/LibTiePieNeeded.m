% LibTiePieNeeded.m - for LibTiePie 0.4.4+
%
% This script opens LibTiePie if not yet opened and makes the variable 'LibTiePie' globally available.
%
% Find more information on http://www.tiepie.com/LibTiePie .

if ~exist( 'LibTiePie' , 'var' )
  % Import the (enumerated) constants for LibTiePie to be able to use them:
  if verLessThan( 'matlab' , '7.7' ) % No class support
    error( 'Matlab 7.7 (R2008b) or higher is required.' );
  elseif verLessThan( 'matlab' , '7.11' ) % No enum support
    import LibTiePie.Const.*
  else
    import LibTiePie.Const.PID
    import LibTiePie.Const.TIID
    import LibTiePie.Const.TOID
    import LibTiePie.Enum.*
  end

  % Open LibTiePie:
  LibTiePie = LibTiePie.Library
end