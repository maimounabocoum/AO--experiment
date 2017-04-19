
rubiStartSequence;


CC ='';
while strcmpi(CC, '');
    figure(1)
    rubiTransfertBfData
    CC = get(1,'CurrentCharacter');
    data = typecast(buffer.data,'single');
    data2 = reshape(data,buffer.nsample,buffer.nline);
    imagesc(log(data2));
end

rubiStopSequence;