function test(varargin)
% This function works with the AcoustoOptique GUI and is designed to save
% the current data to a predifined folder if the Save checkbox was ticked
%
% Created by Clement Dupuy on 30/04/15
% Last modified by Clement on 30/04/15

saveName='blabla';
Date = datestr(now,'yyyy-mm-dd');
fullDate = datestr(now,'yyyy-mm-dd_hh-MM');

varnames='';

if length(varargin)>1
    for kk=2:length(varargin)
        eval([inputname(kk) '=varargin{' num2str(kk) '};']);
        varnames=[varnames '''' inputname(kk) '''' ','];
    end
else
    warning('No data to save')
end


% Save data, parameters and date

str=['save([saveName ''-'' fullDate ''.mat''],' varnames '''fullDate'',''Param'');'];

eval(str);


end