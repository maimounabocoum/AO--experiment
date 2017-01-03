function SaveData(data,X,Y,AO)
% This function works with the AcoustoOptique GUI and is designed to save
% the current data to a predifined folder if the Save checkbox was ticked
%
% Created by Clement Dupuy on 30/04/15
% Last modified by Clement on 30/04/15

Date = datestr(now,'yyyy-mm-dd');
fullDate = datestr(now,'yyyy-mm-dd_hh-MM');

% Define file name
mkdir([AO.Path '\' Date]);
saveName = [AO.Path '\' Date '\' AO.Name];

% Create a struct with the parameters to save 
Param.SEQ = AO.SEQ;
Param.X0 = AO.X0;
Param.Volt = AO.Volt;
Param.FreqSonde = AO.FreqSonde;
Param.NbHemicycle = AO.NbHemicycle;
Param.Foc = AO.Foc;
Param.ScanLength = AO.ScanLength;
Param.Prof = AO.Prof;
Param.NTrig = AO.NTrig;
Param.SamplingRate = AO.SamplingRate;
Param.Range = AO.Range;


% Save data, parameters and date
save([saveName '-' fullDate '.mat'],'data','X','Y','fullDate','Param')

end