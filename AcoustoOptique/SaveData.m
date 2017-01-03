function SaveData(varargin)
% This function works with the AcoustoOptique GUI and is designed to save
% the current data to a predifined folder if the Save checkbox was ticked
%
% Created by Clement Dupuy on 30/04/15
% Last modified by Clement on 30/04/15

narg=length(varargin);

if narg<1
    error('SaveData must save at least the AO parameters structure')
end

if isstruct(varargin{1})
    AO=varargin{1};
else
    error('The first argument must be the AO parameters structure')
end

Date = datestr(now,'yyyy-mm-dd');
fullDate = datestr(now,'yyyy-mm-dd_hh-MM');

% Define file name
mkdir([AO.Path '\' Date]);
saveName = [AO.Path '\' Date '\' AO.Name];

try
    switch AO.val
        % Create a struct with the parameters to save
        
        case 1
            Param.SEQ = AO.SEQ;
            Param.X0 = AO.X0(AO.val);
            Param.Volt = AO.Volt(AO.val);
            Param.FreqSonde = AO.FreqSonde(AO.val);
            Param.NbHemicycle = AO.NbHemicycle(AO.val);
            Param.Foc = AO.Foc;
            Param.ScanLength = AO.ScanLength(AO.val);
            Param.Prof = AO.Prof(AO.val);
            Param.NTrig = AO.NTrig(AO.val);
            Param.SamplingRate = AO.SamplingRate;
            Param.Range = AO.Range;
            
        case 2
            Param.SEQ = AO.SEQ;
            Param.AlphaM = AO.AlphaM(AO.val);
            Param.Volt = AO.Volt(AO.val);
            Param.FreqSonde = AO.FreqSonde(AO.val);
            Param.NbHemicycle = AO.NbHemicycle(AO.val);
            Param.dA = AO.dA(AO.val);
            Param.ScanLength = AO.ScanLength(AO.val);
            Param.X0 = AO.X0(AO.val);
            Param.Prof = AO.Prof(AO.val);
            Param.NTrig = AO.NTrig(AO.val);
            Param.SamplingRate = AO.SamplingRate;
            Param.Range = AO.Range;
            
        case 3
            Param.SEQ = AO.SEQ;
            Param.Volt = AO.Volt(AO.val);
            Param.FreqSonde = AO.FreqSonde(AO.val);
            Param.NbHemicycle = AO.NbHemicycle(AO.val);
            Param.AlphaM = AO.AlphaM(AO.val);
            Param.dA = AO.dA;
            Param.Nphase = 2*AO.Nphase;
            Param.Prof = AO.Prof(AO.val);
            Param.NTrig = AO.NTrig(AO.val);
            Param.SamplingRate = AO.SamplingRate;
            Param.Range = AO.Range;
    end
catch
    error('The first argument must be the AO parameters structure')
end

varnames='';

varnames='';

if narg>1
    for kk=2:narg
        eval([inputname(kk) '=varargin{' num2str(kk) '};']);
        varnames=[varnames '''' inputname(kk) '''' ','];
    end
else
    warning('No data to save')
end


% Save data, parameters and date

str=['save([saveName ''-'' fullDate ''.mat''],''-v7.3'',' varnames '''fullDate'',''Param'');'];

eval(str);


end