function y = GetSoftwareLim(controleur,MyMotor)



fprintf(controleur,[MyMotor 'getnlimit']);

y = strsplit( fscanf(controleur) );
y = y(1:2)








end

