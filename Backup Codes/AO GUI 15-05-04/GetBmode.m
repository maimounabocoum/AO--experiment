

srv = remoteDefineServer('extern','192.168.1.16','9999');
remoteSetLevel(srv,'user_coarse');

msg.name='get_status';
toto=remoteSendMessage(srv,msg);
if strcmp(toto.freeze,'1');
    remoteFreeze(srv,0);
end
clear msg

% Set Output Format to FF
msg.name='set_output_format';
msg.format='FF';
msg.image_format='bmp';
msg.framerate_limit=10000;
remoteSendMessage(srv,msg);
clear msg

[data,status] = remoteTransfertData(srv, 'FF');     %data.data = données image en vecteur ligne

data_uint = int16(data.data);       %les datas sont en int8, on veut au final un uint8
data_uint(data.data<0) = int16(data.data(data.data<0))+int16(256);
%pour traiter le formatage bizarre des data de retour (genre de modulo 256: a plus de 127 on passe a -128)

indice_debut = length(data.data)-3*str2num(status.height)*str2num(status.width)+1;
%seules les datas de la fin du buffer contiennent l'image (image RGB)
indice_fin = length(data.data);
image_Bmode_3 = reshape(data_uint(abs(indice_debut):indice_fin),...
    3,str2num(status.width),str2num(status.height));
Bmode = cat(3,flipud(squeeze(image_Bmode_3(3,:,:))'),...
    flipud(squeeze(image_Bmode_3(2,:,:))'),...
    flipud(squeeze(image_Bmode_3(1,:,:))'));   %on recale tout le mode dans le bon ordre (data en BGR et non pas RGB)
Bmode = uint8(Bmode);