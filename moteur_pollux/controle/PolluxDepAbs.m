function PolluxDepAbs(controller,axe,pos)

fprintf(controller,[num2str(pos,'%2.1f') ' ' num2str(axe) ' nm']);

PolluxWaitToFinish(controller,axe)