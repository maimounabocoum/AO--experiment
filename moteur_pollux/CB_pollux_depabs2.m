d_abs2=str2double(get(gcbo,'String'));
d_abs2str=num2str(d_abs2,'%0.1f');
set(bouton_deplacement_abs2,'Callback','PolluxDepAbs(Controller,numero(2),d_abs2);');