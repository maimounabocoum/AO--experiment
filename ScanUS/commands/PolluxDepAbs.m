function PolluxDepAbs(controller,pos,MyMotor)

fprintf(controller,[num2str(pos,'%2.1f') ' ' MyMotor ' nmove']);

PolluxWaitToFinish(controller,MyMotor)