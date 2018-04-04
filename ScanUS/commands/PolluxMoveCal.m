function PolluxMoveCal(controller,MyMotor)

fprintf(controller,[ MyMotor ' ncal']);

PolluxWaitToFinish(controller,MyMotor)