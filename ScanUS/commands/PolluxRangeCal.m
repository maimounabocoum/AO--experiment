function PolluxRangeCal(controller,MyMotor)

fprintf(controller,[ MyMotor ' nrm']);

PolluxWaitToFinish(controller,MyMotor)