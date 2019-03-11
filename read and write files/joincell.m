function CELL3 = joincell( CELL1 , CELL2 )


Line_cell1 = size(CELL1,1);
Col_cell1  = size(CELL1,2);

Line_cell2 = size(CELL2,1);
Col_cell2  = size(CELL2,2);



CELL3 = cell( max(Line_cell1,Line_cell2) , Col_cell1 + Col_cell2);


CELL3(1:Line_cell1,1:Col_cell1) = CELL1;

CELL3(1:Line_cell2,(Col_cell1+1):(Col_cell1+ Col_cell2)) = CELL2;




end

