%%
srv = remoteDefineServer('extern','192.168.1.16',9999);
remoteSetOutputFormat(srv, 'FF');

%%

tmpfile = 'remoteImg.jpg';
t=clock;
pressedKey ='';
figureHandle = figure();
frSum = 0;
frCount = 0;
i = 0;

while ~strcmpi(pressedKey, 'q');
    pressedKey = get(figureHandle,'CurrentCharacter');
    if strcmpi(pressedKey, ' ');
        k = waitforbuttonpress;
    end
       [buffer, status] = remoteTransfertData(srv, 'FF');
        if strcmp(status.type,'data') == 1;
             fhandle = fopen (tmpfile, 'w');
             fwrite (fhandle, buffer.data, 'int8');
             fclose (fhandle);
             dispImg = imread(tmpfile);
             image(dispImg);
             drawnow;
         end
    i = i +1;
    FrameRate = (etime(clock,t));
    frSum = frSum + FrameRate;
    frCount = frCount + 1;
    
    t=clock;
end

1/(frSum / frCount)
