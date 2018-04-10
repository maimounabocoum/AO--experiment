function PolluxDepRel(controller,pos,MyMotor)

fprintf(controller,[num2str(pos,'%2.4f') ' ' MyMotor ' nr']);

PolluxWaitToFinish(controller,MyMotor)

end