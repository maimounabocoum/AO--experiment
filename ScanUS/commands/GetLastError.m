function code = GetLastError(controleur,MyMotor)

fprintf(controleur,[MyMotor 'getnerror']);

code = fscanf(controleur);


end

