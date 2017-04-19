% PROCESSING.BUILDCOLORMAP (PUBLIC)
%   Build a colormap to be used to display images.
%
%   CMAP = PROCESSING.BUILDCOLORMAP(MAPNAME) returns a colormap to be used with
%   the display function according to a colormap name MAPNAME (ColorDoppler,
%   jet, hot, gray).
%
%   CMAP = PROCESSING.BUILDCOLORMAP(MAPVALUES) returns a colormap to be used
%   with the display function according to a colormap description MAPVALUES. The
%   colormap description is a (n,4)-matrix for which the 1st column corresponds
%   to the position of the break points (0-255), the 2nd to the red channel
%   values (0-255), the 3rd to the green channel values and the 4th to the blue
%   channel values.
%
%   Note - This function is defined as a global method of PROCESSING package. It
%   cannot be used without the legHAL package developed by SuperSonic Imagine
%   and without a system with a REMOTE server running.
%
%   Copyright 2010 Supersonic Imagine
%   Revision: 1.00 - Date: 2010/03/02

function varargout = BuildColorMap(varargin)

% ============================================================================ %
% ============================================================================ %

%% Control the method call
if ( ischar(varargin{1}) ) % definition of MAPSTRING
    
    NewMap = LoadMap(varargin{1});
    
elseif ( isnumeric(varargin{1}) ) % definition of MAPVALUES
    
    if ( size(varargin{1}, 2) ~= 4 ) % 4 columns should be defined
        
        error('PROCESSING:BUILDCOLORMAP', ...
             ['The custom color map needs four columns:\n' ...
              ' - 1st: position of the break points,\n' ...
              ' - 2nd: red channel values,\n' ...
              ' - 3rd: green channel values,\n' ...
              ' - 4th: blue channel values.']);
          
    elseif ( ~isreal(varargin{1}) ) % no complex values are authorized
        
        error('PROCESSING:BUILDCOLORMAP', ...
             'Only real values are authorized to define a colormap.');
         
    else % new colormap
        
        NewMap = varargin{1};
        
    end
    
else
    
    error('PROCESSING:BUILDCOLORMAP', ['The first input argument should be ' ...
        'a vector or the name of an implemented colormap. ' ...
        upper(class(varargin{1})) ' objects are not supported.']);
    
end

% ============================================================================ %

%% Control the NewMap values

if ( min(NewMap(:)) < 0 ) % no values smaller than 0
    
    error('PROCESSING:BUILDCOLORMAP', ...
          'The colormap values should be greater (or equal) than 0.');
      
elseif ( max(NewMap(:)) > 255 ) % no values greater than 255
    
    error('PROCESSING:BUILDCOLORMAP', ...
          'The colormap values should be smaller (or equal) than 255');
      
elseif ( min(NewMap(:,1)) == max(NewMap(:,1)) ) % break points should be distinct
    
    error('PROCESSING:BUILDCOLORMAP', ...
          'The positions of the break points should be distinct.');
      
else % rescale the position of the break points
    
    MinBk = min(NewMap(:,1));
    MaxBk = max(NewMap(:,1));
    NewMap(:,1) = (NewMap(:,1) - MinBk) * 255 / (MaxBk - MinBk);
    
end

% ============================================================================ %

%% Build the colormap

varargout{1} = uint8( ...
    [permute(interp1(NewMap(:,1), NewMap(:,2), 0:255), [2 1]) ...
     permute(interp1(NewMap(:,1), NewMap(:,3), 0:255), [2 1]) ...
     permute(interp1(NewMap(:,1), NewMap(:,4), 0:255), [2 1])]);

% ============================================================================ %
% ============================================================================ %

end

% ============================================================================ %
% ============================================================================ %

%%
% PROCESSING.LOADMAP (PUBLIC)
%   Loads the break points of a colormap
%
%   COLORMAP = LOADMAP(MAPNAME) returns the break points descriptor of the
%   MAPNAME colormap (ColorDoppler, jet, hot, gray).

function Map = LoadMap(MapName)

% ============================================================================ %
% ============================================================================ %

switch lower(MapName)
    
    case 'colordoppler'
        Map = [  0  156  248  252;
                55    3  126  235;
                87   36   67  240;
               123   52   22  255;
               128   47   47   47;
               133  171   11   39;
               155  199    6   31;
               195  248  114   18;
               223  251  192   24;
               255  249  229   12];
           
% ============================================================================ %

    case 'jet'
        Map = [  0  132    0    0;
                32  255    0    0;
                96  255  255    0;
               160    0  255  255;
               224    0    0  255;
               255    0    0  132];
           
% ============================================================================ %

    case 'hot'
        Map = [  0    3    0    0;
                96  255    0    0;
               192  255  255    0;
               255  255  255  255];
           
% ============================================================================ %

    case 'gray'
        Map = [  0    0    0    0;
               255  255  255  255];
           
% ============================================================================ %

    otherwise
        error('PROCESSING:LOADMAP', ['The colormap ' upper(MapName) ' is ' ...
            'not implemented.']);
        
end

% ============================================================================ %
% ============================================================================ %

end

