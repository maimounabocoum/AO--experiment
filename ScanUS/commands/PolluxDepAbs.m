function PolluxDepAbs(controller,pos,MyMotor)

fprintf(controller,[num2str(pos,'%2.4f') ' ' MyMotor ' nmove']);

PolluxWaitToFinish(controller,MyMotor)