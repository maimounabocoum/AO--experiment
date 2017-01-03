clear

srv.type = 'extern';
srv.addr = '192.168.1.16';
srv.port = '9999';

msg.name        = 'set_level';
msg.level       = 'user_coarse';
remoteSendMessage(srv, msg);
clear msg

msg=struct('name', 'get_status');
status=remoteSendMessage(srv,msg);
if strcmp(status.freeze,'1');
    msg.name      = 'freeze';
    msg.active    = 0;
    remoteSendMessage(srv, msg);
end
clear msg

% Set Output Format to FF
msg.name='set_output_format';
msg.format='FF';
msg.image_format='bmp';
msg.framerate_limit=10000;
remoteSendMessage(srv,msg);
clear msg

buffer.data = int8(0);
param = remoteGetFFData(srv,buffer);

msg.name        = 'set_level';
msg.level       = 'system';
remoteSendMessage(srv, msg);
clear msg


data_uint = int16(buffer.data);       %les datas sont en int8, on veut au final un uint8
data_uint(buffer.data<0) = int16(buffer.data(buffer.data<0))+int16(256);
%pour traiter le formatage bizarre des data de retour (genre de modulo 256: a plus de 127 on passe a -128)

indice_debut = length(buffer.data)-3*str2num(param.height)*str2num(param.width)+1;
%seules les datas de la fin du buffer contiennent l'image (image RGB)
indice_fin = length(buffer.data);
image_Bmode_3 = reshape(data_uint(abs(indice_debut):indice_fin),...
    3,str2num(param.width),str2num(param.height));
data = cat(3,flipud(squeeze(image_Bmode_3(3,:,:))'),...
    flipud(squeeze(image_Bmode_3(2,:,:))'),...
    flipud(squeeze(image_Bmode_3(1,:,:))'));   %on recale tout le mode dans le bon ordre (data en BGR et non pas RGB)
data = uint8(data);

imagesc(data)