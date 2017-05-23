%% test sheet %%
clearvars;
Nloop = 10 ;
MyMeasurement = oscilloTrace(100,200,10e6,1540) ;
%mygui = oscilloGUI();

%MyMeasurement = MyMeasurement.Addline(actual.ActualStart,actual.ActualLength,datatmp,LineNumber);
for i = 1:Nloop
MyMeasurement.Lines = repmat(exp(-(MyMeasurement.t(1:100)'-3e-6).^2/(1e-6)^2),1,200) + 0.1*rand(100,200);
MyMeasurement.ScreenAquisition();

if MyMeasurement.IsRunning == 0
    break;
end
pause(1)

end
