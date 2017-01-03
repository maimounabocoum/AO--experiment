function PolluxDepRel(controller,axe,d)

fprintf(controller,[num2str(d,'%2.2f') ' ' num2str(axe) ' nr']);

PolluxWaitToFinish(controller,axe)

end