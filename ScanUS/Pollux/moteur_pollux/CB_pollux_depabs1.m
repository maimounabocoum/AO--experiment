d_abs1=str2double(get(gcbo,'String'));
d_abs1str=num2str(d_abs1,'%0.1f');
set(bouton_deplacement_abs1,'Callback','PolluxDepAbs(Controller,numero(1),d_abs1);');