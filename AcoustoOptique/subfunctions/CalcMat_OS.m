function BoolActiveList = CalcMat_OS( Xm, fx, BoolActiveList, type )
% creation by Maïmouna Bocoum
% 09/11/2017

% Xm if the coordinate of the probe element centered on the [X0 X1] in
% order to lock the phase to the center of the probe

% convert to column vector:
Xm = Xm(:) ;

switch type
    case 'sin'
BoolActiveList = repmat( (sin(2*pi*fx*Xm)>0) , 1, size(BoolActiveList,2) );
    case 'cos'
BoolActiveList = repmat( (cos(2*pi*fx*Xm)>0) , 1, size(BoolActiveList,2) );
end


end

