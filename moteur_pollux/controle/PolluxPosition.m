function y=PolluxPosition(controleur,axe)

fprintf(controleur,[num2str(axe) ' np']);
y=str2double(fscanf(controleur,'%s'));